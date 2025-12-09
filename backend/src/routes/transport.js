// src/routes/transport.js
// Uses TransitAggregatorService (free-first) and returns the same simple mobile contract.

const express = require('express');
const Joi = require('joi');
const NodeCache = require('node-cache');

const requireApiKey = require('../middleware/auth');
const TransitAggregatorService = require('../services/transitAggregatorService');

const router = express.Router();
const cacheTTL = parseInt(process.env.CACHE_TTL || '300', 10);
const cache = new NodeCache({ stdTTL: cacheTTL, checkperiod: Math.max(60, Math.floor(cacheTTL / 2)) });

const aggregator = new TransitAggregatorService();

// Validate query params schema for the endpoints
const stopsSchema = Joi.object({
  city: Joi.string().min(2).required(),
  mode: Joi.string().valid('bus','metro','tram','sbahn','bikeshare','taxi').default('bus'),
});

// GET /v1/stops?city=Munich&mode=bus
router.get('/stops', requireApiKey, async (req, res, next) => {
  try {
    const { error, value } = stopsSchema.validate(req.query);
    if (error) return res.status(400).json({ error: error.message });

    const city = value.city;
    const mode = value.mode;

    const cacheKey = `stops:${city.toLowerCase()}:${mode}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ source: 'cache', stops: cached });
    }

    // Use TransitAggregatorService to discover stops (transport.rest -> TransitLand -> mock)
    const stops = await aggregator.getStopsForCity(city, mode);
    cache.set(cacheKey, stops);
    return res.json({ source: 'transit_aggregator', stops });
  } catch (err) {
    next(err);
  }
});

// GET /v1/vehicles?city=Munich&mode=bus
router.get('/vehicles', requireApiKey, async (req, res, next) => {
  try {
    const { error, value } = stopsSchema.validate(req.query);
    if (error) return res.status(400).json({ error: error.message });

    const city = value.city;
    const mode = value.mode;

    const cacheKey = `vehicles:${city.toLowerCase()}:${mode}`;
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ source: 'cache', vehicles: cached });
    }

    // Use aggregator to fetch live-ish vehicles (mock when realtime not available)
    const vehicles = await aggregator.getVehiclesForCity(city, mode);
    // Vehicles must be fresh — short TTL
    cache.set(cacheKey, vehicles, 10);
    return res.json({ source: 'transit_aggregator', vehicles });
  } catch (err) {
    next(err);
  }
});

module.exports = router;