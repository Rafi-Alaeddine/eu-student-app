// Add this file: backend/src/services/transitAggregatorService.js
// Free-first Transit Aggregator: transport.rest -> TransitLand -> Nominatim -> mock fallback
// This is the same implementation we discussed previously.

const axios = require('axios');
const qs = require('querystring');

class TransitAggregatorService {
  constructor() {
    this.transportRestBase = process.env.TRANSPORT_REST_BASE || 'https://v6.transport.rest';
    this.transitlandBase = process.env.TRANSITLAND_BASE || 'https://transit.land/api/v2/rest';
    this.transitlandKey = process.env.TRANSITLAND_API_KEY || null; // optional
    this.nominatimBase = 'https://nominatim.openstreetmap.org/search';
    this.defaultFallbackCenter = { lat: 48.1351, lon: 11.5820 }; // Munich
  }

  async geocodeCity(city) {
    const params = { q: city, format: 'json', addressdetails: 0, limit: 1 };
    const url = `${this.nominatimBase}?${qs.stringify(params)}`;
    const resp = await axios.get(url, {
      headers: { 'User-Agent': 'denti-transport-backend/1.0 (+https://your.app)' },
      timeout: 8000,
    });
    if (!resp.data || resp.data.length === 0) {
      throw new Error(`Could not geocode city: ${city}`);
    }
    const entry = resp.data[0];
    return { lat: parseFloat(entry.lat), lon: parseFloat(entry.lon) };
  }

  async getStopsForCity(city, mode = 'bus') {
    let center;
    try {
      center = await this.geocodeCity(city);
    } catch (e) {
      center = this.defaultFallbackCenter;
    }

    try {
      const stops = await this._getStopsFromTransportRest(center, mode);
      if (stops && stops.length > 0) return stops;
    } catch (e) {
      console.warn('transport.rest stops fetch failed:', e.message);
    }

    try {
      const stops = await this._getStopsFromTransitLand(center, mode);
      if (stops && stops.length > 0) return stops;
    } catch (e) {
      console.warn('TransitLand stops fetch failed:', e.message);
    }

    return await this._mockStops(city, center);
  }

  async getVehiclesForCity(city, mode = 'bus') {
    let center;
    try {
      center = await this.geocodeCity(city);
    } catch (e) {
      center = this.defaultFallbackCenter;
    }

    // For Phase A: fallback to mock vehicles (positioned near stops)
    const stops = await this.getStopsForCity(city, mode);
    return this._mockVehiclesFromStops(city, mode, stops, center);
  }

  // Implementation helpers below
  async _getStopsFromTransportRest(center, mode) {
    const url = `${this.transportRestBase}/stops`;
    const params = { lat: center.lat, lon: center.lon, distance: 5000 };
    const resp = await axios.get(url, { params, timeout: 8000 });
    if (!resp.data || !Array.isArray(resp.data)) return [];
    const stops = resp.data.map((s) => {
      const coords = (s.geometry && s.geometry.coordinates) || (s.location && [s.location.lon, s.location.lat]) || [null, null];
      const lon = coords[0];
      const lat = coords[1];
      return { id: s.id || `tr:${s.name || Math.random()}`, name: s.name || 'Unknown', lat: Number(lat), lon: Number(lon) };
    }).filter(st => st.lat && st.lon);
    return stops;
  }

  async _getStopsFromTransitLand(center, mode) {
    const params = { lat: center.lat, lon: center.lon, r: 5000, per_page: 100 };
    if (this.transitlandKey) params.api_key = this.transitlandKey;
    const url = `${this.transitlandBase}/stops?${qs.stringify(params)}`;
    const resp = await axios.get(url, { timeout: 10000, headers: { 'User-Agent': 'denti-transport-backend/1.0' } });
    if (!resp.data || !Array.isArray(resp.data.stops)) return [];
    const stops = resp.data.stops.map(s => {
      return {
        id: s.onestop_id || s.id || `tl:${s.name}`,
        name: s.name || s.stop_name || 'Unknown',
        lat: Number(s.geometry && s.geometry.coordinates ? s.geometry.coordinates[1] : (s.latitude || null)),
        lon: Number(s.geometry && s.geometry.coordinates ? s.geometry.coordinates[0] : (s.longitude || null)),
      };
    }).filter(st => st.lat && st.lon);
    return stops;
  }

  async _mockStops(city, center = null) {
    if (!center) center = await this.geocodeCity(city).catch(() => this.defaultFallbackCenter);
    const baseLat = center.lat;
    const baseLon = center.lon;
    const stops = [];
    for (let i = 0; i < 30; i++) {
      const lat = baseLat + (Math.random() - 0.5) * 0.08;
      const lon = baseLon + (Math.random() - 0.5) * 0.08;
      stops.push({ id: `mock-stop-${i}`, name: `${city} Stop ${i + 1}`, lat, lon });
    }
    return stops;
  }

  _mockVehiclesFromStops(city, mode, stops = [], center = null) {
    const vehicles = [];
    if (!stops || stops.length === 0) return this._mockVehicles(city, mode);
    const seed = (city && city.length) || 5;
    const sampleCount = Math.min(12, Math.max(3, Math.floor(stops.length / 3)));
    for (let i = 0; i < sampleCount; i++) {
      const s = stops[(i * 3 + seed) % stops.length];
      const lat = s.lat + (Math.random() - 0.5) * 0.0025;
      const lon = s.lon + (Math.random() - 0.5) * 0.0025;
      vehicles.push({ id: `veh-${mode}-${i}`, lat, lon, bearing: Math.floor(Math.random() * 360), speed: Math.round(Math.random() * 30), route: `R${(i % 10) + 1}`, delay_seconds: Math.round((Math.random() - 0.5) * 120) });
    }
    return vehicles;
  }

  _mockVehicles(city, mode) {
    const vehicles = [];
    const seed = city.length;
    for (let i = 0; i < 10; i++) {
      const lat = 48.1351 + ((i + seed) % 7 - 3) * 0.01 + (Math.random() - 0.5) * 0.005;
      const lon = 11.5820 + ((i + seed) % 5 - 2) * 0.01 + (Math.random() - 0.5) * 0.005;
      vehicles.push({ id: `veh-${mode}-${i}`, lat, lon, bearing: Math.floor(Math.random() * 360), speed: Math.round(Math.random() * 30), route: `R${(i % 10) + 1}`, delay_seconds: Math.round((Math.random() - 0.5) * 120) });
    }
    return vehicles;
  }
}

module.exports = TransitAggregatorService;