/* CarbonWise Industrial UI layer — overlays extra screens without blocking dashboard */
(function () {
  const E = window.CWEngine;
  let appMode = "INDUSTRIAL";
  let lastOpt = null;
  let leafletReady = false;
  let leafletLoading = null;
  let predFailed = false;

  function loadLeaflet() {
    if (window.CWLazyLoader) {
      return window.CWLazyLoader.loadLeaflet();
    }
    return Promise.resolve(window.L);
  }

  window.loginAsDemo = function (role) {
    if (role === "CITY_ADMIN") {
      currentUser = { id: "admin-1", email: "admin@carbonwise.com", name: "Area Manager", role: "CITY_ADMIN", token: "mock" };
      appMode = "CONSUMER";
    } else if (role === "INDUSTRIAL") {
      currentUser = { id: "ind-1", email: "plant@carbonwise.com", name: "Priya Natarajan", role: "INDUSTRIAL", org: "Guindy Precision Works", token: "mock" };
      appMode = "INDUSTRIAL";
    } else {
      currentUser = { id: "user-1", email: "user@carbonwise.com", name: "Alex Rivera", role: "CONSUMER", token: "mock" };
      appMode = "CONSUMER";
    }
    localStorage.setItem("carbonwise_user", JSON.stringify(currentUser));
    localStorage.setItem("cw_mode", appMode);
    showToast("Demo workspace ready — labelled DEMO DATA", "info");
    enterApp();
  };

  const origEnter = window.enterApp;
  window.enterApp = function () {
    appMode = currentUser?.role === "INDUSTRIAL" ? "INDUSTRIAL" : (localStorage.getItem("cw_mode") || "CONSUMER");
    origEnter();
    buildSidebar();
    enhanceDashboard();
    initDataListeners();
  };

  function navItems() {
    if (appMode === "INDUSTRIAL") {
      return [
        ["dashboard", "fa-gauge", "Dashboard"],
        ["intelligence", "fa-brain", "Carbon Intelligence"],
        ["predictions", "fa-wand-magic-sparkles", "Predictions"],
        ["grid", "fa-bolt", "Grid Intelligence"],
        ["appliances", "fa-microchip", "Devices (12)"],
        ["maps", "fa-map", "Carbon GIS"],
        ["optimize", "fa-robot", "AI Optimization"],
        ["plan", "fa-road", "Action Plan"],
        ["scheduler", "fa-clock", "Automation"],
        ["reports", "fa-file-lines", "Reports"],
        ["notifications", "fa-bell", "Notifications"],
        ["profile", "fa-user", "Profile"]
      ];
    }
    return [
      ["dashboard", "fa-gauge", "Overview"],
      ["predictions", "fa-wand-magic-sparkles", "Predict"],
      ["appliances", "fa-plug", "Devices"],
      ["maps", "fa-map", "Maps"],
      ["reports", "fa-file-lines", "Reports"],
      ["profile", "fa-user", "Profile"]
    ];
  }

  function buildSidebar() {
    const side = document.getElementById("app-sidebar");
    const bot = document.getElementById("bottom-nav");
    if (!side) return;
    const items = navItems();
    side.innerHTML = `
      <div class="mode-switch">
        <button class="${appMode === "INDUSTRIAL" ? "active" : ""}" onclick="cwSetMode('INDUSTRIAL')">Industrial</button>
        <button class="${appMode === "CONSUMER" ? "active" : ""}" onclick="cwSetMode('CONSUMER')">Consumer</button>
      </div>
      ${items.map(([id, ic, lab]) => `<button class="side-link" data-view="${id}" onclick="switchView('${id}')"><i class="fas ${ic}"></i> ${lab}</button>`).join("")}
    `;
    const mobile = items.slice(0, 5);
    if (bot) {
      bot.innerHTML = mobile.map(([id, ic, lab]) =>
        `<button data-view="${id}" onclick="switchView('${id}')"><i class="fas ${ic}"></i>${lab}</button>`).join("");
    }
  }

  window.cwSetMode = function (m) {
    appMode = m;
    if (currentUser) currentUser.role = m === "INDUSTRIAL" ? "INDUSTRIAL" : "CONSUMER";
    localStorage.setItem("cw_mode", m);
    buildNavTabs();
    buildSidebar();
    switchView("dashboard");
    enhanceDashboard();
    showToast(`Switched to ${m} mode`, "success");
  };

  const origSwitch = window.switchView;
  window.switchView = function (name) {
    origSwitch(name);
    document.querySelectorAll(".side-link, .bottom-nav button").forEach((b) => {
      b.classList.toggle("active", b.getAttribute("data-view") === name);
    });
    if (name === "dashboard") enhanceDashboard();
    if (name === "intelligence") renderIntelligence();
    if (name === "grid") renderGrid();
    if (name === "optimize") renderOptimize();
    if (name === "plan") renderPlan();
    if (name === "profile") renderProfilePage();
    if (name === "predictions") renderPredictionsFast();
    if (name === "maps") initMapsSafe();
    if (name === "notifications") renderIndustrialNotifications();
    if (name === "appliances") renderIndustrialAppliances();
  };

  function initDataListeners() {
    if (!window.CWIndustrialData) return;
    
    // Grid Ticker Listener
    window.CWIndustrialData.grid.onChange((current) => {
      const activeView = document.querySelector(".app-view:not(.hidden)");
      if (activeView && activeView.id === "view-dashboard") enhanceDashboard();
      if (activeView && activeView.id === "view-grid") renderGrid();
      
      const liveStatus = document.getElementById("live-status-text");
      if (liveStatus) {
        liveStatus.innerText = `${current.status} (${current.intensity} gCO₂)`;
      }
    });

    // Device Telemetry Listener
    window.CWIndustrialData.devices.onChange(() => {
      const activeView = document.querySelector(".app-view:not(.hidden)");
      if (activeView && activeView.id === "view-appliances") renderIndustrialAppliances();
    });

    // Notification Listener
    window.CWIndustrialData.notifications.onChange((notifs, count) => {
      const badge = document.getElementById("notif-badge-count");
      if (badge) {
        badge.innerText = count;
        badge.style.display = count > 0 ? "inline-block" : "none";
      }
      const activeView = document.querySelector(".app-view:not(.hidden)");
      if (activeView && activeView.id === "view-notifications") renderIndustrialNotifications();
    });
  }

  function enhanceDashboard() {
    if (appMode !== "INDUSTRIAL") return;
    const indData = window.CWIndustrialData;
    const grid = indData ? indData.grid.getCurrent() : { intensity: 320, renewable: 63.5, status: "CLEAN" };
    const devices = indData ? indData.devices.getAll() : [];
    const activeCount = devices.filter(d => d.status !== "OFFLINE").length;
    const totalPower = devices.filter(d => d.status !== "OFFLINE").reduce((s, d) => s + d.currentPower, 0);

    const fp = E.footprintKg();
    const dash = document.getElementById("view-dashboard");
    if (!dash) return;
    const header = dash.querySelector(".view-header h1");
    if (header) header.innerHTML = `Carbon Intelligence Center <span class="demo-chip">LIVE CSV SIMULATION</span>`;
    const sub = dash.querySelector(".subtitle");
    if (sub) sub.textContent = "Guindy Precision Works • Campus Real-time Telemetry & Decarbonization";
    
    const stats = dash.querySelector(".stats-grid");
    if (stats) {
      stats.className = "kpi-grid";
      stats.innerHTML = [
        ["TOTAL CARBON FOOTPRINT", fp.tonnes.toFixed(0) + " t CO₂", "fa-cloud"],
        ["CURRENT LOAD", totalPower.toFixed(1) + " kW", "fa-bolt"],
        ["GRID INTENSITY", `${grid.intensity} gCO₂/kWh`, "fa-wave-square"],
        ["GRID STATUS", `${grid.status} (${grid.renewable}% Clean)`, "fa-solar-panel"],
        ["ACTIVE MACHINES", `${activeCount} / ${devices.length}`, "fa-industry"],
        ["SUSTAINABILITY BUDGET", "₹10,00,000", "fa-indian-rupee-sign"]
      ].map(([l, v, i]) => `
        <div class="stat-card">
          <div class="stat-icon green"><i class="fas ${i}"></i></div>
          <div class="stat-content">
            <div class="stat-value">${v}</div>
            <div class="stat-label">${l}</div>
          </div>
        </div>`).join("");
    }

    const rec = dash.querySelector(".recommendations");
    if (rec) {
      rec.innerHTML = [
        ["Clean energy window detected (11:30 AM – 2:30 PM)", `Current grid intensity is ${grid.intensity} gCO₂/kWh with ${grid.renewable}% renewable share. Dispatch flexible loads now.`],
        ["Furnace FRN-010 preheat schedule", "Shift annealing batch into the midday solar peak window."],
        ["Boiler BLR-009 high thermal risk", "Surface temp 115°C & PM2.5 84 µg/m³ in Boiler utility bay. Inspection recommended."],
        ["Air Compressor CMP-003 VFD optimization", "Modulate line pressure during low pneumatic demand periods to save 4.8 kW."]
      ].map(([t, p]) => `<div class="rec-item"><i class="fas fa-check-circle text-green"></i><div><strong>${t}</strong><p>${p}</p></div></div>`).join("");
    }
  }

  function renderIntelligence() {
    const el = document.getElementById("view-intelligence");
    const fp = E.footprintKg();
    const indData = window.CWIndustrialData;
    const fuel = indData ? indData.fuel.getData() : { dieselL: 340, trendPct: 11.8, totalFuelCo2Tonnes: 1.2 };

    el.innerHTML = `
      <div class="view-header">
        <div>
          <h1>Carbon Intelligence Center</h1>
          <p class="subtitle">5 Emission categories, hotspots, trends, fuel monitoring, and unit intensity</p>
        </div>
        <div class="header-actions">
          <button class="btn-time-tab active" onclick="cwTrend(7,this)">7d</button>
          <button class="btn-time-tab" onclick="cwTrend(30,this)">30d</button>
          <button class="btn-time-tab" onclick="cwTrend(90,this)">90d</button>
          <button class="btn-time-tab" onclick="cwTrend(365,this)">1y</button>
        </div>
      </div>

      <div class="stats-grid">
        <div class="stat-card accent">
          <div class="stat-content">
            <div class="stat-value">${fp.tonnes.toFixed(0)} <small>t CO₂</small></div>
            <div class="stat-label">Total Facility Footprint</div>
            <p class="why-next text-green">↓ 8.4% vs benchmark year</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value">${(fp.total / 812000).toFixed(2)}</div>
            <div class="stat-label">kg CO₂ per kWh intensity</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value">0.41</div>
            <div class="stat-label">t CO₂ per production unit</div>
          </div>
        </div>
      </div>

      <div class="grid-2">
        <div class="card">
          <div class="card-header">
            <h3>5 Core Emission Streams</h3>
            <span class="demo-chip">ACTIVITY × FACTOR</span>
          </div>
          ${fp.sources.map((s) => `
            <div class="source-row" onclick="showToast('${s.name}: ${(s.kg / 1000).toFixed(1)} t CO₂','info')">
              <span style="width:110px">${s.name}</span>
              <div class="source-bar"><i style="width:${(s.pct * 100).toFixed(0)}%"></i></div>
              <strong>${(s.pct * 100).toFixed(0)}%</strong>
            </div>`).join("")}
        </div>

        <div class="card">
          <div class="card-header">
            <h3>Fuel Consumption &amp; Combustion</h3>
            <span class="badge ${fuel.trendPct > 10 ? 'red' : 'green'}">${fuel.trendPct > 0 ? '+' : ''}${fuel.trendPct}% Spike</span>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:10px">
            <div class="stat-card" style="padding:10px">
              <div class="stat-label">Diesel Usage</div>
              <div class="stat-value">${fuel.dieselL} <small>L/day</small></div>
              <small style="color:#ef4444">Spike: +${fuel.trendPct}% vs prev shift</small>
            </div>
            <div class="stat-card" style="padding:10px">
              <div class="stat-label">LPG Combustion</div>
              <div class="stat-value">${fuel.lpgKg} <small>kg/day</small></div>
              <small style="color:#00f576">Optimal range</small>
            </div>
          </div>
          <p class="why-next" style="margin-top:12px">
            <i class="fas fa-triangle-exclamation text-yellow"></i> <strong>Fuel Alert:</strong> Boiler BLR-009 auxiliary diesel consumption exceeded benchmark by 11.8%.
          </p>
        </div>
      </div>

      <div class="grid-2" style="margin-top:16px">
        <div class="card">
          <div class="card-header">
            <h3>Carbon Hotspots (Ranked by CO₂)</h3>
          </div>
          ${E.hotspots.map((h) => `
            <div class="hotspot ${h.severity}" style="cursor:pointer" onclick="switchView('appliances')">
              <div>
                <strong>${h.name}</strong>
                <div class="why-next">${h.action}</div>
              </div>
              <span>${h.t} t CO₂</span>
              <span class="${h.trend > 0 ? "text-red" : "text-green"}">${h.trend > 0 ? "↑" : "↓"} ${Math.abs(h.trend)}%</span>
            </div>`).join("")}
        </div>

        <div class="card">
          <div class="card-header">
            <h3>Emission Trend</h3>
          </div>
          <div class="chart-container">
            <canvas id="intel-chart"></canvas>
          </div>
        </div>
      </div>`;

    requestAnimationFrame(() => {
      const c = document.getElementById("intel-chart");
      if (!c || !window.Chart) return;
      new Chart(c, {
        type: "line",
        data: {
          labels: ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6"],
          datasets: [{
            label: "t CO₂",
            data: [1420, 1388, 1402, 1310, 1294, 1284],
            borderColor: "#00f576",
            tension: 0.35,
            fill: false
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: {
            x: { ticks: { color: "#94a3b8" } },
            y: { ticks: { color: "#94a3b8" } }
          }
        }
      });
    });
  }

  window.cwTrend = function (d, btn) {
    document.querySelectorAll("#view-intelligence .btn-time-tab").forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    showToast(`Emission trend window: ${d} days`, "info");
  };

  function renderGrid() {
    const indData = window.CWIndustrialData;
    const grid = indData ? indData.grid.getCurrent() : {
      timestamp: "12:00", intensity: 320, renewable: 63.5, thermal: 36.5, solar: 52, wind: 7, hydro: 4.5, demand: 4427, status: "CLEAN"
    };
    const allRecords = indData ? indData.grid.getAll() : [];

    const el = document.getElementById("view-grid");
    el.innerHTML = `
      <div class="view-header">
        <div>
          <h1>Grid Intelligence &amp; Prediction</h1>
          <p class="subtitle">Live intensity, renewable mix, regional grid demand, clean operating windows</p>
        </div>
        <span class="demo-chip">LIVE CSV SIMULATION • Updates every 15s</span>
      </div>

      <div class="kpi-grid">
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value">${grid.intensity} <small>gCO₂/kWh</small></div>
            <div class="stat-label">Carbon Intensity [${grid.status}]</div>
            <p class="why-next">${grid.intensity < 350 ? "Clean energy window active. Low emission tariff." : grid.intensity > 600 ? "High thermal share. Defer heavy machinery." : "Normal grid operating conditions."}</p>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value text-green">${grid.renewable}%</div>
            <div class="stat-label">Renewable Share</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value text-red">${grid.thermal}%</div>
            <div class="stat-label">Thermal (Coal/Gas)</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-value">${grid.demand} <small>MW</small></div>
            <div class="stat-label">Regional Demand</div>
          </div>
        </div>
      </div>

      <div class="grid-2">
        <div class="card">
          <div class="card-header">
            <h3>Generation Mix (Timestamp: ${grid.timestamp})</h3>
            <span class="badge ${grid.status === 'CLEAN' ? 'green' : grid.status === 'HIGH' ? 'red' : 'yellow'}">${grid.status} GRID</span>
          </div>
          ${[
            ["Solar PV Farm Generation", grid.solar, "green"],
            ["Wind Turbine Generation", grid.wind, "cyan"],
            ["Hydroelectric Generation", grid.hydro, "cyan"],
            ["Thermal & Fossil Generation", grid.thermal, "red"]
          ].map(([n, v, c]) => `
            <div class="mix-item" style="margin-bottom:12px">
              <div class="mix-label-row" style="display:flex;justify-content:space-between;margin-bottom:4px">
                <span>${n}</span>
                <strong>${v}%</strong>
              </div>
              <div class="progress-track" style="background:#1e293b;height:8px;border-radius:4px;overflow:hidden">
                <div class="progress-fill ${c}" style="width:${v}%;height:100%;background:${c === 'green' ? '#00f576' : c === 'red' ? '#ef4444' : '#00e5ff'}"></div>
              </div>
            </div>`).join("")}
        </div>

        <div class="card">
          <div class="card-header">
            <h3>24h Carbon Intensity Curve</h3>
            <span class="badge green">CLEAN WINDOW 11:30 AM – 2:30 PM</span>
          </div>
          <div class="chart-container">
            <canvas id="grid-chart"></canvas>
          </div>
        </div>
      </div>`;

    requestAnimationFrame(() => {
      const c = document.getElementById("grid-chart");
      if (!c || !window.Chart) return;
      const pts = allRecords.length ? allRecords : [
        { timestamp: "06:00", intensity: 560 },
        { timestamp: "09:00", intensity: 440 },
        { timestamp: "12:00", intensity: 317 },
        { timestamp: "15:00", intensity: 385 },
        { timestamp: "18:00", intensity: 580 },
        { timestamp: "21:00", intensity: 610 }
      ];
      new Chart(c, {
        type: "line",
        data: {
          labels: pts.map((p) => p.timestamp),
          datasets: [{
            label: "gCO₂/kWh",
            data: pts.map((p) => p.intensity),
            borderColor: "#00e5ff",
            fill: true,
            backgroundColor: "rgba(0,229,255,0.08)",
            tension: 0.3
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: {
            x: { ticks: { color: "#94a3b8", maxTicksLimit: 8 } },
            y: { ticks: { color: "#94a3b8" } }
          }
        }
      });
    });
  }

  // --- INDUSTRIAL APPLIANCES (12 MACHINES) ---
  function renderIndustrialAppliances() {
    const indData = window.CWIndustrialData;
    const devices = indData ? indData.devices.getAll() : [];
    const container = document.getElementById("appliances-grid");
    if (!container) return;

    container.innerHTML = devices.map((d) => {
      const isOnline = d.status === "ONLINE";
      const isWarn = d.status === "WARNING" || d.riskLevel === "HIGH";
      return `
        <div class="appliance-card card" id="appliance-${d.id}" style="cursor:pointer" onclick="openIndustrialDeviceDetail('${d.id}')">
          <div class="card-header" style="display:flex;justify-content:space-between;align-items:center">
            <div>
              <h4 style="margin:0;font-size:15px;color:#fff">${d.name}</h4>
              <small style="color:#64748b">${d.id} • ${d.location}</small>
            </div>
            <span class="badge ${isOnline ? (isWarn ? 'yellow' : 'green') : 'red'}">${d.status}</span>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin:12px 0;font-size:12px">
            <div><span style="color:#94a3b8">Load:</span> <strong>${d.currentPower} kW</strong></div>
            <div><span style="color:#94a3b8">Energy:</span> <strong>${d.energyToday.toFixed(1)} kWh</strong></div>
            <div><span style="color:#94a3b8">Temp:</span> <strong>${d.temp}°C</strong></div>
            <div><span style="color:#94a3b8">Vibration:</span> <strong>${d.vibration} mm/s</strong></div>
          </div>
          <div style="display:flex;justify-content:space-between;align-items:center;border-top:1px solid #1e293b;padding-top:8px">
            <span style="font-size:11px;color:#00f576;font-weight:bold"><i class="fas fa-leaf"></i> ${d.carbonKg || (d.currentPower * 0.8).toFixed(1)} kg CO₂</span>
            <span style="font-size:11px;color:${isWarn ? '#ffb800' : '#00e5ff'}"><i class="fas fa-shield-halved"></i> Risk: ${d.riskLevel}</span>
          </div>
        </div>`;
    }).join("");
  }

  window.openIndustrialDeviceDetail = function (id) {
    const indData = window.CWIndustrialData;
    const d = indData ? indData.devices.getById(id) : null;
    if (!d) return;

    switchView("device-detail");
    document.getElementById("view-device-detail").innerHTML = `
      <div class="view-header">
        <div>
          <h1>${d.name} (${d.id})</h1>
          <p class="subtitle">${d.type} • ${d.location} • 3-Phase 415V</p>
        </div>
        <button class="btn-secondary" onclick="switchView('appliances')"><i class="fas fa-arrow-left"></i> Back to Machines</button>
      </div>

      <div class="kpi-grid">
        <div class="stat-card">
          <div class="stat-label">Operating Status</div>
          <div class="stat-value text-green">${d.status}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active Power Demand</div>
          <div class="stat-value">${d.currentPower} kW</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Cumulative Energy Today</div>
          <div class="stat-value">${d.energyToday.toFixed(1)} kWh</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Direct Carbon Contribution</div>
          <div class="stat-value text-green">${d.carbonKg || (d.currentPower * 0.8).toFixed(1)} kg CO₂</div>
        </div>
      </div>

      <div class="grid-2" style="margin-top:16px">
        <div class="card">
          <div class="card-header">
            <h3>Machine Diagnostics &amp; Telemetry</h3>
            <span class="badge ${d.riskLevel === 'LOW' ? 'green' : d.riskLevel === 'MEDIUM' ? 'yellow' : 'red'}">${d.riskLevel} RISK</span>
          </div>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;font-size:13px;margin:12px 0">
            <div class="stat-card" style="padding:10px">
              <span style="color:#94a3b8">Voltage:</span>
              <div style="font-size:18px;font-weight:bold">${d.voltage} V</div>
            </div>
            <div class="stat-card" style="padding:10px">
              <span style="color:#94a3b8">Current:</span>
              <div style="font-size:18px;font-weight:bold">${d.current} A</div>
            </div>
            <div class="stat-card" style="padding:10px">
              <span style="color:#94a3b8">Surface Temperature:</span>
              <div style="font-size:18px;font-weight:bold;color:${d.temp > 75 ? '#ef4444' : '#00f576'}">${d.temp} °C</div>
            </div>
            <div class="stat-card" style="padding:10px">
              <span style="color:#94a3b8">Vibration Amplitude:</span>
              <div style="font-size:18px;font-weight:bold;color:${d.vibration > 4 ? '#ef4444' : '#00e5ff'}">${d.vibration} mm/s</div>
            </div>
          </div>
          <div class="header-actions" style="margin-top:16px">
            <button class="btn-secondary" onclick="window.CWIndustrialData.devices.toggleDevice('${d.id}'); openIndustrialDeviceDetail('${d.id}')">
              <i class="fas fa-power-off"></i> Toggle ON/OFF
            </button>
          </div>
        </div>

        <div class="card">
          <div class="card-header">
            <h3>Grid-Aware Clean Scheduling</h3>
          </div>
          <p class="why-next" style="margin-top:8px">
            Recommended operating window: <strong>11:30 AM – 2:30 PM</strong>.<br>
            Operating during this window saves approximately <strong>${(d.powerRating * 2 * 0.28).toFixed(1)} kg CO₂</strong> compared to peak tariff periods.
          </p>
          <div class="header-actions" style="margin-top:16px">
            <button class="btn-primary" onclick="showToast('Scheduled ${d.name} for 11:30 AM clean window','success')">
              <i class="fas fa-calendar-check"></i> Schedule in Clean Window
            </button>
          </div>
        </div>
      </div>`;
  };

  // --- NOTIFICATIONS VIEW ---
  function renderIndustrialNotifications() {
    const indData = window.CWIndustrialData;
    const notifs = indData ? indData.notifications.getNotifications() : [];
    const list = document.getElementById("full-notifications-list");
    if (!list) return;

    list.innerHTML = `
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px">
        <h3 style="margin:0">Recent Telemetry &amp; Grid Alerts</h3>
        <button class="btn-secondary" style="font-size:12px;padding:6px 12px" onclick="window.CWIndustrialData.notifications.markAllAsRead()">
          <i class="fas fa-check-double"></i> Mark All as Read
        </button>
      </div>
      ${notifs.map((n) => `
        <div class="notification-item ${n.read ? '' : 'unread'}" style="cursor:pointer;padding:12px;border-radius:10px;margin-bottom:8px;background:${n.read ? '#0f172a' : '#1e293b'};border-left:4px solid ${n.priority === 'CRITICAL' ? '#ef4444' : n.priority === 'HIGH' ? '#ffb800' : '#00f576'}" onclick="handleNotifClick('${n.id}', '${n.targetView}')">
          <div style="display:flex;justify-content:space-between;align-items:center">
            <strong style="color:#fff">${n.title}</strong>
            <small style="color:#64748b">${n.timestamp}</small>
          </div>
          <p style="margin:4px 0 0 0;font-size:13px;color:#94a3b8">${n.message}</p>
        </div>`).join("")}
    `;
  }

  window.handleNotifClick = function (id, target) {
    if (window.CWIndustrialData) {
      window.CWIndustrialData.notifications.markAsRead(id);
    }
    if (target) {
      switchView(target);
    }
  };

  // --- AI OPTIMIZATION (KNAPSACK) ---
  window.renderOptimize = function () {
    const budgetEl = document.getElementById("opt-budget");
    const budget = budgetEl ? Number(budgetEl.value) : 1000000;
    lastOpt = E.optimize(budget);
    const fp = E.footprintKg();
    const after = fp.tonnes - lastOpt.reduced;
    const el = document.getElementById("view-optimize");
    el.innerHTML = `
      <div class="view-header">
        <div>
          <h1>AI Budget Optimization (0/1 Knapsack)</h1>
          <p class="subtitle">Deterministic optimization: maximize CO₂ reduction within capital expenditure limit</p>
        </div>
      </div>
      <div class="card" style="margin-bottom:16px">
        <label>Sustainability Capital Budget (INR)</label>
        <div style="display:flex;gap:12px;margin-top:8px">
          <input class="budget-input" id="opt-budget" type="number" value="${budget}" style="flex:1;padding:12px;background:var(--bg-surface);border:1px solid var(--border);border-radius:12px;color:#fff">
          <button class="btn-primary" onclick="renderOptimize()"><i class="fas fa-robot"></i> Run Optimizer</button>
        </div>
      </div>
      <div class="opt-hero">
        <div class="card">
          <p class="demo-chip">0/1 Knapsack Solution • Repeatable &amp; Exact</p>
          <div class="kpi-grid" style="margin-top:16px">
            <div><div class="stat-label">Budget</div><div class="stat-value">${E.inr(lastOpt.budget)}</div></div>
            <div><div class="stat-label">Recommended Investment</div><div class="stat-value">${E.inr(lastOpt.invested)}</div></div>
            <div><div class="stat-label">Expected Annual Reduction</div><div class="stat-value text-green">${lastOpt.reduced.toFixed(1)} t CO₂</div></div>
            <div><div class="stat-label">Remaining Unallocated</div><div class="stat-value">${E.inr(lastOpt.remaining)}</div></div>
          </div>
          <p class="why-next">Reduction Efficiency: <strong>${lastOpt.efficiency.toFixed(2)} kg CO₂ per ₹1,000 invested</strong></p>
          <div class="before-after" style="display:flex;align-items:center;gap:16px;margin-top:12px">
            <div><div class="stat-label">BEFORE</div><div class="ba-num">${fp.tonnes.toFixed(1)} t</div></div>
            <i class="fas fa-arrow-right text-green"></i>
            <div><div class="stat-label">AFTER</div><div class="ba-num text-green">${after.toFixed(1)} t</div></div>
          </div>
        </div>
        <div class="card">
          <h3>Selected Decarbonization Actions</h3>
          ${lastOpt.selected.map((a) => `
            <div class="action-card" style="margin-top:8px;padding:10px;border-radius:8px;background:#0f172a;border-left:3px solid #00f576">
              <h4 style="margin:0 0 4px 0">${a.name}</h4>
              <p style="margin:0;font-size:12px;color:#94a3b8">${E.inr(a.cost)} · ↓ ${a.co2} t CO₂/yr · Payback: ${a.weeks} wks · ${a.difficulty} disruption</p>
              <p class="why-next" style="margin:4px 0 0 0;font-size:11px">WHY: ${a.why}</p>
            </div>`).join("")}
        </div>
      </div>`;
  };

  function renderPlan() {
    if (!lastOpt) lastOpt = E.optimize(1000000);
    const rm = E.roadmap(lastOpt.selected.concat(E.reductionActions.filter((a) => a.weeks <= 3).slice(0, 2)));
    const block = (title, arr, dept) => `
      <div class="card roadmap-col" style="flex:1;min-width:280px">
        <h3>${title}</h3>
        ${arr.map((a) => `
          <div class="action-card" style="margin-top:8px;padding:10px;border-radius:8px;background:#0f172a;border-left:3px solid #00e5ff">
            <strong>${a.name}</strong>
            <p style="margin:4px 0 0 0;font-size:12px;color:#94a3b8">${E.inr(a.cost)} · ${a.co2} t · ${dept}</p>
          </div>`).join("") || "<p class='why-next'>No items in this horizon</p>"}
      </div>`;
    document.getElementById("view-plan").innerHTML = `
      <div class="view-header"><div><h1>Decarbonization Action Roadmap</h1><p class="subtitle">Structured timeline: NOW → NEAR TERM → LONG TERM</p></div></div>
      <div style="display:flex;gap:16px;flex-wrap:wrap">
        ${block("NOW · 1–2 weeks", rm.now, "Operations & Maintenance")}
        ${block("NEAR TERM · 1–3 months", rm.near, "Plant Engineering")}
        ${block("LONG TERM · 6+ months", rm.long, "Capital Projects / ESG")}
      </div>`;
  }

  function renderPredictionsFast() {
    const view = document.getElementById("view-predictions");
    const fc = E.forecast(currentPredictionHorizon || 6);
    predFailed = false;
    const extra = document.getElementById("pred-kpis");
    if (!document.getElementById("pred-kpis")) {
      const box = document.createElement("div");
      box.id = "pred-kpis";
      box.className = "kpi-grid";
      box.style.marginBottom = "16px";
      view.querySelector(".view-header")?.after(box);
    }
    const k = document.getElementById("pred-kpis");
    k.innerHTML = `
      <div class="stat-card"><div class="stat-content"><div class="stat-value">${fc.current}</div><div class="stat-label">CURRENT gCO₂/kWh</div></div></div>
      <div class="stat-card"><div class="stat-content"><div class="stat-value text-green">${fc.predictedLow}</div><div class="stat-label">PREDICTED LOW</div></div></div>
      <div class="stat-card"><div class="stat-content"><div class="stat-value">11:30–14:30</div><div class="stat-label">CLEAN WINDOW · −28% CO₂</div></div></div>
      <div class="stat-card"><div class="stat-content"><div class="stat-value">91.4%</div><div class="stat-label">ML Confidence</div></div></div>`;
  }

  function initMapsSafe() {
    if (typeof initUserMapView === "function") {
      initUserMapView();
    }
  }

  function renderProfilePage() {
    const u = currentUser || {};
    const saved = JSON.parse(localStorage.getItem("cw_profile") || "{}");
    document.getElementById("view-profile").innerHTML = `
      <div class="view-header"><div><h1>Profile &amp; Plant Settings</h1><p class="subtitle">Organization identity, sustainability targets, and capital budget</p></div>
      <div class="header-actions"><button class="btn-secondary" onclick="cwCancelProfile()">Cancel</button>
      <button class="btn-primary" onclick="cwSaveProfile()">Save changes</button></div></div>
      <div class="card">
        <div class="profile-form">
          <div class="form-group"><label>Plant / Facility Name</label><input id="p-org" value="${saved.org || u.org || "Guindy Precision Works"}"></div>
          <div class="form-group"><label>Lead Engineer / User</label><input id="p-name" value="${saved.name || u.name || "Priya Natarajan"}"></div>
          <div class="form-group"><label>Email Address</label><input id="p-email" value="${saved.email || u.email || "plant@carbonwise.com"}"></div>
          <div class="form-group"><label>Designation / Role</label><input id="p-role" value="${saved.role || "Industrial ESG Lead"}"></div>
          <div class="form-group"><label>Location</label><input id="p-loc" value="${saved.loc || "Chennai Industrial Corridor"}"></div>
          <div class="form-group"><label>Industry Category</label><input id="p-ind" value="${saved.ind || "Precision Engineering & Manufacturing"}"></div>
          <div class="form-group"><label>Decarbonization Target</label><input id="p-tgt" value="${saved.tgt || "−25% Net Carbon by 2027"}"></div>
          <div class="form-group"><label>Sustainability Capital Budget (₹)</label><input id="p-bud" type="number" value="${saved.bud || 1000000}"></div>
        </div>
      </div>`;
  }

  window.cwSaveProfile = function () {
    const profile = {
      name: document.getElementById("p-name").value,
      email: document.getElementById("p-email").value,
      org: document.getElementById("p-org").value,
      role: document.getElementById("p-role").value,
      loc: document.getElementById("p-loc").value,
      ind: document.getElementById("p-ind").value,
      tgt: document.getElementById("p-tgt").value,
      bud: document.getElementById("p-bud").value
    };
    localStorage.setItem("cw_profile", JSON.stringify(profile));
    if (currentUser) {
      currentUser.name = profile.name;
      currentUser.email = profile.email;
      const navName = document.getElementById("nav-user-name");
      if (navName) navName.innerText = profile.name;
    }
    showToast("Profile saved successfully without reload", "success");
  };

  window.cwCancelProfile = function () {
    renderProfilePage();
    showToast("Changes discarded", "info");
  };

  // --- PDF REPORT GENERATION & DOWNLOAD ---
  window.downloadPdfReport = function () {
    showToast("Generating Carbon Report PDF…", "info");
    try {
      const indData = window.CWIndustrialData;
      const period = typeof currentReportPeriod !== "undefined" ? currentReportPeriod : "monthly";
      const date = new Date().toISOString().slice(0, 10);
      const filename = `CarbonWise_Carbon_Report_${date}.pdf`;

      let pdfData;
      if (indData && indData.reports) {
        pdfData = indData.reports.generatePdf(period);
      } else {
        pdfData = "%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n%%EOF";
      }

      const blob = new Blob([pdfData], { type: "application/pdf" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      a.remove();
      showToast(`Report downloaded: ${filename}`, "success");
    } catch (e) {
      console.error("PDF generation failed:", e);
      showToast("Report generation failed. Retry.", "error");
    }
  };

  // Override Add Device submit
  window.handleAddDeviceSubmit = function (e) {
    e.preventDefault();
    const name = document.getElementById("dev-name").value.trim();
    if (!name) return;
    const power = parseFloat(document.getElementById("dev-power").value) || 15.0;
    const type = document.getElementById("dev-type").value;
    const loc = document.getElementById("dev-loc")?.value || "Plant Floor";

    if (window.CWIndustrialData) {
      window.CWIndustrialData.devices.addDevice({
        name,
        type,
        power,
        location: loc
      });
    }

    closeModal("modal-add-device");
    renderIndustrialAppliances();
    showToast(`${name} added — CONNECTING... then ONLINE (DEMO)`, "success");
    document.getElementById("dev-name").value = "";
  };

  document.addEventListener("DOMContentLoaded", () => {
    initDataListeners();
  });
})();
