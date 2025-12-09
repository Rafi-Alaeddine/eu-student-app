// src/index.js
require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const morgan = require('morgan');

const transportRouter = require('./routes/transport');

// Basic config / env
const PORT = process.env.PORT || 8000;
const ALLOWED_ORIGINS = (process.env.ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);

const app = express();
app.use(helmet());
app.use(express.json({ limit: '1mb' }));
app.use(morgan('combined'));

// CORS: restrict to allowed origins if provided, otherwise allow all (development)
if (ALLOWED_ORIGINS.length > 0) {
  app.use(cors({
    origin: function (origin, callback) {
      // allow non-browser clients like curl (origin == undefined)
      if (!origin) return callback(null, true);
      if (ALLOWED_ORIGINS.indexOf(origin) !== -1) {
        callback(null, true);
      } else {
        callback(new Error('CORS policy: Origin not allowed'));
      }
    }
  }));
} else {
  app.use(cors());
}

// Global rate limiting (protects your backend)
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 120, // limit each IP to 120 requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(limiter);

// Routes
app.use('/v1', transportRouter);

// Basic health
app.get('/health', (req, res) => res.json({ status: 'ok' }));

// Error handler (simple)
app.use((err, req, res, next) => {
  console.error(err && err.stack ? err.stack : err);
  res.status(500).json({ error: err.message || 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Transport backend listening on port ${PORT}`);
});