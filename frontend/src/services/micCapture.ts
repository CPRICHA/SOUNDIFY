/**
 * Browser microphone capture for Stage 3 live detection.
 *
 * Captures short mono PCM windows, resamples to 16 kHz, and emits WAV blobs
 * compatible with the existing Python classify API (via Express proxy).
 *
 * Sequential contract: `onChunk` is awaited before the next window is taken.
 * Audio is never written to disk.
 */

export const MIC_CHUNK_DURATION_SEC = 1.5;
export const MIC_TARGET_SAMPLE_RATE = 16000;

export type MicCaptureStatus =
  | 'idle'
  | 'requesting'
  | 'listening'
  | 'analyzing'
  | 'error';

export interface MicCaptureOptions {
  /** Window length in seconds (default 1.5). */
  chunkDurationSec?: number;
  /** Called with a mono 16 kHz WAV blob; awaited before next capture. */
  onChunk: (wavBlob: Blob) => Promise<void>;
  onStatus?: (status: MicCaptureStatus, detail?: string) => void;
  onError?: (error: Error) => void;
}

export interface MicCaptureHandle {
  stop: () => void;
}

function downsample(
  input: Float32Array,
  fromRate: number,
  toRate: number
): Float32Array {
  if (fromRate === toRate) {
    return input;
  }
  if (fromRate < toRate) {
    // Upsample is unexpected for mic capture; return as-is (caller still encodes).
    return input;
  }

  const ratio = fromRate / toRate;
  const newLength = Math.floor(input.length / ratio);
  const result = new Float32Array(newLength);

  for (let i = 0; i < newLength; i++) {
    const start = Math.floor(i * ratio);
    const end = Math.min(Math.floor((i + 1) * ratio), input.length);
    let sum = 0;
    let count = 0;
    for (let j = start; j < end; j++) {
      sum += input[j];
      count++;
    }
    result[i] = count > 0 ? sum / count : 0;
  }

  return result;
}

/** Encode mono float32 PCM (-1..1) as 16-bit PCM WAV. */
export function encodeWavMono(
  samples: Float32Array,
  sampleRate: number
): Blob {
  const numSamples = samples.length;
  const bytesPerSample = 2;
  const blockAlign = bytesPerSample; // mono
  const byteRate = sampleRate * blockAlign;
  const dataSize = numSamples * bytesPerSample;
  const buffer = new ArrayBuffer(44 + dataSize);
  const view = new DataView(buffer);

  const writeString = (offset: number, str: string) => {
    for (let i = 0; i < str.length; i++) {
      view.setUint8(offset + i, str.charCodeAt(i));
    }
  };

  writeString(0, 'RIFF');
  view.setUint32(4, 36 + dataSize, true);
  writeString(8, 'WAVE');
  writeString(12, 'fmt ');
  view.setUint32(16, 16, true); // PCM chunk size
  view.setUint16(20, 1, true); // PCM format
  view.setUint16(22, 1, true); // mono
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, byteRate, true);
  view.setUint16(32, blockAlign, true);
  view.setUint16(34, 16, true); // bits per sample
  writeString(36, 'data');
  view.setUint32(40, dataSize, true);

  let offset = 44;
  for (let i = 0; i < numSamples; i++) {
    const s = Math.max(-1, Math.min(1, samples[i]));
    view.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7fff, true);
    offset += 2;
  }

  return new Blob([buffer], { type: 'audio/wav' });
}

function mixToMono(inputBuffer: AudioBuffer): Float32Array {
  const channels = inputBuffer.numberOfChannels;
  const length = inputBuffer.length;
  if (channels === 1) {
    return inputBuffer.getChannelData(0).slice();
  }
  const mono = new Float32Array(length);
  for (let c = 0; c < channels; c++) {
    const data = inputBuffer.getChannelData(c);
    for (let i = 0; i < length; i++) {
      mono[i] += data[i] / channels;
    }
  }
  return mono;
}

/**
 * Start microphone capture. Does not run until called (no auto page-load prompt).
 */
export async function startMicCapture(
  options: MicCaptureOptions
): Promise<MicCaptureHandle> {
  const chunkDurationSec = options.chunkDurationSec ?? MIC_CHUNK_DURATION_SEC;
  const { onChunk, onStatus, onError } = options;

  if (!navigator.mediaDevices?.getUserMedia) {
    const err = new Error(
      'This browser does not support microphone capture (getUserMedia).'
    );
    onStatus?.('error', err.message);
    onError?.(err);
    throw err;
  }

  onStatus?.('requesting', 'Microphone permission required');

  let stream: MediaStream;
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      audio: {
        echoCancellation: true,
        noiseSuppression: true,
        channelCount: 1,
      },
      video: false,
    });
  } catch (err) {
    const name = err instanceof DOMException ? err.name : '';
    let message = 'Microphone unavailable';
    if (name === 'NotAllowedError' || name === 'PermissionDeniedError') {
      message = 'Microphone permission denied';
    } else if (name === 'NotFoundError' || name === 'DevicesNotFoundError') {
      message = 'No microphone found';
    } else if (err instanceof Error) {
      message = err.message;
    }
    const error = new Error(message);
    onStatus?.('error', message);
    onError?.(error);
    throw error;
  }

  const AudioContextCtor =
    window.AudioContext ||
    (window as unknown as { webkitAudioContext: typeof AudioContext })
      .webkitAudioContext;
  const audioContext = new AudioContextCtor();
  await audioContext.resume();

  const source = audioContext.createMediaStreamSource(stream);
  // ScriptProcessor is deprecated but widely supported and simple for Stage 3.
  const bufferSize = 4096;
  const processor = audioContext.createScriptProcessor(bufferSize, 1, 1);

  const nativeRate = audioContext.sampleRate;
  const targetSamplesAtNative = Math.ceil(chunkDurationSec * nativeRate);
  let pending = new Float32Array(0);
  let stopped = false;
  let busy = false; // true while awaiting onChunk (no backlog)

  const appendSamples = (incoming: Float32Array) => {
    const merged = new Float32Array(pending.length + incoming.length);
    merged.set(pending, 0);
    merged.set(incoming, pending.length);
    pending = merged;
  };

  const takeWindow = (): Float32Array | null => {
    if (pending.length < targetSamplesAtNative) {
      return null;
    }
    const window = pending.slice(0, targetSamplesAtNative);
    pending = pending.slice(targetSamplesAtNative);
    return window;
  };

  const processLoop = async () => {
    while (!stopped) {
      if (busy) {
        await new Promise((r) => setTimeout(r, 50));
        continue;
      }

      const windowNative = takeWindow();
      if (!windowNative) {
        await new Promise((r) => setTimeout(r, 50));
        continue;
      }

      busy = true;
      onStatus?.('analyzing', 'Analyzing');

      try {
        const resampled = downsample(
          windowNative,
          nativeRate,
          MIC_TARGET_SAMPLE_RATE
        );
        const wavBlob = encodeWavMono(resampled, MIC_TARGET_SAMPLE_RATE);
        console.log(
          `[mic] chunk ready bytes=${wavBlob.size} duration≈${chunkDurationSec}s rate=${MIC_TARGET_SAMPLE_RATE}`
        );
        await onChunk(wavBlob);
      } catch (err) {
        const error = err instanceof Error ? err : new Error(String(err));
        console.error('[detect] classification failed', error);
        onError?.(error);
      } finally {
        // Drop any audio accumulated during classify to avoid backlog.
        pending = new Float32Array(0);
        busy = false;
        if (!stopped) {
          onStatus?.('listening', 'Listening');
        }
      }
    }
  };

  processor.onaudioprocess = (event) => {
    if (stopped || busy) {
      return;
    }
    const input = event.inputBuffer.getChannelData(0);
    appendSamples(input);
  };

  source.connect(processor);
  // Keep the processor alive without playing mic audio through speakers.
  const silentGain = audioContext.createGain();
  silentGain.gain.value = 0;
  processor.connect(silentGain);
  silentGain.connect(audioContext.destination);

  onStatus?.('listening', 'Listening');
  void processLoop();

  console.log(
    `[mic] capture started nativeRate=${nativeRate} chunk=${chunkDurationSec}s → ${MIC_TARGET_SAMPLE_RATE} Hz WAV`
  );

  return {
    stop: () => {
      if (stopped) return;
      stopped = true;
      try {
        processor.disconnect();
        silentGain.disconnect();
        source.disconnect();
      } catch {
        /* ignore */
      }
      try {
        processor.onaudioprocess = null;
      } catch {
        /* ignore */
      }
      stream.getTracks().forEach((t) => t.stop());
      void audioContext.close();
      pending = new Float32Array(0);
      onStatus?.('idle');
      console.log('[mic] capture stopped; microphone released');
    },
  };
}

/** Unused helper kept for clarity if we ever decode MediaRecorder blobs. */
export function audioBufferToWavBlob(buffer: AudioBuffer): Blob {
  const mono = mixToMono(buffer);
  const resampled = downsample(mono, buffer.sampleRate, MIC_TARGET_SAMPLE_RATE);
  return encodeWavMono(resampled, MIC_TARGET_SAMPLE_RATE);
}
