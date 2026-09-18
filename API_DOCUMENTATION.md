# CarbonWise – REST API Documentation

## Base URL
```
Production: https://api.carbonwise.in
Development: http://localhost:8080
```

## Authentication
All endpoints (except `/api/auth/*`) require a JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

---

## 1. Authentication

### POST `/api/auth/login`
Login with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
  "userId": "uuid-string",
  "role": "CONSUMER",
  "user": {
    "id": "uuid",
    "name": "Muhil A",
    "email": "user@example.com",
    "role": "CONSUMER",
    "isVerified": true
  }
}
```

### POST `/api/auth/register`
Register a new user.

**Request:**
```json
{
  "name": "Muhil A",
  "email": "user@example.com",
  "password": "password123",
  "role": "CONSUMER"
}
```

**Roles:** `CONSUMER`, `CITY_ADMIN`

### POST `/api/auth/verifyOTP`
Verify email with OTP code.

**Request:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

### POST `/api/auth/forgotPassword`
Request password reset email.

### POST `/api/auth/refresh`
Refresh JWT token using refresh token.

---

## 2. Consumer

### GET `/api/consumer/dashboard?userId=<id>`
Get complete dashboard data including live carbon, stats, and recommendations.

**Response:**
```json
{
  "liveCarbon": { "intensity": 145, "solarWindPercent": 45, ... },
  "totalCarbonSaved": 86.1,
  "totalElectricityUsed": 350.0,
  "renewablePercentage": 57.0,
  "activeDevices": 4,
  "bestChargingTime": "10:00 AM - 2:00 PM",
  "bestApplianceTime": "11:00 AM - 1:00 PM"
}
```

### GET `/api/consumer/carbon/live`
Get current live carbon intensity.

**Response:**
```json
{
  "intensity": 145,
  "solarWindPercent": 45,
  "hydroPercent": 12,
  "gasPercent": 28,
  "coalPercent": 15,
  "status": "CLEAN",
  "timestamp": "2026-07-26T11:30:00"
}
```

### GET `/api/consumer/carbon/history?days=30`
Get historical carbon intensity data.

---

## 3. Prediction

### GET `/api/prediction/6h`
6-hour carbon intensity forecast from AI server.

### GET `/api/prediction/12h`
12-hour forecast.

### GET `/api/prediction/24h`
24-hour forecast.

**Response:**
```json
{
  "id": "pred_6h_2026-07-26T11:30:00",
  "predictedAt": "2026-07-26T11:30:00",
  "dataPoints": [
    { "time": "2026-07-26T12:00:00", "predictedIntensity": 120, "confidence": 0.85 },
    ...
  ],
  "bestChargingTime": "10:00 - 14:00",
  "bestApplianceTime": "10:00 - 12:00",
  "recommendation": "Schedule heavy loads during peak solar hours."
}
```

---

## 4. Devices

### POST `/api/device?userId=<id>`
Add a smart device.

**Request:**
```json
{
  "name": "EV Charger",
  "type": "EV_CHARGER",
  "powerRating": 7.4
}
```

**Types:** `SMART_PLUG`, `EV_CHARGER`, `AIR_CONDITIONER`, `WASHING_MACHINE`, `WATER_HEATER`

### GET `/api/device?userId=<id>`
List all devices for a user.

### PUT `/api/device/{id}`
Update device (toggle on/off, rename, etc).

### DELETE `/api/device/{id}`
Delete a device.

---

## 5. Scheduler

### POST `/api/schedule`
Create a schedule (manual or AI-recommended).

**Request:**
```json
{
  "deviceId": "uuid",
  "userId": "uuid",
  "startTime": "2026-07-26T10:00:00",
  "endTime": "2026-07-26T14:00:00",
  "isAiRecommended": true,
  "estimatedCarbonSaving": 2.5
}
```

### GET `/api/schedule?userId=<id>`
List all schedules for a user.

---

## 6. Sensors

### POST `/api/sensor/data`
Post sensor data from IoT devices (no auth required for IoT).

**Request:**
```json
{
  "sensorId": "esp32_sensor_01",
  "co2": 420,
  "pm25": 35,
  "pm10": 52,
  "temperature": 32.5,
  "humidity": 78
}
```

### GET `/api/sensor/live`
Get live sensor data (last 30 minutes).

---

## 7. Reports

### GET `/api/reports/daily?userId=<id>`
Daily carbon report.

### GET `/api/reports/weekly?userId=<id>`
Weekly carbon report.

### GET `/api/reports/monthly?userId=<id>`
Monthly carbon report.

**Response:**
```json
{
  "id": "uuid",
  "totalCarbonUsed": 287.0,
  "totalCarbonSaved": 86.1,
  "totalElectricityUsed": 350.0,
  "renewablePercentage": 57.0,
  "deviceCount": 4,
  "deviceStatistics": [...],
  "pdfUrl": "https://storage.carbonwise.in/reports/daily_2026-07-26.pdf"
}
```

---

## 8. Admin

### GET `/api/admin/users`
List all users (System Admin only).

### GET `/api/admin/cities`
List all cities.

### GET `/api/admin/sensors`
List all sensors.

---

## 9. GIS / Maps

### GET `/api/gis/heatmap/carbon`
Get carbon heatmap data for map overlay.

### GET `/api/gis/sensors`
Get sensor locations for map markers.

### GET `/api/gis/risk-zones`
Get high risk carbon zones.

---

## Error Responses

```json
{
  "timestamp": "2026-07-26T11:30:00",
  "error": "User not found",
  "status": 400
}
```

## Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request / Validation Error |
| 401 | Unauthorized (missing/invalid JWT) |
| 403 | Forbidden (wrong role) |
| 404 | Not Found |
| 500 | Internal Server Error |
