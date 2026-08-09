import { ClassifyPrediction } from '../types';

/** Minimum model confidence required to fire a visual alert (Stage 3). */
export const DETECTION_CONFIDENCE_THRESHOLD = 0.45;

/** Per-label alert cooldown in milliseconds (Stage 3). */
export const DETECTION_COOLDOWN_MS = 3500;

/**
 * Send an audio blob/file to the Express ML proxy.
 * Field name must be `audio` (matches Python /api/v1/classify).
 */
export async function classifyAudio(file: Blob | File): Promise<ClassifyPrediction> {
  const formData = new FormData();
  const filename =
    file instanceof File && file.name
      ? file.name
      : 'chunk.wav';

  formData.append('audio', file, filename);

  console.log('[detectClient] POST /api/detect/classify', filename);

  let res: Response;
  try {
    res = await fetch('/api/detect/classify', {
      method: 'POST',
      body: formData,
    });
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(`Network error calling /api/detect/classify: ${message}`);
  }

  let payload: unknown;
  try {
    payload = await res.json();
  } catch {
    throw new Error(
      `Detect proxy returned non-JSON (HTTP ${res.status}). Is Express running?`
    );
  }

  if (!res.ok) {
    const detail =
      payload &&
      typeof payload === 'object' &&
      'error' in payload &&
      typeof (payload as { error: unknown }).error === 'string'
        ? (payload as { error: string }).error
        : JSON.stringify(payload);
    throw new Error(`Classify failed (HTTP ${res.status}): ${detail}`);
  }

  const prediction = payload as ClassifyPrediction;
  if (
    typeof prediction.predicted_class !== 'string' ||
    typeof prediction.confidence !== 'number'
  ) {
    throw new Error('Classify response missing predicted_class/confidence');
  }

  console.log(
    `[detect] class=${prediction.predicted_class} confidence=${prediction.confidence.toFixed(2)} latency=${Math.round(prediction.inference_ms)}ms`
  );

  return prediction;
}
