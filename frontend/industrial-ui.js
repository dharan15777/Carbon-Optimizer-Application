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
  };

  function navItems() {
    if (appMode === "INDUSTRIAL") {
      return [
        ["dashboard", "fa-gauge", "Dashboard"],
        ["intelligence", "fa-brain", "Carbon Intelligence"],
        ["predictions", "fa-wand-magic-sparkles", "Predictions"],
        ["grid", "fa-bolt", "Grid Intelligence"],
        ["appliances", "fa-microchip", "Devices"],
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
    if (name === "intelligence") renderIntelligence();
    if (name === "grid") renderGrid();
    if (name === "optimize") renderOptimize();
    if (name === "plan") renderPlan();
    if (name === "profile") renderProfilePage();
    if (name === "predictions") renderPredictionsFast();
    if (name === "maps") initMapsSafe();
  };

  function enhanceDashboard() {
    if (appMode !== "INDUSTRIAL") return;
    const fp = E.footprintKg();
    const dash = document.getElementById("view-dashboard");
    if (!dash) return;
    const header = dash.querySelector(".view-header h1");
    if (header) header.innerHTML = `Carbon Intelligence Center <span class="demo-chip">DEMO DATA</span>`;
    const sub = dash.querySelector(".subtitle");
    if (sub) sub.textContent = "Measure → understand → predict → optimize → act";
    const stats = dash.querySelector(".stats-grid");
    if (stats) {
      stats.className = "kpi-grid";
      stats.innerHTML = [
        ["TOTAL CARBON FOOTPRINT", fp.tonnes.toFixed(0) + " t CO₂", "fa-cloud"],
        ["CARBON REDUCTION", "18.6%", "fa-arrow-trend-down"],
        ["GRID INTENSITY", "412 gCO₂/kWh", "fa-bolt"],
        ["SUSTAINABILITY BUDGET", "₹10,00,000", "fa-indian-rupee-sign"],
        ["ACTIVE DEVICES", String(state.appliances.length), "fa-microchip"]
      ].map(([l, v, i]) => `<div class="stat-card"><div class="stat-icon green"><i class="fas ${i}"></i></div><div class="stat-content"><div class="stat-value">${v}</div><div class="stat-label">${l}</div></div></div>`).join("");
    }
    const rec = dash.querySelector(".recommendations");
    if (rec) {
      rec.innerHTML = [
        ["Shift EV charging to 2 PM", "Grid intensity expected −24%"],
        ["Solar generation is currently available", "Dispatch flexible loads now"],
        ["Production Line A abnormal energy", "Investigate 2nd-shift kW spike"],
        ["Grid intensity expected to fall 24% at 3 PM", "Schedule furnace preheat"]
      ].map(([t, p]) => `<div class="rec-item"><i class="fas fa-check-circle text-green"></i><div><strong>${t}</strong><p>${p}</p></div></div>`).join("");
    }
  }

  function renderIntelligence() {
    const el = document.getElementById("view-intelligence");
    const fp = E.footprintKg();
    el.innerHTML = `
      <div class="view-header"><div><h1>Carbon Intelligence</h1><p class="subtitle">Total footprint, hotspots, trends, anomalies</p></div>
      <div class="header-actions"><button class="btn-time-tab active" onclick="cwTrend(7,this)">7d</button>
      <button class="btn-time-tab" onclick="cwTrend(30,this)">30d</button>
      <button class="btn-time-tab" onclick="cwTrend(90,this)">90d</button>
      <button class="btn-time-tab" onclick="cwTrend(365,this)">1y</button></div></div>
      <div class="stats-grid">
        <div class="stat-card accent"><div class="stat-content"><div class="stat-value">${fp.tonnes.toFixed(0)} <small>t CO₂</small></div>
        <div class="stat-label">Carbon footprint</div><p class="why-next text-green">↓ 8.4% vs previous period</p></div></div>
        <div class="stat-card"><div class="stat-content"><div class="stat-value">${(fp.total / 812000).toFixed(2)}</div>
        <div class="stat-label">kg CO₂ per kWh intensity</div></div></div>
        <div class="stat-card"><div class="stat-content"><div class="stat-value">0.41</div>
        <div class="stat-label">t CO₂ per production unit</div></div></div>
      </div>
      <div class="grid-2">
        <div class="card"><div class="card-header"><h3>Carbon sources</h3><span class="demo-chip">DEMO DATA</span></div>
          ${fp.sources.map((s) => `<div class="source-row" onclick="showToast('${s.name}: ${(s.kg / 1000).toFixed(1)} t CO₂','info')">
            <span style="width:110px">${s.name}</span>
            <div class="source-bar"><i style="width:${(s.pct * 100).toFixed(0)}%"></i></div>
            <strong>${(s.pct * 100).toFixed(0)}%</strong></div>`).join("")}
        </div>
        <div class="card"><div class="card-header"><h3>Emission trend</h3></div>
          <div class="chart-container"><canvas id="intel-chart"></canvas></div></div>
      </div>
      <div class="card"><div class="card-header"><h3>Carbon hotspots</h3></div>
        ${E.hotspots.map((h) => `<div class="hotspot ${h.severity}"><div><strong>${h.name}</strong><div class="why-next">WHY ${h.severity} • WHAT NEXT: ${h.action}</div></div>
        <span>${h.t} t CO₂</span><span class="${h.trend > 0 ? "text-red" : "text-green"}">${h.trend > 0 ? "↑" : "↓"} ${Math.abs(h.trend)}%</span></div>`).join("")}
      </div>`;
    requestAnimationFrame(() => {
      const c = document.getElementById("intel-chart");
      if (!c || !window.Chart) return;
      new Chart(c, {
        type: "line",
        data: { labels: ["W1", "W2", "W3", "W4", "W5", "W6"], datasets: [{ label: "t CO₂", data: [1420, 1388, 1402, 1310, 1294, 1284], borderColor: "#00f576", tension: 0.35, fill: false }] },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { ticks: { color: "#94a3b8" } }, y: { ticks: { color: "#94a3b8" } } } }
      });
    });
  }
  window.cwTrend = function (d, btn) {
    document.querySelectorAll("#view-intelligence .btn-time-tab").forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    showToast(`Trend window: ${d} days`, "info");
  };

  function renderGrid() {
    const h = new Date().getHours();
    const mix = E.mixForHour(h);
    const fc = E.forecast(24);
    const el = document.getElementById("view-grid");
    el.innerHTML = `
      <div class="view-header"><div><h1>Grid Intelligence</h1><p class="subtitle">Live intensity, mix, clean operating windows</p></div>
      <span class="demo-chip">DEMO DATA if live grid API is down</span></div>
      <div class="kpi-grid">
        <div class="stat-card"><div class="stat-content"><div class="stat-value">412 <small>gCO₂/kWh</small></div><div class="stat-label">Live grid carbon intensity</div>
        <p class="why-next">WHY: thermal share is high. WHAT NEXT: run flexible loads 14:00–17:00.</p></div></div>
        <div class="stat-card"><div class="stat-content"><div class="stat-value">${mix.solar + mix.hydro}%</div><div class="stat-label">Renewable</div></div></div>
        <div class="stat-card"><div class="stat-content"><div class="stat-value">${mix.coal + mix.gas}%</div><div class="stat-label">Thermal</div></div></div>
      </div>
      <div class="grid-2">
        <div class="card"><div class="card-header"><h3>Generation mix</h3></div>
          ${[["Solar & Wind", mix.solar, "green"], ["Hydroelectric", mix.hydro, "cyan"], ["Natural Gas", mix.gas, "yellow"], ["Coal", mix.coal, "red"], ["Other", mix.other, "cyan"]].map(([n, v, c]) =>
            `<div class="mix-item"><div class="mix-label-row"><span>${n}</span><strong>${v}%</strong></div><div class="progress-track"><div class="progress-fill ${c}" style="width:${v}%"></div></div></div>`).join("")}
        </div>
        <div class="card"><div class="card-header"><h3>24h intensity</h3><span class="badge green">CLEAN WINDOW 14:00–17:00</span></div>
          <div class="chart-container"><canvas id="grid-chart"></canvas></div></div>
      </div>`;
    requestAnimationFrame(() => {
      const c = document.getElementById("grid-chart");
      if (!c) return;
      new Chart(c, {
        type: "line",
        data: { labels: fc.points.map((p) => p.hour + "h"), datasets: [{ data: fc.points.map((p) => p.intensity), borderColor: "#00e5ff", fill: true, backgroundColor: "rgba(0,229,255,0.1)", tension: 0.3 }] },
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } } }
      });
    });
  }

  window.renderOptimize = function () {
    const budgetEl = document.getElementById("opt-budget");
    const budget = budgetEl ? Number(budgetEl.value) : 1000000;
    lastOpt = E.optimize(budget);
    const fp = E.footprintKg();
    const after = fp.tonnes - lastOpt.reduced;
    const el = document.getElementById("view-optimize");
    el.innerHTML = `
      <div class="view-header"><div><h1>AI Optimization</h1><p class="subtitle">How should we spend your sustainability budget?</p></div></div>
      <div class="card" style="margin-bottom:16px">
        <label>Sustainability budget (INR)</label>
        <div style="display:flex;gap:12px;margin-top:8px">
          <input class="budget-input" id="opt-budget" type="number" value="${budget}" style="flex:1;padding:12px;background:var(--bg-surface);border:1px solid var(--border);border-radius:12px;color:#fff">
          <button class="btn-primary" onclick="renderOptimize()"><i class="fas fa-robot"></i> Run optimizer</button>
        </div>
      </div>
      <div class="opt-hero">
        <div class="card">
          <p class="demo-chip">Knapsack — maximize t CO₂ s.t. cost ≤ budget</p>
          <div class="kpi-grid" style="margin-top:16px">
            <div><div class="stat-label">Available</div><div class="stat-value">${E.inr(lastOpt.budget)}</div></div>
            <div><div class="stat-label">Recommended</div><div class="stat-value">${E.inr(lastOpt.invested)}</div></div>
            <div><div class="stat-label">Expected reduction</div><div class="stat-value text-green">${lastOpt.reduced.toFixed(1)} t</div></div>
            <div><div class="stat-label">Remaining</div><div class="stat-value">${E.inr(lastOpt.remaining)}</div></div>
          </div>
          <p class="why-next">Efficiency: ${lastOpt.efficiency.toFixed(2)} kg CO₂ per ₹1,000</p>
          <div class="before-after">
            <div><div class="stat-label">BEFORE</div><div class="ba-num">${fp.tonnes.toFixed(1)}</div></div>
            <i class="fas fa-arrow-right text-green"></i>
            <div><div class="stat-label">AFTER</div><div class="ba-num text-green">${after.toFixed(1)}</div></div>
          </div>
        </div>
        <div class="card"><h3>Recommended action plan</h3>
          ${lastOpt.selected.map((a) => `<div class="action-card"><h4>${a.name}</h4>
            <p>${E.inr(a.cost)} · ↓ ${a.co2} t CO₂/year · ${a.weeks} weeks · ${a.difficulty}</p>
            <p class="why-next">WHY: ${a.why}</p></div>`).join("")}
        </div>
      </div>`;
  };

  function renderPlan() {
    if (!lastOpt) lastOpt = E.optimize(1000000);
    const rm = E.roadmap(lastOpt.selected.concat(E.reductionActions.filter((a) => a.weeks <= 3).slice(0, 2)));
    const block = (title, arr, dept) => `
      <div class="card roadmap-col"><h3>${title}</h3>
        ${arr.map((a) => `<div class="action-card"><strong>${a.name}</strong><p>${E.inr(a.cost)} · ${a.co2} t · ${dept}</p></div>`).join("") || "<p class='why-next'>No items in this horizon</p>"}
      </div>`;
    document.getElementById("view-plan").innerHTML = `
      <div class="view-header"><div><h1>Action roadmap</h1><p class="subtitle">Now → near term → long term</p></div></div>
      <div style="display:flex;gap:16px;flex-wrap:wrap">
        ${block("NOW · 1–2 weeks", rm.now, "Operations")}
        ${block("NEAR TERM · 1–3 months", rm.near, "Engineering")}
        ${block("LONG TERM · 6+ months", rm.long, "Capex / ESG")}
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
      <div class="stat-card"><div class="stat-content"><div class="stat-value">14:00–17:00</div><div class="stat-label">BEST CLEAN WINDOW · −18.4 kg</div></div></div>
      <div class="stat-card"><div class="stat-content"><div class="stat-value">87%</div><div class="stat-label">Confidence</div></div></div>`;
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
      <div class="view-header"><div><h1>Profile</h1><p class="subtitle">Editable identity, org, sustainability, notifications</p></div>
      <div class="header-actions"><button class="btn-secondary" onclick="cwCancelProfile()">Cancel</button>
      <button class="btn-primary" onclick="cwSaveProfile()">Save changes</button></div></div>
      <div class="card">
        <div class="profile-form">
          <div class="form-group"><label>Full name</label><input id="p-name" value="${saved.name || u.name || ""}"></div>
          <div class="form-group"><label>Email</label><input id="p-email" value="${saved.email || u.email || ""}"></div>
          <div class="form-group"><label>Phone</label><input id="p-phone" value="${saved.phone || "+91 98765 43210"}"></div>
          <div class="form-group"><label>Organization</label><input id="p-org" value="${saved.org || u.org || "Guindy Precision Works"}"></div>
          <div class="form-group"><label>Role</label><input id="p-role" value="${saved.role || "ESG Lead"}"></div>
          <div class="form-group"><label>Location</label><input id="p-loc" value="${saved.loc || "Chennai"}"></div>
          <div class="form-group"><label>Industry</label><input id="p-ind" value="${saved.ind || "Precision manufacturing"}"></div>
          <div class="form-group"><label>Org size</label><input id="p-size" value="${saved.size || "240 employees"}"></div>
          <div class="form-group"><label>Sustainability target</label><input id="p-tgt" value="${saved.tgt || "−25% CO₂ by 2027"}"></div>
          <div class="form-group"><label>Monthly budget (₹)</label><input id="p-bud" type="number" value="${saved.bud || 1000000}"></div>
        </div>
      </div>`;
  }
  window.cwSaveProfile = function () {
    const profile = {
      name: document.getElementById("p-name").value,
      email: document.getElementById("p-email").value,
      phone: document.getElementById("p-phone").value,
      org: document.getElementById("p-org").value,
      role: document.getElementById("p-role").value,
      loc: document.getElementById("p-loc").value,
      ind: document.getElementById("p-ind").value,
      size: document.getElementById("p-size").value,
      tgt: document.getElementById("p-tgt").value,
      bud: document.getElementById("p-bud").value
    };
    localStorage.setItem("cw_profile", JSON.stringify(profile));
    if (currentUser) {
      currentUser.name = profile.name;
      currentUser.email = profile.email;
      document.getElementById("nav-user-name").innerText = profile.name;
    }
    showToast("Profile updated successfully", "success");
  };
  window.cwCancelProfile = function () { renderProfilePage(); showToast("Edits discarded", "info"); };

  window.downloadPdfReport = function () {
    showToast("Generating report…", "info");
    try {
      const fp = E.footprintKg();
      const opt = lastOpt || E.optimize(1000000);
      const date = new Date().toISOString().slice(0, 10);
      const lines = [
        "CARBONWISE INDUSTRIAL",
        "Carbon Intelligence & Sustainability Report",
        "Organization: Guindy Precision Works",
        "Period: " + (typeof currentReportPeriod !== "undefined" ? currentReportPeriod : "monthly"),
        "Generated: " + date,
        "",
        "EXECUTIVE SUMMARY",
        "Total carbon footprint: " + fp.tonnes.toFixed(1) + " t CO2",
        "Electricity: " + (fp.electricity / 1000).toFixed(1) + " t",
        "Fuel: " + (fp.fuel / 1000).toFixed(1) + " t",
        "Logistics: " + (fp.logistics / 1000).toFixed(1) + " t",
        "Production: " + (fp.production / 1000).toFixed(1) + " t",
        "Waste: " + (fp.waste / 1000).toFixed(1) + " t",
        "",
        "AI OPTIMIZATION",
        "Budget: " + E.inr(opt.budget),
        "Recommended investment: " + E.inr(opt.invested),
        "Expected reduction: " + opt.reduced.toFixed(1) + " t/year",
        "Remaining: " + E.inr(opt.remaining),
        "",
        "RECOMMENDED ACTIONS",
        ...opt.selected.map((a) => "- " + a.name + " | " + E.inr(a.cost) + " | " + a.co2 + " t"),
        "",
        "DEVICE STATUS",
        ...state.appliances.map((d) => "- " + d.name + " " + (d.isActive ? "ONLINE" : "STANDBY")),
        "",
        "This file is a generated CarbonWise report."
      ];
      const pdf = buildSimplePdf(lines);
      const blob = new Blob([pdf], { type: "application/pdf" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = "CarbonWise_Carbon_Report_" + date + ".pdf";
      document.body.appendChild(a);
      a.click();
      a.remove();
      showToast("Report generated successfully.", "success");
    } catch (e) {
      showToast("Report generation failed. Retry.", "error");
    }
  };

  function buildSimplePdf(lines) {
    const esc = (s) => s.replace(/\\/g, "\\\\").replace(/\(/g, "\\(").replace(/\)/g, "\\)");
    let y = 800;
    const cmds = ["BT", "/F1 11 Tf", "14 TL"];
    lines.forEach((ln) => {
      cmds.push("1 0 0 1 40 " + y + " Tm", "(" + esc(ln).slice(0, 110) + ") Tj");
      y -= 16;
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
      out += (i + 1) + " 0 obj\n" + obj + "\nendobj\n";
    });
    const start = out.length;
    out += "xref\n0 " + (objects.length + 1) + "\n0000000000 65535 f \n";
    xref.slice(1).forEach((off) => {
      out += String(off).padStart(10, "0") + " 00000 n \n";
    });
    out += "trailer << /Size " + (objects.length + 1) + " /Root 1 0 R >>\nstartxref\n" + start + "\n%%EOF";
    return out;
  }

  const origAdd = window.handleAddDeviceSubmit;
  window.handleAddDeviceSubmit = function (e) {
    e.preventDefault();
    const name = document.getElementById("dev-name").value.trim();
    if (!name) return;
    const newDev = {
      id: document.getElementById("dev-id")?.value || "dev-" + Date.now(),
      name,
      type: document.getElementById("dev-type").value,
      powerRating: parseFloat(document.getElementById("dev-power").value) || 1.5,
      location: document.getElementById("dev-loc")?.value || "Plant Sector A",
      protocol: document.getElementById("dev-proto")?.value || "Simulation",
      isActive: true,
      connecting: false,
      isScheduled: false
    };
    state.appliances.unshift(newDev);
    closeModal("modal-add-device");
    renderFullAppliances();
    showToast(name + " added and ONLINE!", "success");
    document.getElementById("dev-name").value = "";
  };

  const origRenderDev = window.renderFullAppliances;
  window.renderFullAppliances = function () {
    origRenderDev();
    document.querySelectorAll(".appliance-card").forEach((card) => {
      card.style.cursor = "pointer";
      card.addEventListener("click", (ev) => {
        if (ev.target.closest("button, input, label")) return;
        const id = card.id.replace("appliance-", "");
        const d = state.appliances.find((x) => x.id === id);
        if (d) openDeviceDetail(d);
      });
    });
  };

  function openDeviceDetail(d) {
    switchView("device-detail");
    const kg = (d.powerRating * 6 * 0.82).toFixed(1);
    document.getElementById("view-device-detail").innerHTML = `
      <div class="view-header"><div><h1>${d.name}</h1><p class="subtitle">${d.type} · ${d.protocol || "MQTT"} · ${d.location || "Plant"}</p></div>
      <button class="btn-secondary" onclick="switchView('appliances')">Back</button></div>
      <div class="kpi-grid">
        <div class="stat-card"><div class="stat-label">Status</div><div class="stat-value">${d.connecting ? "CONNECTING" : d.isActive ? "ONLINE" : "OFFLINE"}</div></div>
        <div class="stat-card"><div class="stat-label">Power</div><div class="stat-value">${d.powerRating} kW</div></div>
        <div class="stat-card"><div class="stat-label">Carbon impact</div><div class="stat-value">${kg} kg/shift</div></div>
        <div class="stat-card"><div class="stat-label">Last comms</div><div class="stat-value">12s ago</div></div>
      </div>
      <div class="card"><p class="demo-chip">Simulation mode — MQTT commands are not sent to physical hardware</p>
        <p class="why-next" style="margin-top:12px">Recommended: schedule during 14:00–16:00. Expected reduction 4.8 kg CO₂.</p>
        <div class="header-actions" style="margin-top:12px">
          <button class="btn-primary" onclick="showToast('Schedule created (sim)','success')">Schedule</button>
          <button class="btn-secondary" onclick="showToast('Cancelled','info')">Cancel</button>
        </div>
      </div>`;
  }

  document.addEventListener("DOMContentLoaded", () => {
    const p = document.getElementById("view-reports");
    if (p) {
      const tabs = p.querySelector(".report-period-tabs");
      if (tabs && !tabs.dataset.ext) {
        tabs.dataset.ext = "1";
        tabs.insertAdjacentHTML("beforeend",
          `<button class="btn-period-tab" onclick="setReportPeriod('quarterly', this)">Quarterly</button>
           <button class="btn-period-tab" onclick="setReportPeriod('yearly', this)">Yearly</button>`);
      }
    }
  });
})();
