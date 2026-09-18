# CarbonWise Datasets

## Sources
- Tamil Nadu Grid Mix Data (TANGEDCO)
- India Carbon Intensity API (WattTime / electricMap)
- Weather Data (OpenWeatherMap)
- Sensor Data (ESP32 / PMS5003 / MH-Z19B)

## Format
CSV files with columns: timestamp, intensity, solar_wind_percent, hydro_percent, gas_percent, coal_percent, temperature, humidity

## Training Dataset
- `carbon_intensity_hourly.csv` - Hourly carbon intensity data for Tamil Nadu
- `grid_mix_daily.csv` - Daily grid power generation mix
- `sensor_readings.csv` - IoT sensor readings with CO2, PM2.5, PM10
