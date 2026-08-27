import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { SOUND_TAXONOMY } from "./src/data/soundTaxonomy.js";

// Types
interface MockUser {
  id: string;
  name: string;
  age: number;
  phone: string;
  email: string;
  micAccess: boolean;
  termsAccepted: boolean;
  privacyPolicyAccepted: boolean;
  outputPreferences: ('text' | 'icon' | 'color')[];
}

interface MockEvent {
  id: string;
  user_id: string;
  label: string;
  severity: string;
  mode: string;
  timestamp: string;
}

async function startServer() {
  const app = express();
  const PORT = 3000;

  // Middleware for JSON parsing
  app.use(express.json());

  // In-memory persistent states for simulation
  const MOCK_USERS: Record<string, MockUser> = {
    "usr_123": {
      id: "usr_123",
      name: "John Doe",
      age: 28,
      phone: "+15551234567",
      email: "deekshakuselan23@gmail.com",
      micAccess: true,
      termsAccepted: true,
      privacyPolicyAccepted: true,
      outputPreferences: ["text", "icon", "color"]
    }
  };

  const MOCK_EVENTS: MockEvent[] = [];

  // ==========================================
  // 1. SOUND TAXONOMY ENDPOINT
  // ==========================================
  app.get("/api/sound-taxonomy", (req, res) => {
    res.json(SOUND_TAXONOMY);
  });

  // ==========================================
  // 2. AUTH ENDPOINTS
  // ==========================================
  app.post("/api/auth/signup", (req, res) => {
    const { name, age, phone, email, micAccess, termsAccepted, privacyPolicyAccepted } = req.body;
    
    // Check if user exists
    const existing = Object.values(MOCK_USERS).find(u => u.email === email);
    if (existing) {
      res.status(400).json({ error: "Email already registered" });
      return;
    }

    const newId = `usr_${Math.random().toString(36).substring(2, 10)}`;
    const newUser: MockUser = {
      id: newId,
      name: name || "Anonymous User",
      age: Number(age) || 0,
      phone: phone || "",
      email: email || "",
      micAccess: !!micAccess,
      termsAccepted: !!termsAccepted,
      privacyPolicyAccepted: !!privacyPolicyAccepted,
      outputPreferences: ["text", "icon", "color"]
    };

    MOCK_USERS[newId] = newUser;
    res.json({
      access_token: `mock-jwt-token-${newId}`,
      token_type: "bearer",
      user_id: newId
    });
  });

  app.post("/api/auth/signin", (req, res) => {
    const { email } = req.body;
    const user = Object.values(MOCK_USERS).find(u => u.email === email);
    if (user) {
      res.json({
        access_token: `mock-jwt-token-${user.id}`,
        token_type: "bearer",
        user_id: user.id
      });
      return;
    }

    // Default fallback to John Doe if unregistered for user test simplicity
    res.json({
      access_token: `mock-jwt-token-usr_123`,
      token_type: "bearer",
      user_id: "usr_123"
    });
  });

  // ==========================================
  // 3. USER PROFILE ENDPOINTS
  // ==========================================
  app.get("/api/users/:id/profile", (req, res) => {
    const user = MOCK_USERS[req.params.id];
    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ error: "Profile not found" });
    }
  });

  app.put("/api/users/:id/profile", (req, res) => {
    const user = MOCK_USERS[req.params.id];
    if (!user) {
      res.status(404).json({ error: "Profile not found" });
      return;
    }

    const { name, age, phone, outputPreferences } = req.body;
    if (name !== undefined) user.name = name;
    if (age !== undefined) user.age = Number(age);
    if (phone !== undefined) user.phone = phone;
    if (outputPreferences !== undefined) user.outputPreferences = outputPreferences;

    res.json(user);
  });

  // ==========================================
  // 4. SOUND EVENTS SYNC ENDPOINTS
  // ==========================================
  app.post("/api/sound-events", (req, res) => {
    const { user_id, label, severity, mode, timestamp } = req.body;
    
    const eventId = `evt_${Math.random().toString(36).substring(2, 10)}`;
    const newEvent: MockEvent = {
      id: eventId,
      user_id: user_id || "usr_123",
      label: label || "Unknown Sound",
      severity: severity || "low",
      mode: mode || "indoor",
      timestamp: timestamp || new Date().toISOString()
    };

    MOCK_EVENTS.push(newEvent);
    res.json(newEvent);
  });

  app.get("/api/sound-events/:user_id", (req, res) => {
    const list = MOCK_EVENTS.filter(e => e.user_id === req.params.user_id);
    // Sort reverse chronological
    list.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
    res.json(list);
  });

  // ==========================================
  // 5. EMERGENCY TELEPHONY STUB
  // ==========================================
  app.post("/api/emergency/contact", (req, res) => {
    const { user_id, message, action_type } = req.body;
    const user = MOCK_USERS[user_id];
    const phone = user ? user.phone : "+15551234567";

    res.json({
      status: "success",
      recipient: phone,
      dispatch_message: message || "Dispatched automated safety warning",
      action_type: action_type || "CALL_EMERGENCY",
      provider_stub: "Twilio SMS Gateway Simulator",
      timestamp: new Date().toISOString()
    });
  });

  // ==========================================
  // VITE DEVELOPMENT OR PRODUCTION SERVING
  // ==========================================
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
  });
}

startServer();
