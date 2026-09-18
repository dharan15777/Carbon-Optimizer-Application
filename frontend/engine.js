/**
 * CarbonWise Industrial — carbon calculation, grid forecast, knapsack optimizer.
 * All emission factors live here (never scattered in UI).
 */
window.CWEngine = (function () {
  const FACTORS = {
    electricity: { unit: "kWh", kgPerUnit: 0.82, label: "Grid electricity" },
    diesel: { unit: "L", kgPerUnit: 2.68, label: "Diesel" },
    petrol: { unit: "L", kgPerUnit: 2.31, label: "Petrol" },
    lpg: { unit: "kg", kgPerUnit: 2.98, label: "LPG" },
    naturalGas: { unit: "m³", kgPerUnit: 2.02, label: "Natural gas" },
    logisticsKm: { unit: "km", kgPerUnit: 0.21, label: "Road logistics" },
    productionKwh: { unit: "kWh", kgPerUnit: 0.82, label: "Production energy" },
    wasteSolid: { unit: "t", kgPerUnit: 467, label: "Solid waste" },
    wasteOrganic: { unit: "t", kgPerUnit: 580, label: "Organic waste" }
  };

  function co2(activity, factorKey) {
    const f = FACTORS[factorKey];
    if (!f) return 0;
    return activity * f.kgPerUnit;
  }

  const activities = {
    electricityKwh: 812000,
    dieselL: 98000,
    logisticsKm: 186000,
    productionKwh: 234000,
    wasteT: 112
  };

  function footprintKg() {
    const electricity = co2(activities.electricityKwh, "electricity");
    const fuel = co2(activities.dieselL, "diesel");
    const logistics = co2(activities.logisticsKm, "logisticsKm");
    const production = co2(activities.productionKwh, "productionKwh");
    const waste = co2(activities.wasteT, "wasteSolid");
    const total = electricity + fuel + logistics + production + waste;
    return {
      electricity, fuel, logistics, production, waste, total,
      tonnes: total / 1000,
      sources: [
        { id: "electricity", name: "Electricity", kg: electricity, pct: electricity / total },
        { id: "fuel", name: "Fuel", kg: fuel, pct: fuel / total },
        { id: "production", name: "Production", kg: production, pct: production / total },
        { id: "logistics", name: "Logistics", kg: logistics, pct: logistics / total },
        { id: "waste", name: "Waste", kg: waste, pct: waste / total }
      ]
    };
  }

  const hotspots = [
    { name: "Production Line A", t: 324, trend: 6.2, severity: "high", action: "Shift 2nd shift to 14:00–17:00 clean window" },
    { name: "Industrial Furnace", t: 216, trend: 2.1, severity: "high", action: "Furnace idle-setback + refractory audit" },
    { name: "HVAC Plant", t: 143, trend: -1.4, severity: "medium", action: "Optimize chiller setpoints vs outdoor wet-bulb" },
    { name: "Diesel Generator", t: 97, trend: 11.0, severity: "high", action: "Reduce DG runtime; prefer grid during clean hours" },
    { name: "Logistics Fleet", t: 76, trend: -3.2, severity: "medium", action: "Consolidate afternoon dispatches" }
  ];

  const reductionActions = [
    { id: "solar", name: "Solar Installation", category: "Renewable", cost: 500000, co2: 50, weeks: 26, priority: 9, difficulty: "High", source: "Electricity", why: "Highest CO₂ per rupee among capex options at this site irradiance." },
    { id: "led", name: "LED Upgrade", category: "Efficiency", cost: 80000, co2: 8.5, weeks: 3, priority: 8, difficulty: "Low", source: "Electricity", why: "Fast payback, low disruption, immediate lighting load cut." },
    { id: "motor", name: "Motor Efficiency Upgrade", category: "Equipment", cost: 150000, co2: 14, weeks: 8, priority: 8, difficulty: "Medium", source: "Production", why: "Line A motors run 18h/day; IE4 swap cuts continuous kW." },
    { id: "hvac", name: "HVAC Optimization", category: "Operations", cost: 95000, co2: 9.2, weeks: 4, priority: 7, difficulty: "Low", source: "Electricity", why: "Controls + VFDs without full plant replacement." },
    { id: "ev", name: "EV Fleet Transition", category: "Logistics", cost: 210000, co2: 9.9, weeks: 20, priority: 6, difficulty: "Medium", source: "Logistics", why: "Diesel km are a material hotspot; EV pairs with solar." },
    { id: "transport", name: "Transport Optimization", category: "Logistics", cost: 45000, co2: 4.1, weeks: 2, priority: 7, difficulty: "Low", source: "Logistics", why: "Routing + load factor; zero hardware." },
    { id: "re", name: "Renewable Electricity (PPA)", category: "Renewable", cost: 180000, co2: 22, weeks: 12, priority: 8, difficulty: "Medium", source: "Electricity", why: "Grid mix is coal-heavy evenings; green PPA hedges intensity." },
    { id: "schedule", name: "Production Scheduling", category: "Operations", cost: 35000, co2: 6.4, weeks: 2, priority: 9, difficulty: "Low", source: "Production", why: "Moves flexible load into predicted clean windows." },
    { id: "equip", name: "Energy-efficient machinery", category: "Equipment", cost: 320000, co2: 18, weeks: 28, priority: 5, difficulty: "High", source: "Production", why: "High reduction but long payback vs solar+motors." },
    { id: "behavior", name: "Behavioral optimization", category: "People", cost: 18000, co2: 2.8, weeks: 1, priority: 6, difficulty: "Low", source: "Electricity", why: "Shutdown SOP and compressed-air leak program." },
    { id: "waste", name: "Waste segregation & composting", category: "Waste", cost: 42000, co2: 3.6, weeks: 6, priority: 4, difficulty: "Low", source: "Waste", why: "Cuts landfill methane from organic fraction." }
  ];

  /** 0/1 knapsack: maximize CO₂ (t/year) subject to cost <= budget. */
  function optimize(budget) {
    const items = reductionActions;
    const n = items.length;
    const scale = 1000;
    const W = Math.floor(budget / scale);
    const dp = Array.from({ length: n + 1 }, () => new Float64Array(W + 1));
    const keep = Array.from({ length: n + 1 }, () => new Uint8Array(W + 1));
    for (let i = 1; i <= n; i++) {
      const w = Math.floor(items[i - 1].cost / scale);
      const v = items[i - 1].co2;
      for (let c = 0; c <= W; c++) {
        dp[i][c] = dp[i - 1][c];
        if (w <= c && dp[i - 1][c - w] + v > dp[i][c]) {
          dp[i][c] = dp[i - 1][c - w] + v;
          keep[i][c] = 1;
        }
      }
    }
    const selected = [];
    let c = W;
    for (let i = n; i >= 1; i--) {
      if (keep[i][c]) {
        selected.push(items[i - 1]);
        c -= Math.floor(items[i - 1].cost / scale);
      }
    }
    selected.sort((a, b) => b.co2 / b.cost - a.co2 / a.cost);
    const invested = selected.reduce((s, a) => s + a.cost, 0);
    const reduced = selected.reduce((s, a) => s + a.co2, 0);
    return {
      budget,
      invested,
      remaining: budget - invested,
      reduced,
      efficiency: invested ? (reduced * 1000) / (invested / 1000) : 0,
      selected
    };
  }

  function forecast(hours, current = 412) {
    const points = [];
    const now = new Date();
    now.setMinutes(0, 0, 0);
    for (let i = 0; i < hours; i++) {
      const t = new Date(now.getTime() + i * 3600000);
      const h = t.getHours();
      let v = current;
      if (h >= 11 && h <= 16) v = 260 + (h - 14) * (h - 14) * 8;
      else if (h >= 18 && h <= 22) v = 480 + (h - 20) * 12;
      else if (h >= 2 && h <= 6) v = 340;
      else v = 390;
      v += Math.sin(i / 2) * 8;
      points.push({ t, hour: h, intensity: Math.round(v) });
    }
    const min = points.reduce((a, p) => (p.intensity < a.intensity ? p : a), points[0]);
    const max = points.reduce((a, p) => (p.intensity > a.intensity ? p : a), points[0]);
    const clean = points.filter((p) => p.intensity < 320);
    const start = clean[0];
    const end = clean[clean.length - 1];
    return {
      current,
      points,
      predictedLow: min.intensity,
      peak: max.intensity,
      confidence: 0.87,
      cleanWindow: start && end ? { from: start.t, to: end.t, reductionKg: 18.4 } : null
    };
  }

  function mixForHour(h) {
    if (h >= 11 && h <= 16) return { solar: 42, hydro: 14, gas: 22, coal: 18, other: 4 };
    if (h >= 18 && h <= 22) return { solar: 6, hydro: 10, gas: 28, coal: 48, other: 8 };
    return { solar: 18, hydro: 16, gas: 26, coal: 32, other: 8 };
  }

  function roadmap(selected) {
    const now = [], near = [], long = [];
    selected.forEach((a) => {
      if (a.weeks <= 3) now.push(a);
      else if (a.weeks <= 14) near.push(a);
      else long.push(a);
    });
    return { now, near, long };
  }

  function inr(n) {
    return "₹" + Number(n).toLocaleString("en-IN");
  }

  return {
    FACTORS, activities, co2, footprintKg, hotspots, reductionActions,
    optimize, forecast, mixForHour, roadmap, inr
  };
})();
