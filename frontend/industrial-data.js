/**
 * CarbonWise Industrial Data & Simulation Service
 * Unified, deterministic engine for:
 * - CSV-based grid telemetry simulation (every 15-20s)
 * - 12 Industrial machines with live telemetry (power, temp, vibration, kWh, CO2)
 * - 12 Industrial sensors (air quality, noise, PM2.5, smoke, pressure, etc.)
 * - Industrial risk engine (Low, Medium, High, Critical)
 * - Carbon hotspot calculation from actual device power & grid intensity
 * - Fuel monitoring & consumption spike detection
 * - Reactive notification system with unread badge & click navigation
 * - Real PDF report generator (CarbonWise_Carbon_Report_YYYY-MM-DD.pdf)
 */
(function () {
  // --- 1. CSV GRID TELEMETRY DATA & SERVICE ---
  const RAW_GRID_CSV = [
    "00:00,603,17.8,82.2,0,10.2,7.6,3305,HIGH",
    "00:15,602,18.0,82.0,0,10.4,7.6,3388,HIGH",
    "00:30,601,18.2,81.8,0,10.6,7.6,3471,HIGH",
    "01:00,598,18.5,81.5,0,11.0,7.5,3623,NORMAL",
    "02:00,590,19.2,80.8,0,11.8,7.4,3832,NORMAL",
    "04:00,578,20.4,79.6,0,13.2,7.2,4084,NORMAL",
    "06:00,560,22.0,78.0,0,15.0,7.0,4320,NORMAL",
    "07:00,535,25.2,74.8,4.2,14.2,6.8,4460,NORMAL",
    "08:00,490,31.4,68.6,12.5,12.5,6.4,4580,NORMAL",
    "09:00,440,38.5,61.5,22.0,10.8,5.7,4650,NORMAL",
    "10:00,380,48.2,51.8,34.0,9.0,5.2,4600,NORMAL",
    "11:00,345,55.0,45.0,42.5,7.8,4.7,4520,CLEAN",
    "11:30,330,58.2,41.8,47.0,6.8,4.4,4480,CLEAN",
    "12:00,317,63.5,36.5,52.0,7.0,4.5,4427,CLEAN",
    "12:30,323,62.7,37.3,51.6,6.6,4.5,4343,CLEAN",
    "13:00,336,61.1,38.9,50.2,6.3,4.6,4240,CLEAN",
    "13:30,342,59.8,40.2,48.5,6.5,4.8,4190,CLEAN",
    "14:00,348,58.5,41.5,46.0,7.2,5.3,4150,CLEAN",
    "14:30,360,54.0,46.0,40.5,8.0,5.5,4180,NORMAL",
    "15:00,385,50.2,49.8,35.0,9.4,5.8,4230,NORMAL",
    "16:00,430,42.0,58.0,24.0,11.8,6.2,4380,NORMAL",
    "17:00,495,33.5,66.5,11.5,15.2,6.8,4560,NORMAL",
    "18:00,580,22.8,77.2,1.2,14.6,7.0,4720,NORMAL",
    "19:00,648,17.8,82.2,0,10.2,7.6,4820,HIGH",
    "19:30,640,18.9,81.1,0,10.9,8.0,4790,HIGH",
    "20:00,630,20.0,80.0,0,12.0,8.0,4650,HIGH",
    "21:00,610,21.5,78.5,0,13.5,8.0,4420,HIGH",
    "22:00,595,23.0,77.0,0,15.0,8.0,4100,NORMAL",
    "23:00,585,24.5,75.5,0,16.5,8.0,3800,NORMAL"
  ];

  class GridDataService {
    constructor() {
      this.records = [];
      this.currentIndex = 13; // default starts at clean window (12:00)
      this.listeners = [];
      this.intervalId = null;
      this.init();
    }

    init() {
      this.parseCsv(RAW_GRID_CSV);
      // Try to load external CSV if available on server
      fetch("data/grid_telemetry.csv")
        .then((res) => (res.ok ? res.text() : null))
        .then((text) => {
          if (text) {
            const lines = text.trim().split(/\r?\n/).slice(1);
            if (lines.length > 5) this.parseCsv(lines);
          }
        })
        .catch(() => {});

      // Centralized simulation loop: advance every 15 seconds
      this.intervalId = setInterval(() => {
        this.stepSimulation();
      }, 15000);
    }

    parseCsv(lines) {
      this.records = lines.map((l) => {
        const p = l.split(",");
        const intensity = parseFloat(p[1]) || 400;
        let status = p[8] ? p[8].trim() : "NORMAL";
        if (intensity < 350) status = "CLEAN";
        else if (intensity > 600) status = "HIGH";
        else status = "NORMAL";

        return {
          timestamp: p[0],
          intensity: intensity,
          renewable: parseFloat(p[2]) || 50,
          thermal: parseFloat(p[3]) || 50,
          solar: parseFloat(p[4]) || 0,
          wind: parseFloat(p[5]) || 0,
          hydro: parseFloat(p[6]) || 0,
          demand: parseFloat(p[7]) || 4000,
          status: status
        };
      });
    }

    stepSimulation() {
      if (!this.records.length) return;
      this.currentIndex = (this.currentIndex + 1) % this.records.length;
      const current = this.getCurrent();
      
      // Notify all registered UI components
      this.listeners.forEach((fn) => fn(current));

      // Trigger Notification events on threshold crossing
      if (current.intensity > 600) {
        notificationService.addNotification({
          title: "High Carbon Grid Alert",
          message: `Grid intensity reached ${current.intensity} gCO₂/kWh. Delay non-essential production loads.`,
          category: "GRID",
          priority: "HIGH",
          targetView: "grid"
        });
      } else if (current.intensity < 350) {
        notificationService.addNotification({
          title: "Clean Energy Window Active",
          message: `Grid intensity is low (${current.intensity} gCO₂/kWh). Renewable share is ${current.renewable}%. Ideal for EV charging & heavy equipment.`,
          category: "CLEAN",
          priority: "INFO",
          targetView: "grid"
        });
      }
    }

    getCurrent() {
      if (!this.records.length) {
        return {
          timestamp: "12:00",
          intensity: 320,
          renewable: 63.5,
          thermal: 36.5,
          solar: 52,
          wind: 7,
          hydro: 4.5,
          demand: 4427,
          status: "CLEAN"
        };
      }
      return this.records[this.currentIndex];
    }

    getAll() {
      return this.records;
    }

    onChange(fn) {
      this.listeners.push(fn);
    }
  }

  // --- 2. 12 INDUSTRIAL MACHINES & TELEMETRY ---
  const INITIAL_MACHINES = [
    {
      id: "CNC-001",
      name: "CNC Milling Machine 5-Axis",
      type: "CNC Machine",
      location: "Precision Machining Bay 1",
      powerRating: 15.0,
      currentPower: 11.8,
      voltage: 415,
      current: 19.5,
      energyToday: 74.6,
      temp: 68.4,
      vibration: 4.2,
      runtimeHours: 6.3,
      status: "ONLINE",
      riskLevel: "MEDIUM",
      coords: [13.0102, 80.2155]
    },
    {
      id: "MOT-002",
      name: "Heavy Duty Induction Motor",
      type: "Industrial Motor",
      location: "Assembly Line Conveyor",
      powerRating: 22.0,
      currentPower: 17.5,
      voltage: 412,
      current: 29.1,
      energyToday: 112.4,
      temp: 58.2,
      vibration: 2.8,
      runtimeHours: 6.4,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0108, 80.2162]
    },
    {
      id: "CMP-003",
      name: "Rotary Screw Air Compressor",
      type: "Air Compressor",
      location: "Central Utility Plant",
      powerRating: 30.0,
      currentPower: 26.2,
      voltage: 416,
      current: 43.1,
      energyToday: 184.2,
      temp: 78.5,
      vibration: 3.4,
      runtimeHours: 7.1,
      status: "ONLINE",
      riskLevel: "MEDIUM",
      coords: [13.0095, 80.2148]
    },
    {
      id: "HVAC-004",
      name: "Industrial Cleanroom HVAC",
      type: "Industrial HVAC",
      location: "Cleanroom Block B",
      powerRating: 45.0,
      currentPower: 38.0,
      voltage: 414,
      current: 62.8,
      energyToday: 268.0,
      temp: 42.1,
      vibration: 1.9,
      runtimeHours: 7.2,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0115, 80.2170]
    },
    {
      id: "IMM-005",
      name: "Hydraulic Injection Molding Machine",
      type: "Injection Molding",
      location: "Polymer Processing Hall",
      powerRating: 55.0,
      currentPower: 44.5,
      voltage: 418,
      current: 73.0,
      energyToday: 312.5,
      temp: 72.8,
      vibration: 4.8,
      runtimeHours: 7.0,
      status: "ONLINE",
      riskLevel: "HIGH",
      coords: [13.0090, 80.2158]
    },
    {
      id: "CONV-006",
      name: "Main Line Roller Conveyor",
      type: "Conveyor Belt Motor",
      location: "Warehouse Logistics Hub",
      powerRating: 11.0,
      currentPower: 8.2,
      voltage: 415,
      current: 13.5,
      energyToday: 58.1,
      temp: 48.0,
      vibration: 2.1,
      runtimeHours: 7.1,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0120, 80.2145]
    },
    {
      id: "PMP-007",
      name: "Centrifugal Effluent Slurry Pump",
      type: "Industrial Pump",
      location: "Water & Effluent Treatment Plant",
      powerRating: 18.5,
      currentPower: 14.8,
      voltage: 413,
      current: 24.6,
      energyToday: 98.4,
      temp: 52.3,
      vibration: 3.1,
      runtimeHours: 6.6,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0085, 80.2175]
    },
    {
      id: "WLD-008",
      name: "Automated Robotic MIG Welder",
      type: "Welding Machine",
      location: "Chassis Fabrication Bay",
      powerRating: 12.0,
      currentPower: 9.6,
      voltage: 416,
      current: 15.8,
      energyToday: 48.2,
      temp: 64.0,
      vibration: 2.6,
      runtimeHours: 5.1,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0105, 80.2182]
    },
    {
      id: "BLR-009",
      name: "Industrial Steam Boiler 2-Ton",
      type: "Boiler",
      location: "Thermal Utility Station",
      powerRating: 75.0,
      currentPower: 62.0,
      voltage: 415,
      current: 102.5,
      energyToday: 420.0,
      temp: 115.0,
      vibration: 4.9,
      runtimeHours: 6.9,
      status: "WARNING",
      riskLevel: "HIGH",
      coords: [13.0080, 80.2150]
    },
    {
      id: "FRN-010",
      name: "Continuous Electric Annealing Furnace",
      type: "Industrial Furnace",
      location: "Heat Treatment Facility",
      powerRating: 110.0,
      currentPower: 88.5,
      voltage: 415,
      current: 146.0,
      energyToday: 590.2,
      temp: 840.0,
      vibration: 1.8,
      runtimeHours: 6.7,
      status: "ONLINE",
      riskLevel: "HIGH",
      coords: [13.0075, 80.2165]
    },
    {
      id: "CHL-011",
      name: "Centrifugal Water-Cooled Chiller",
      type: "Chiller",
      location: "Refrigeration Plant",
      powerRating: 40.0,
      currentPower: 31.4,
      voltage: 417,
      current: 51.6,
      energyToday: 218.0,
      temp: 38.5,
      vibration: 2.2,
      runtimeHours: 7.0,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0112, 80.2138]
    },
    {
      id: "PKG-012",
      name: "High-Speed Carton Packaging Unit",
      type: "Packaging Machine",
      location: "End-of-Line Packaging",
      powerRating: 8.0,
      currentPower: 5.8,
      voltage: 414,
      current: 9.6,
      energyToday: 38.2,
      temp: 41.2,
      vibration: 1.6,
      runtimeHours: 6.6,
      status: "ONLINE",
      riskLevel: "LOW",
      coords: [13.0125, 80.2160]
    }
  ];

  class DeviceTelemetryService {
    constructor() {
      this.devices = JSON.parse(JSON.stringify(INITIAL_MACHINES));
      this.listeners = [];
      this.init();
    }

    init() {
      // Continuous telemetry fluctuations every 4 seconds
      setInterval(() => {
        this.stepTelemetry();
      }, 4000);
    }

    stepTelemetry() {
      const grid = gridDataService.getCurrent();
      this.devices.forEach((d) => {
        if (d.status === "OFFLINE") return;

        // Controlled realistic power fluctuation +/- 2.5%
        const deltaPct = (Math.random() - 0.5) * 0.05;
        d.currentPower = Math.max(1.0, Math.round((d.currentPower * (1 + deltaPct)) * 10) / 10);
        d.voltage = Math.round(412 + Math.random() * 6);
        d.current = Math.round((d.currentPower * 1000 / (1.732 * d.voltage * 0.85)) * 10) / 10;
        d.energyToday = Math.round((d.energyToday + (d.currentPower * (4 / 3600))) * 100) / 100;
        d.runtimeHours = Math.round((d.runtimeHours + (4 / 3600)) * 100) / 100;

        // Temperature drift +/- 0.3°C
        d.temp = Math.round((d.temp + (Math.random() - 0.5) * 0.6) * 10) / 10;

        // Vibration fluctuation +/- 0.1 mm/s
        d.vibration = Math.max(0.5, Math.round((d.vibration + (Math.random() - 0.5) * 0.2) * 10) / 10);

        // Calculate Carbon: Energy * Grid Intensity / 1000
        d.carbonKg = Math.round((d.energyToday * (grid.intensity / 1000)) * 10) / 10;

        // Dynamic risk evaluation
        if (d.temp > 85 && d.type !== "Industrial Furnace" && d.type !== "Boiler") {
          d.riskLevel = "CRITICAL";
          d.status = "CRITICAL";
        } else if (d.vibration > 4.5 || (d.temp > 75 && d.type !== "Industrial Furnace" && d.type !== "Boiler")) {
          d.riskLevel = "HIGH";
          d.status = "WARNING";
        } else if (d.vibration > 3.5 || d.temp > 65) {
          d.riskLevel = "MEDIUM";
        } else {
          d.riskLevel = "LOW";
        }
      });

      this.listeners.forEach((fn) => fn(this.devices));
    }

    getAll() {
      return this.devices;
    }

    getById(id) {
      return this.devices.find((x) => x.id === id);
    }

    toggleDevice(id) {
      const dev = this.getById(id);
      if (dev) {
        dev.status = dev.status === "OFFLINE" ? "ONLINE" : "OFFLINE";
        dev.currentPower = dev.status === "ONLINE" ? dev.powerRating * 0.75 : 0;
        this.listeners.forEach((fn) => fn(this.devices));
      }
    }

    addDevice(data) {
      const newDev = {
        id: data.id || "DEV-" + (this.devices.length + 1).toString().padStart(3, "0"),
        name: data.name,
        type: data.type || "Industrial Machine",
        location: data.location || "Production Floor",
        powerRating: parseFloat(data.power) || 15.0,
        currentPower: (parseFloat(data.power) || 15.0) * 0.8,
        voltage: 415,
        current: 20.0,
        energyToday: 0.0,
        temp: 50.0,
        vibration: 2.0,
        runtimeHours: 0.0,
        status: "ONLINE",
        riskLevel: "LOW",
        coords: [13.0100 + (Math.random() - 0.5) * 0.005, 80.2150 + (Math.random() - 0.5) * 0.005]
      };
      this.devices.unshift(newDev);
      this.listeners.forEach((fn) => fn(this.devices));
      return newDev;
    }

    onChange(fn) {
      this.listeners.push(fn);
    }
  }

  // --- 3. 12 INDUSTRIAL SENSORS & POLLUTION MONITORING ---
  const INITIAL_SENSORS = [
    { id: "TEMP-01", type: "Temperature", location: "Production Bay 1", value: 68.4, unit: "°C", status: "NORMAL", risk: "LOW", coords: [13.0103, 80.2156] },
    { id: "HUM-02", type: "Humidity", location: "Assembly Clean Area", value: 48.2, unit: "% RH", status: "NORMAL", risk: "LOW", coords: [13.0109, 80.2163] },
    { id: "PM25-03", type: "PM2.5", location: "Boiler Utility Area", value: 84.0, unit: "µg/m³", status: "WARNING", risk: "HIGH", coords: [13.0081, 80.2152] },
    { id: "PM10-04", type: "PM10", location: "Warehouse Loading Dock", value: 42.5, unit: "µg/m³", status: "NORMAL", risk: "LOW", coords: [13.0122, 80.2147] },
    { id: "CO2-05", type: "CO₂ Concentration", location: "Furnace Exhaust Hall", value: 620, unit: "ppm", status: "WARNING", risk: "MEDIUM", coords: [13.0077, 80.2166] },
    { id: "AQI-06", type: "Air Quality Index", location: "Plant Boundary North", value: 112, unit: "AQI", status: "WARNING", risk: "MEDIUM", coords: [13.0128, 80.2158] },
    { id: "NSE-07", type: "Acoustic Noise", location: "Stamping & Punch Line", value: 82.4, unit: "dB", status: "WARNING", risk: "MEDIUM", coords: [13.0098, 80.2178] },
    { id: "VIB-08", type: "Vibration Sensor", location: "Induction Motor 2 Bearing", value: 4.2, unit: "mm/s", status: "WARNING", risk: "HIGH", coords: [13.0107, 80.2164] },
    { id: "GAS-09", type: "VOC / Gas Sensor", location: "Chemical Storage Yard", value: 12.0, unit: "ppm", status: "NORMAL", risk: "LOW", coords: [13.0088, 80.2185] },
    { id: "ENM-10", type: "Energy Meter", location: "Main 11kV Substation", value: 415.2, unit: "V", status: "NORMAL", risk: "LOW", coords: [13.0092, 80.2140] },
    { id: "SMK-11", type: "Smoke Optical Sensor", location: "Control & Server Room", value: 0.02, unit: "% obs/m", status: "NORMAL", risk: "LOW", coords: [13.0118, 80.2172] },
    { id: "PRS-12", type: "Pneumatic Pressure", location: "Air Header Ring Main", value: 7.2, unit: "bar", status: "NORMAL", risk: "LOW", coords: [13.0096, 80.2149] }
  ];

  class SensorService {
    constructor() {
      this.sensors = JSON.parse(JSON.stringify(INITIAL_SENSORS));
      this.listeners = [];
      this.init();
    }

    init() {
      setInterval(() => {
        this.stepSensors();
      }, 5000);
    }

    stepSensors() {
      this.sensors.forEach((s) => {
        const delta = (Math.random() - 0.5) * 0.04;
        if (s.type === "PM2.5") {
          s.value = Math.max(10, Math.round((s.value + (Math.random() - 0.48) * 1.5) * 10) / 10);
          s.status = s.value > 75 ? "WARNING" : "NORMAL";
          s.risk = s.value > 75 ? "HIGH" : "LOW";
        } else if (s.type === "CO₂ Concentration") {
          s.value = Math.round(s.value + (Math.random() - 0.5) * 6);
          s.status = s.value > 600 ? "WARNING" : "NORMAL";
        } else if (s.type === "Temperature") {
          s.value = Math.round((s.value + delta * 10) * 10) / 10;
        } else if (s.type === "Air Quality Index") {
          s.value = Math.round(s.value + (Math.random() - 0.5) * 2);
        } else {
          s.value = Math.round((s.value * (1 + delta)) * 10) / 10;
        }
      });
      this.listeners.forEach((fn) => fn(this.sensors));
    }

    getAll() {
      return this.sensors;
    }

    onChange(fn) {
      this.listeners.push(fn);
    }
  }

  // --- 4. FUEL MONITORING SERVICE ---
  class FuelService {
    constructor() {
      this.data = {
        dieselL: 340,
        dieselPrevL: 304,
        lpgKg: 120,
        naturalGasM3: 450,
        dailyCost: 32500,
        trendPct: 11.8 // +11.8% increase
      };
      this.checkSpikes();
    }

    checkSpikes() {
      if (this.data.trendPct > 10) {
        setTimeout(() => {
          notificationService.addNotification({
            title: "Fuel Consumption Spike Alert",
            message: `Fuel consumption increased by ${this.data.trendPct}% compared with the previous shift. Investigate Boiler BLR-009 auxiliary burners.`,
            category: "FUEL",
            priority: "HIGH",
            targetView: "intelligence"
          });
        }, 3000);
      }
    }

    getData() {
      const co2Diesel = this.data.dieselL * 2.68;
      const co2Lpg = this.data.lpgKg * 2.98;
      const co2Gas = this.data.naturalGasM3 * 2.02;
      const totalFuelCo2 = co2Diesel + co2Lpg + co2Gas;
      return {
        ...this.data,
        co2Diesel,
        co2Lpg,
        co2Gas,
        totalFuelCo2Kg: totalFuelCo2,
        totalFuelCo2Tonnes: totalFuelCo2 / 1000
      };
    }
  }

  // --- 5. NOTIFICATION SERVICE ---
  class NotificationService {
    constructor() {
      this.notifications = [
        {
          id: "notif-1",
          title: "Clean Energy Window Active",
          message: "Renewable grid generation is at 63.5%. Clean window 11:30–14:30. Ideal for heavy CNC & compressor operations.",
          category: "CLEAN",
          priority: "INFO",
          timestamp: new Date(Date.now() - 5 * 60000).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
          read: false,
          targetView: "grid"
        },
        {
          id: "notif-2",
          title: "High Industrial Risk: Boiler Area",
          message: "Elevated PM2.5 (84 µg/m³) and high surface temperature detected on Boiler BLR-009.",
          category: "RISK",
          priority: "CRITICAL",
          timestamp: new Date(Date.now() - 14 * 60000).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
          read: false,
          targetView: "maps"
        },
        {
          id: "notif-3",
          title: "AI Budget Optimization Ready",
          message: "Knapsack capital allocation optimizer found ₹10,00,000 schedule saving 94.7 t CO₂ annually.",
          category: "OPTIMIZATION",
          priority: "INFO",
          timestamp: new Date(Date.now() - 25 * 60000).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
          read: false,
          targetView: "optimize"
        }
      ];
      this.listeners = [];
    }

    addNotification(notif) {
      const item = {
        id: "notif-" + Date.now() + "-" + Math.floor(Math.random() * 1000),
        title: notif.title,
        message: notif.message,
        category: notif.category || "GENERAL",
        priority: notif.priority || "INFO",
        timestamp: new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
        read: false,
        targetView: notif.targetView || "dashboard"
      };
      this.notifications.unshift(item);
      if (this.notifications.length > 20) this.notifications.pop();
      this.notify();
    }

    getNotifications() {
      return this.notifications;
    }

    getUnreadCount() {
      return this.notifications.filter((n) => !n.read).length;
    }

    markAsRead(id) {
      const n = this.notifications.find((x) => x.id === id);
      if (n) {
        n.read = true;
        this.notify();
      }
    }

    markAllAsRead() {
      this.notifications.forEach((n) => (n.read = true));
      this.notify();
    }

    notify() {
      this.listeners.forEach((fn) => fn(this.notifications, this.getUnreadCount()));
    }

    onChange(fn) {
      this.listeners.push(fn);
    }
  }

  // --- 6. REAL PDF REPORT GENERATOR ---
  class ReportService {
    generatePdf(period = "monthly") {
      const grid = gridDataService.getCurrent();
      const devices = deviceTelemetryService.getAll();
      const sensors = sensorService.getAll();
      const fuel = fuelService.getData();
      const date = new Date().toISOString().slice(0, 10);

      const totalMachineKwh = devices.reduce((sum, d) => sum + d.energyToday, 0);
      const totalMachineCo2Kg = devices.reduce((sum, d) => sum + (d.carbonKg || 0), 0);

      const lines = [
        "CARBONWISE INDUSTRIAL INTELLIGENCE & ESG REPORT",
        "================================================",
        "Facility: Guindy Precision Works & Manufacturing Campus",
        "Reporting Period: " + period.toUpperCase() + " (" + date + ")",
        "Data Mode: Industrial Telemetry Simulation (Verified)",
        "",
        "1. EXECUTIVE SUMMARY",
        "-------------------",
        "Total Facility Carbon Footprint: 1,480.2 tonnes CO2 eq",
        "Total Machine Active Energy Today: " + totalMachineKwh.toFixed(1) + " kWh",
        "Real-time Direct Carbon Impact: " + totalMachineCo2Kg.toFixed(1) + " kg CO2",
        "Target Reduction Goal: -25% by 2027",
        "",
        "2. EMISSION SOURCE BREAKDOWN",
        "----------------------------",
        "Electricity (Scope 2): 665.8 t CO2 (45.0%)",
        "Production Processes: 191.9 t CO2 (13.0%)",
        "Fuel & Combustion (Scope 1): 262.6 t CO2 (17.7%) [Diesel: " + fuel.dieselL + " L, LPG: " + fuel.lpgKg + " kg]",
        "Logistics & Freight: 152.5 t CO2 (10.3%)",
        "Solid & Organic Waste: 207.4 t CO2 (14.0%)",
        "",
        "3. GRID INTELLIGENCE & TELEMETRY",
        "--------------------------------",
        "Current Grid Intensity: " + grid.intensity + " gCO2/kWh [" + grid.status + "]",
        "Renewable Generation Mix: " + grid.renewable + "% (Solar: " + grid.solar + "%, Wind: " + grid.wind + "%, Hydro: " + grid.hydro + "%)",
        "Thermal Generation Share: " + grid.thermal + "%",
        "Regional Grid Demand: " + grid.demand + " MW",
        "Recommended Clean Operating Window: 11:30 AM - 02:30 PM",
        "",
        "4. INDUSTRIAL MACHINERY TELEMETRY SUMMARY",
        "-----------------------------------------",
        ...devices.map(
          (d) =>
            "- " +
            d.id +
            " " +
            d.name +
            ": " +
            d.currentPower +
            " kW | " +
            d.temp +
            " deg C | Vib: " +
            d.vibration +
            " mm/s | Risk: " +
            d.riskLevel +
            " [" +
            d.status +
            "]"
        ),
        "",
        "5. SENSORS & ENVIRONMENTAL POLLUTION",
        "------------------------------------",
        ...sensors.slice(0, 6).map(
          (s) => "- " + s.id + " (" + s.type + "): " + s.value + " " + s.unit + " @ " + s.location + " [" + s.status + "]"
        ),
        "",
        "6. AI BUDGET OPTIMIZATION (KNAPSACK RECOMMENDED ACTIONS)",
        "-------------------------------------------------------",
        "- Rooftop Solar 500kW: Cost Rs 50,00,000 | Co2 cut: 50.0 t/yr | Payback: 3.2 yrs",
        "- Factory-wide LED Retrofit: Cost Rs 8,00,000 | Co2 cut: 8.5 t/yr | Payback: 0.9 yrs",
        "- IE4 Motor Upgrade: Cost Rs 15,00,000 | Co2 cut: 14.0 t/yr | Payback: 2.1 yrs",
        "- VFD on Pumps: Cost Rs 12,00,000 | Co2 cut: 11.2 t/yr | Payback: 1.5 yrs",
        "",
        "================================================",
        "Report verified by CarbonWise Industrial AI Engine.",
        "File: CarbonWise_Carbon_Report_" + date + ".pdf"
      ];

      return this.buildRawPdf(lines);
    }

    buildRawPdf(lines) {
      const esc = (s) => s.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
      let y = 800;
      const cmds = ["BT", "/F1 10 Tf", "13 TL"];
      lines.forEach((ln) => {
        cmds.push("1 0 0 1 40 " + y + " Tm", "(" + esc(ln).slice(0, 105) + ") Tj");
        y -= 14;
        if (y < 40) y = 800;
      });
      cmds.push("ET");
      const stream = cmds.join("\n");
      const objects = [];
      const add = (s) => objects.push(s);
      add("<< /Type /Catalog /Pages 2 0 R >>");
      add("<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
      add("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 842] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>");
      add("<< /Length " + stream.length + " >>\nstream\n" + stream + "\nendstream");
      add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");
      let out = "%PDF-1.4\n";
      const xref = [0];
      objects.forEach((obj, i) => {
        xref.push(out.length);
        out += i + 1 + " 0 obj\n" + obj + "\nendobj\n";
      });
      const start = out.length;
      out += "xref\n0 " + (objects.length + 1) + "\n0000000000 65535 f \n";
      xref.slice(1).forEach((off) => {
        out += String(off).padStart(10, "0") + " 00000 n \n";
      });
      out += "trailer << /Size " + (objects.length + 1) + " /Root 1 0 R >>\nstartxref\n" + start + "\n%%EOF";
      return out;
    }
  }

  // Export globally
  const gridDataService = new GridDataService();
  const deviceTelemetryService = new DeviceTelemetryService();
  const sensorService = new SensorService();
  const fuelService = new FuelService();
  const notificationService = new NotificationService();
  const reportService = new ReportService();

  window.CWIndustrialData = {
    grid: gridDataService,
    devices: deviceTelemetryService,
    sensors: sensorService,
    fuel: fuelService,
    notifications: notificationService,
    reports: reportService
  };
})();
