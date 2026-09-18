// CarbonWise Frontend Application Logic - Modern SPA
const API_BASE = "https://carbonwise-application.onrender.com/api";

// App State
let currentUser = null;
let currentView = "dashboard";
let userLeafletMap = null;
let managerLeafletMap = null;
let userEnergyChart = null;
let predictionChart = null;
let managerChart = null;
let mapMarkersGroup = null;
let currentMapFilter = "ALL";
let currentPredictionHorizon = 6;
let currentReportPeriod = "monthly";

// Local Mock Data Store (Synchronized with Backend & Fallback)
const state = {
    appliances: [
        { id: "dev-1", name: "EV Home Charger", type: "EV_CHARGER", powerRating: 7.4, isActive: true, isScheduled: true },
        { id: "dev-2", name: "Living Room AC", type: "AIR_CONDITIONER", powerRating: 1.8, isActive: true, isScheduled: false },
        { id: "dev-3", name: "Smart Washing Machine", type: "WASHING_MACHINE", powerRating: 1.2, isActive: false, isScheduled: true },
        { id: "dev-4", name: "Eco Water Heater", type: "WATER_HEATER", powerRating: 2.5, isActive: false, isScheduled: false }
    ],
    schedules: [
        { id: "sch-1", title: "EV Charging (AI Auto-Pilot)", time: "11:00 AM – 2:00 PM (Solar Peak)", device: "EV Home Charger", saving: "34% CO₂ Saved", isAi: true, enabled: true },
        { id: "sch-2", title: "Dishwasher Eco Wash", time: "1:30 PM – 3:00 PM", device: "Smart Washing Machine", saving: "22% CO₂ Saved", isAi: false, enabled: true }
    ],
    notifications: [
        { id: "notif-1", title: "Optimal Green Charging Active", message: "Grid carbon intensity is currently low (118 gCO₂/kWh). Excellent time to charge EV.", type: "GRID_CLEAN", isRead: false, time: "10 mins ago" },
        { id: "notif-2", title: "AI Scheduled Smart Cycle", message: "Smart Washing Machine scheduled for 1:30 PM today during peak renewable window.", type: "BEST_CHARGING", isRead: false, time: "2 hours ago" },
        { id: "notif-3", title: "Air Quality Normal", message: "All localized IoT environmental sensors are online and within clean thresholds.", type: "DEVICE_COMPLETED", isRead: true, time: "5 hours ago" },
        { id: "notif-4", title: "Monthly Carbon Report Ready", message: "You reduced your carbon footprint by 30% this month. View your report now.", type: "DAILY_REPORT", isRead: true, time: "1 day ago" }
    ],
    sensors: [
        { id: "S-101", name: "Sensor Hub North", lat: 13.0900, lng: 80.2800, co2: 412, pm25: 28, temp: 29.5, status: "ONLINE", type: "AIR_QUALITY" },
        { id: "S-102", name: "Home Gateway #1", lat: 13.0827, lng: 80.2707, co2: 385, pm25: 18, temp: 28.4, status: "ONLINE", type: "HOME_SMART_METER" },
        { id: "S-103", name: "Substation Sensor #4", lat: 13.0500, lng: 80.2500, co2: 460, pm25: 38, temp: 31.0, status: "ONLINE", type: "GRID_MONITOR" },
        { id: "S-104", name: "Solar Farm Collector", lat: 12.9800, lng: 80.2500, co2: 320, pm25: 12, temp: 28.0, status: "ONLINE", type: "RENEWABLE_FEED" },
        { id: "S-105", name: "Industrial Park Node", lat: 13.0100, lng: 80.2200, co2: 590, pm25: 65, temp: 33.2, status: "WARNING", type: "INDUSTRIAL" }
    ],
    heatmaps: [
        { lat: 13.0827, lng: 80.2707, intensity: 118.0, radius: 1400, label: "Chennai Central Clean Hub" },
        { lat: 13.0500, lng: 80.2500, intensity: 142.0, radius: 1600, label: "T. Nagar Commercial Hub" },
        { lat: 13.0850, lng: 80.2100, intensity: 260.0, radius: 1800, label: "Anna Nagar Moderate Zone" },
        { lat: 13.0100, lng: 80.2200, intensity: 380.0, radius: 2000, label: "Guindy Industrial High Load" },
        { lat: 12.9800, lng: 80.2500, intensity: 95.0, radius: 1500, label: "Adyar Green Solar Cluster" },
        { lat: 13.1200, lng: 80.2900, intensity: 410.0, radius: 2200, label: "North Port Heavy Emissions" }
    ],
    houses: [
        { id: 101, name: "House #12 (Solar)", energy: 38, carbon: 11.2, status: "online", alert: false },
        { id: 102, name: "House #45 (EV Active)", energy: 54, carbon: 18.5, status: "online", alert: true },
        { id: 103, name: "House #19", energy: 26, carbon: 7.8, status: "online", alert: false },
        { id: 104, name: "House #88", energy: 42, carbon: 14.1, status: "offline", alert: false },
        { id: 105, name: "House #31", energy: 31, carbon: 9.6, status: "online", alert: false },
        { id: 106, name: "House #94", energy: 62, carbon: 22.4, status: "online", alert: true }
    ]
};

// ==================== TOAST NOTIFICATIONS ====================
function showToast(message, type = "success") {
    const container = document.getElementById("toast-container");
    if (!container) return;
    const toast = document.createElement("div");
    toast.className = `toast ${type}`;
    
    let icon = "fa-check-circle text-green";
    if (type === "error") icon = "fa-triangle-exclamation text-red";
    if (type === "warning") icon = "fa-bell text-yellow";
    if (type === "info") icon = "fa-info-circle text-cyan";

    toast.innerHTML = `<i class="fas ${icon}"></i> <span>${message}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = "0";
        toast.style.transform = "translateX(50px)";
        setTimeout(() => toast.remove(), 300);
    }, 3500);
}

// ==================== AUTHENTICATION ====================
function showLogin() {
    document.getElementById("login-form").classList.remove("hidden");
    document.getElementById("register-form").classList.add("hidden");
}

function showRegister() {
    document.getElementById("login-form").classList.add("hidden");
    document.getElementById("register-form").classList.remove("hidden");
}

function togglePasswordVisibility(inputId, btn) {
    const input = document.getElementById(inputId);
    if (!input) return;
    const isPass = input.type === "password";
    input.type = isPass ? "text" : "password";
    btn.innerHTML = `<i class="fas fa-${isPass ? "eye-slash" : "eye"}"></i>`;
}

function openForgotPassword() {
    const email = document.getElementById("login-email").value.trim() || "user@carbonwise.com";
    showToast(`Password reset instructions sent to ${email}`, "info");
}

async function login() {
    const email = document.getElementById("login-email").value.trim();
    const password = document.getElementById("login-password").value.trim();

    if (!email || !password) {
        showToast("Please enter email and password", "warning");
        return;
    }

    const btn = document.getElementById("btn-login");
    btn.innerHTML = `<i class="fas fa-spinner fa-spin"></i> Signing in...`;
    btn.disabled = true;

    try {
        const res = await fetch(`${API_BASE}/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        });

        if (res.ok) {
            const data = await res.json();
            currentUser = {
                id: data.userId || "user-1",
                email: email,
                name: data.name || email.split("@")[0],
                role: data.role || "CONSUMER",
                token: data.token
            };
        } else {
            // Fallback for offline/demo credentials
            currentUser = {
                id: "user-1",
                email: email,
                name: email === "admin@carbonwise.com" ? "City Area Manager" : "Alex Rivera",
                role: email === "admin@carbonwise.com" ? "CITY_ADMIN" : "CONSUMER",
                token: "mock-jwt-token"
            };
        }
    } catch (_) {
        currentUser = {
            id: "user-1",
            email: email,
            name: email === "admin@carbonwise.com" ? "City Area Manager" : "Alex Rivera",
            role: email === "admin@carbonwise.com" ? "CITY_ADMIN" : "CONSUMER",
            token: "mock-jwt-token"
        };
    }

    btn.innerHTML = `<span>Sign In</span> <i class="fas fa-arrow-right"></i>`;
    btn.disabled = false;

    localStorage.setItem("carbonwise_user", JSON.stringify(currentUser));
    showToast(`Welcome back, ${currentUser.name}!`, "success");
    enterApp();
}

function loginAsDemo(role) {
    if (role === "CITY_ADMIN") {
        currentUser = {
            id: "admin-1",
            email: "admin@carbonwise.com",
            name: "Area Manager",
            role: "CITY_ADMIN",
            token: "mock-admin-token"
        };
    } else {
        currentUser = {
            id: "user-1",
            email: "user@carbonwise.com",
            name: "Alex Rivera",
            role: "CONSUMER",
            token: "mock-user-token"
        };
    }

    localStorage.setItem("carbonwise_user", JSON.stringify(currentUser));
    showToast(`Entering as ${currentUser.role === "CITY_ADMIN" ? "Area Manager" : "Consumer"}`, "info");
    enterApp();
}

async function register() {
    const name = document.getElementById("reg-name").value.trim();
    const email = document.getElementById("reg-email").value.trim();
    const password = document.getElementById("reg-password").value.trim();

    if (!name || !email || !password) {
        showToast("Please fill all required fields", "warning");
        return;
    }

    const btn = document.getElementById("btn-register");
    btn.innerHTML = `<i class="fas fa-spinner fa-spin"></i> Creating...`;
    btn.disabled = true;

    try {
        await fetch(`${API_BASE}/auth/register`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ name, email, password, role: "CONSUMER" })
        });
    } catch (_) {}

    btn.innerHTML = `<span>Create Account</span> <i class="fas fa-user-plus"></i>`;
    btn.disabled = false;

    showToast("Account created successfully! Please sign in.", "success");
    showLogin();
}

function logout() {
    localStorage.removeItem("carbonwise_user");
    currentUser = null;
    document.getElementById("app").classList.add("hidden");
    document.getElementById("auth-screen").classList.remove("hidden");
    closeModal("modal-profile");
    showToast("Logged out successfully", "info");
}

function enterApp() {
    document.getElementById("auth-screen").classList.add("hidden");
    document.getElementById("app").classList.remove("hidden");

    // Update Header Pill
    document.getElementById("nav-user-name").innerText = currentUser.name;
    document.getElementById("nav-user-role").innerText = currentUser.role === "CITY_ADMIN" ? "Area Manager" : "Consumer";
    document.getElementById("greeting-name").innerText = currentUser.name.split(" ")[0];

    buildNavTabs();
    if (currentUser.role === "CITY_ADMIN") {
        switchView("manager");
    } else {
        switchView("dashboard");
    }
}

// ==================== NAVIGATION TABS & VIEWS ====================
function buildNavTabs() {
    const navTabs = document.getElementById("nav-tabs");
    navTabs.innerHTML = "";

    if (currentUser.role === "CITY_ADMIN") {
        navTabs.innerHTML = `
            <button class="nav-tab-btn active" data-view="manager" onclick="switchView('manager')">
                <i class="fas fa-city"></i> Area Hub
            </button>
            <button class="nav-tab-btn" data-view="maps" onclick="switchView('maps')">
                <i class="fas fa-map"></i> Grid Map
            </button>
            <button class="nav-tab-btn" data-view="reports" onclick="switchView('reports')">
                <i class="fas fa-chart-column"></i> Analytics
            </button>
        `;
    } else {
        navTabs.innerHTML = `
            <button class="nav-tab-btn active" data-view="dashboard" onclick="switchView('dashboard')">
                <i class="fas fa-gauge"></i> Overview
            </button>
            <button class="nav-tab-btn" data-view="maps" onclick="switchView('maps')">
                <i class="fas fa-map-marked-alt"></i> Live Map
            </button>
            <button class="nav-tab-btn" data-view="predictions" onclick="switchView('predictions')">
                <i class="fas fa-wand-magic-sparkles"></i> AI Predictions
            </button>
            <button class="nav-tab-btn" data-view="appliances" onclick="switchView('appliances')">
                <i class="fas fa-plug"></i> Appliances
            </button>
            <button class="nav-tab-btn" data-view="scheduler" onclick="switchView('scheduler')">
                <i class="fas fa-clock"></i> Scheduler
            </button>
            <button class="nav-tab-btn" data-view="reports" onclick="switchView('reports')">
                <i class="fas fa-file-lines"></i> Reports
            </button>
        `;
    }
}

function switchView(viewName) {
    currentView = viewName;

    // Hide all views
    document.querySelectorAll(".app-view").forEach(el => el.classList.add("hidden"));

    // Deactivate nav buttons
    document.querySelectorAll(".nav-tab-btn").forEach(btn => {
        btn.classList.toggle("active", btn.getAttribute("data-view") === viewName);
    });

    // Show target view
    const target = document.getElementById(`view-${viewName}`);
    if (target) target.classList.remove("hidden");

    // Trigger view-specific initializers
    if (viewName === "dashboard") initDashboardView();
    if (viewName === "maps") initUserMapView();
    if (viewName === "predictions") initPredictionView();
    if (viewName === "appliances") renderFullAppliances();
    if (viewName === "scheduler") renderSchedulerView();
    if (viewName === "reports") renderReportsView();
    if (viewName === "notifications") renderNotificationsView();
    if (viewName === "manager") initManagerView();

    window.scrollTo({ top: 0, behavior: "smooth" });
}

// ==================== CONSUMER DASHBOARD ====================
function initDashboardView() {
    renderMiniAppliances();
    renderUserEnergyChart();
    updateLiveCarbonGauge(118);
}

function updateLiveCarbonGauge(intensity) {
    const valEl = document.getElementById("gauge-intensity-val");
    const bar = document.getElementById("gauge-progress-bar");
    const badge = document.getElementById("gauge-status-badge");
    if (!valEl || !bar) return;

    valEl.innerText = Math.round(intensity);
    const maxVal = 500;
    const circumference = 502;
    const progress = Math.min(intensity / maxVal, 1);
    const offset = circumference - (progress * circumference * 0.75);
    bar.style.strokeDashoffset = offset;

    if (intensity < 150) {
        bar.style.stroke = "#00f576";
        badge.className = "badge clean";
        badge.innerText = "CLEAN GRID";
    } else if (intensity < 300) {
        bar.style.stroke = "#ffb800";
        badge.className = "badge yellow";
        badge.innerText = "MODERATE";
    } else {
        bar.style.stroke = "#ff3838";
        badge.className = "badge red";
        badge.innerText = "HIGH EMISSION";
    }
}

function renderUserEnergyChart() {
    const canvas = document.getElementById("user-energy-chart");
    if (!canvas) return;
    if (userEnergyChart) userEnergyChart.destroy();

    const ctx = canvas.getContext("2d");
    userEnergyChart = new Chart(ctx, {
        type: "line",
        data: {
            labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            datasets: [
                {
                    label: "Energy (kWh)",
                    data: [48, 52, 41, 63, 55, 49, 34],
                    borderColor: "#00f576",
                    backgroundColor: "rgba(0, 245, 118, 0.1)",
                    fill: true,
                    tension: 0.4,
                    borderWidth: 3,
                    pointRadius: 4,
                    pointBackgroundColor: "#00f576"
                },
                {
                    label: "Carbon (kg CO₂)",
                    data: [16.2, 17.5, 13.8, 21.0, 18.6, 16.4, 11.8],
                    borderColor: "#ff3838",
                    backgroundColor: "rgba(255, 56, 56, 0.05)",
                    fill: true,
                    tension: 0.4,
                    borderWidth: 2,
                    pointRadius: 3,
                    pointBackgroundColor: "#ff3838"
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } },
                y: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } }
            }
        }
    });
}

function renderMiniAppliances() {
    const container = document.getElementById("dash-appliances-list");
    if (!container) return;
    container.innerHTML = state.appliances.slice(0, 3).map(dev => `
        <div class="mini-appliance-item">
            <span><strong>${dev.name}</strong> • ${dev.powerRating} kW</span>
            <span class="badge ${dev.isActive ? "green" : "cyan"}">${dev.isActive ? "RUNNING" : "STANDBY"}</span>
        </div>
    `).join("");
}

function refreshDashboardData() {
    updateLiveCarbonGauge(110 + Math.floor(Math.random() * 25));
    showToast("Dashboard refreshed with latest grid telemetry", "success");
}

// ==================== INTERACTIVE MAP ====================
function initUserMapView() {
    setTimeout(() => {
        if (!userLeafletMap) {
            userLeafletMap = L.map("user-leaflet-map").setView([13.0827, 80.2707], 12);
            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                attribution: "© OpenStreetMap contributors"
            }).addTo(userLeafletMap);

            mapMarkersGroup = L.layerGroup().addTo(userLeafletMap);
        }
        userLeafletMap.invalidateSize();
        renderMapLayers();
    }, 150);
}

function renderMapLayers() {
    if (!mapMarkersGroup) return;
    mapMarkersGroup.clearLayers();

    // 1. Home Marker
    const homeIcon = L.divIcon({
        className: "custom-map-icon",
        html: `<div style="background: #00f576; color: #000; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 16px; box-shadow: 0 0 12px #00f576;"><i class="fas fa-home"></i></div>`,
        iconSize: [32, 32],
        iconAnchor: [16, 16]
    });
    L.marker([13.0827, 80.2707], { icon: homeIcon })
        .addTo(mapMarkersGroup)
        .bindPopup("<strong>Your Smart Home</strong><br>Carbon Intensity: 118 gCO₂/kWh (Clean)");

    // 2. Heatmaps
    if (currentMapFilter === "ALL" || currentMapFilter === "HEATMAP") {
        state.heatmaps.forEach(pt => {
            let color = "#00f576";
            if (pt.intensity >= 300) color = "#ff3838";
            else if (pt.intensity >= 150) color = "#ffb800";

            L.circle([pt.lat, pt.lng], {
                radius: pt.radius,
                color: color,
                fillColor: color,
                fillOpacity: 0.28,
                weight: 2
            }).addTo(mapMarkersGroup).bindPopup(`<strong>${pt.label}</strong><br>Carbon: ${pt.intensity} gCO₂/kWh`);
        });
    }

    // 3. IoT Sensors
    if (currentMapFilter === "ALL" || currentMapFilter === "SENSORS") {
        state.sensors.forEach(s => {
            const isOnline = s.status === "ONLINE";
            const sensorIcon = L.divIcon({
                className: "custom-sensor-icon",
                html: `<div style="background: ${isOnline ? "#00e5ff" : "#ff3838"}; color: #000; width: 26px; height: 26px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; box-shadow: 0 0 8px ${isOnline ? "#00e5ff" : "#ff3838"};"><i class="fas fa-microchip"></i></div>`,
                iconSize: [26, 26],
                iconAnchor: [13, 13]
            });

            const marker = L.marker([s.lat, s.lng], { icon: sensorIcon }).addTo(mapMarkersGroup);
            marker.bindPopup(`<strong>${s.name} (${s.id})</strong><br>CO₂: ${s.co2} ppm • PM2.5: ${s.pm25} µg/m³<br>Temp: ${s.temp}°C • Status: ${s.status}`);
            marker.on("click", () => updateSensorTelemetryBox(s));
        });
    }
}

function updateSensorTelemetryBox(sensor) {
    document.getElementById("selected-sensor-title").innerText = `${sensor.name} (${sensor.id})`;
    document.getElementById("selected-sensor-status").innerText = sensor.status;
    document.getElementById("selected-sensor-status").className = `badge ${sensor.status === "ONLINE" ? "clean" : "red"}`;
    document.getElementById("box-co2").innerText = `${sensor.co2} ppm`;
    document.getElementById("box-pm25").innerText = `${sensor.pm25} µg/m³`;
    document.getElementById("box-temp").innerText = `${sensor.temp} °C`;
    document.getElementById("box-intensity").innerText = "118 gCO₂";
    showToast(`Loaded live telemetry from ${sensor.name}`, "info");
}

function filterMapLayer(layer) {
    currentMapFilter = layer;
    document.querySelectorAll(".map-btn").forEach(b => b.classList.remove("active"));
    if (layer === "ALL") document.getElementById("btn-layer-all")?.classList.add("active");
    if (layer === "HEATMAP") document.getElementById("btn-layer-heat")?.classList.add("active");
    if (layer === "SENSORS") document.getElementById("btn-layer-sensors")?.classList.add("active");
    if (layer === "RISK") document.getElementById("btn-layer-risk")?.classList.add("active");
    renderMapLayers();
}

function resetMapView() {
    if (userLeafletMap) {
        userLeafletMap.setView([13.0827, 80.2707], 13);
        showToast("Centered to Home Location", "info");
    }
}

// ==================== AI PREDICTIONS ====================
function initPredictionView() {
    renderPredictionChart(currentPredictionHorizon);
}

function setPredictionHorizon(hours, btn) {
    currentPredictionHorizon = hours;
    document.querySelectorAll(".btn-time-tab").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    document.getElementById("chart-horizon-label").innerText = `${hours} Hours`;

    if (hours === 6) {
        document.getElementById("pred-charging-time").innerText = "11:00 AM – 2:00 PM";
        document.getElementById("pred-appliance-time").innerText = "1:00 PM – 3:30 PM";
        document.getElementById("pred-recommendation-text").innerText = "Shift high wattage loads to 11:00 AM - 2:00 PM. Grid carbon intensity is projected to drop below 110 gCO₂/kWh due to regional solar peaks.";
    } else if (hours === 12) {
        document.getElementById("pred-charging-time").innerText = "10:30 AM – 2:30 PM";
        document.getElementById("pred-appliance-time").innerText = "12:00 PM – 2:00 PM";
        document.getElementById("pred-recommendation-text").innerText = "Midday solar generation exceeds 65% of grid feed. Best 12-hour carbon savings index occurs between 11 AM and 2 PM.";
    } else {
        document.getElementById("pred-charging-time").innerText = "Tomorrow 10:00 AM – 2:00 PM";
        document.getElementById("pred-appliance-time").innerText = "Tomorrow 11:30 AM – 1:30 PM";
        document.getElementById("pred-recommendation-text").innerText = "24-Hour outlook indicates clear sunny conditions tomorrow with 35% lower emissions during peak solar hours.";
    }

    renderPredictionChart(hours);
    showToast(`Updated AI forecast model for ${hours} hours`, "info");
}

function renderPredictionChart(hours) {
    const canvas = document.getElementById("prediction-chart");
    if (!canvas) return;
    if (predictionChart) predictionChart.destroy();

    const labels = [];
    const intensityData = [];
    const baseHour = 9;

    for (let i = 0; i < hours; i++) {
        const h = (baseHour + i) % 24;
        const ampm = h >= 12 ? "PM" : "AM";
        const displayH = h % 12 === 0 ? 12 : h % 12;
        labels.push(`${displayH} ${ampm}`);

        // Dip during 11AM - 2PM solar peak
        if (h >= 11 && h <= 14) {
            intensityData.push(95 + Math.floor(Math.random() * 15));
        } else if (h >= 18 && h <= 21) {
            intensityData.push(290 + Math.floor(Math.random() * 30)); // Evening peak
        } else {
            intensityData.push(160 + Math.floor(Math.random() * 25));
        }
    }

    const ctx = canvas.getContext("2d");
    predictionChart = new Chart(ctx, {
        type: "line",
        data: {
            labels: labels,
            datasets: [{
                label: "Predicted Carbon (gCO₂/kWh)",
                data: intensityData,
                borderColor: "#00e5ff",
                backgroundColor: "rgba(0, 229, 255, 0.12)",
                fill: true,
                tension: 0.35,
                borderWidth: 3,
                pointBackgroundColor: "#00e5ff"
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } },
                y: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } }
            }
        }
    });
}

// ==================== APPLIANCES MANAGEMENT ====================
function renderFullAppliances() {
    const container = document.getElementById("full-appliances-grid");
    if (!container) return;

    container.innerHTML = state.appliances.map(dev => {
        let icon = "fa-plug";
        if (dev.type === "EV_CHARGER") icon = "fa-car-side";
        if (dev.type === "AIR_CONDITIONER") icon = "fa-snowflake";
        if (dev.type === "WASHING_MACHINE") icon = "fa-soap";
        if (dev.type === "WATER_HEATER") icon = "fa-water";

        return `
            <div class="appliance-card" id="appliance-${dev.id}">
                <div class="appliance-top">
                    <div class="appliance-icon ${dev.isActive ? "" : "inactive"}">
                        <i class="fas ${icon}"></i>
                    </div>
                    <button class="btn-icon-small" onclick="deleteAppliance('${dev.id}')" title="Delete Appliance">
                        <i class="fas fa-trash-alt text-red"></i>
                    </button>
                </div>
                <div class="appliance-info">
                    <h4>${dev.name}</h4>
                    <p>${dev.type.replace(/_/g, " ")} • Rated Power</p>
                </div>
                <div class="appliance-bottom">
                    <span class="wattage-tag">${dev.powerRating} kW</span>
                    <label class="switch-toggle">
                        <input type="checkbox" ${dev.isActive ? "checked" : ""} onchange="toggleApplianceState('${dev.id}', this.checked)">
                        <span class="slider"></span>
                    </label>
                </div>
            </div>
        `;
    }).join("");
}

function toggleApplianceState(id, isActive) {
    const dev = state.appliances.find(d => d.id === id);
    if (dev) {
        dev.isActive = isActive;
        showToast(`${dev.name} turned ${isActive ? "ON" : "OFF"}`, isActive ? "success" : "info");
        renderFullAppliances();
    }
}

function deleteAppliance(id) {
    const idx = state.appliances.findIndex(d => d.id === id);
    if (idx !== -1) {
        const name = state.appliances[idx].name;
        state.appliances.splice(idx, 1);
        renderFullAppliances();
        showToast(`${name} removed successfully`, "info");
    }
}

function openAddDeviceModal() {
    openModal("modal-add-device");
}

function handleAddDeviceSubmit(e) {
    e.preventDefault();
    const name = document.getElementById("dev-name").value.trim();
    const type = document.getElementById("dev-type").value;
    const power = parseFloat(document.getElementById("dev-power").value) || 1.5;

    if (!name) return;

    const newDev = {
        id: `dev-${Date.now()}`,
        name: name,
        type: type,
        powerRating: power,
        isActive: true,
        isScheduled: false
    };

    state.appliances.push(newDev);
    closeModal("modal-add-device");
    renderFullAppliances();
    showToast(`Added ${name} successfully!`, "success");
    document.getElementById("dev-name").value = "";
}

// ==================== SCHEDULER ====================
function renderSchedulerView() {
    const container = document.getElementById("schedules-list");
    if (!container) return;

    document.getElementById("active-schedules-count").innerText = `${state.schedules.filter(s => s.enabled).length} Active`;

    container.innerHTML = state.schedules.map((sch, i) => `
        <div class="schedule-item">
            <div class="schedule-left">
                <i class="fas ${sch.isAi ? "fa-wand-magic-sparkles text-green" : "fa-clock text-cyan"} schedule-icon"></i>
                <div class="schedule-info">
                    <h4>${sch.title}</h4>
                    <p>${sch.device} • ${sch.time}</p>
                    <span class="schedule-badge">${sch.saving}</span>
                </div>
            </div>
            <label class="switch-toggle">
                <input type="checkbox" ${sch.enabled ? "checked" : ""} onchange="toggleScheduleState(${i}, this.checked)">
                <span class="slider"></span>
            </label>
        </div>
    `).join("");
}

function toggleScheduleState(index, enabled) {
    if (state.schedules[index]) {
        state.schedules[index].enabled = enabled;
        showToast(`${state.schedules[index].title} ${enabled ? "activated" : "paused"}`, "info");
        renderSchedulerView();
    }
}

function openManualScheduleModal() {
    const select = document.getElementById("sched-device-select");
    if (select) {
        select.innerHTML = state.appliances.map(a => `<option value="${a.name}">${a.name}</option>`).join("");
    }
    openModal("modal-manual-schedule");
}

function handleManualScheduleSubmit(e) {
    e.preventDefault();
    const device = document.getElementById("sched-device-select").value;
    const start = document.getElementById("sched-start-time").value;
    const end = document.getElementById("sched-end-time").value;

    state.schedules.push({
        id: `sch-${Date.now()}`,
        title: `${device} Custom Schedule`,
        time: `${start} – ${end}`,
        device: device,
        saving: "18% CO₂ Saved",
        isAi: false,
        enabled: true
    });

    closeModal("modal-manual-schedule");
    renderSchedulerView();
    showToast(`Manual schedule set for ${device}!`, "success");
}

function openAiScheduleModal() {
    const select = document.getElementById("ai-sched-device-select");
    if (select) {
        select.innerHTML = state.appliances.map(a => `<option value="${a.name}">${a.name}</option>`).join("");
    }
    openModal("modal-ai-schedule");
}

function handleAiScheduleSubmit(e) {
    e.preventDefault();
    const device = document.getElementById("ai-sched-device-select").value;

    state.schedules.unshift({
        id: `sch-${Date.now()}`,
        title: `${device} (AI Auto-Pilot)`,
        time: "11:00 AM – 2:00 PM (Solar Peak)",
        device: device,
        saving: "34% CO₂ Saved",
        isAi: true,
        enabled: true
    });

    closeModal("modal-ai-schedule");
    renderSchedulerView();
    showToast(`AI Eco-Schedule enabled for ${device}!`, "success");
}

// ==================== CARBON REPORTS ====================
function renderReportsView() {
    const p = currentReportPeriod;
    document.getElementById("report-period-title").innerText = p.charAt(0).toUpperCase() + p.slice(1);

    let used = 287.0, saved = 86.1, kwh = 350, ren = "57%";
    if (p === "daily") { used = 12.4; saved = 4.2; kwh = 18; ren = "68%"; }
    if (p === "weekly") { used = 84.6; saved = 28.5; kwh = 122; ren = "62%"; }

    document.getElementById("rep-carbon-used").innerText = `${used.toFixed(1)} kg CO₂`;
    document.getElementById("rep-carbon-saved").innerText = `${saved.toFixed(1)} kg CO₂`;
    document.getElementById("rep-electricity").innerText = `${kwh} kWh`;
    document.getElementById("rep-renewable").innerText = ren;

    const table = document.getElementById("report-appliance-table");
    if (table) {
        table.innerHTML = `
            <div class="table-row"><strong>Appliance</strong><strong>CO₂ Load</strong><strong>Avoided</strong></div>
            <div class="table-row"><span>EV Home Charger</span><span>${(used * 0.4).toFixed(1)} kg</span><span class="text-green">${(saved * 0.45).toFixed(1)} kg</span></div>
            <div class="table-row"><span>Living Room AC</span><span>${(used * 0.3).toFixed(1)} kg</span><span class="text-green">${(saved * 0.25).toFixed(1)} kg</span></div>
            <div class="table-row"><span>Washing Machine</span><span>${(used * 0.18).toFixed(1)} kg</span><span class="text-green">${(saved * 0.2).toFixed(1)} kg</span></div>
            <div class="table-row"><span>Water Heater</span><span>${(used * 0.12).toFixed(1)} kg</span><span class="text-green">${(saved * 0.1).toFixed(1)} kg</span></div>
        `;
    }
}

function setReportPeriod(period, btn) {
    currentReportPeriod = period;
    document.querySelectorAll(".btn-period-tab").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    renderReportsView();
}

function downloadPdfReport() {
    showToast(`Generating ${currentReportPeriod.toUpperCase()} ESG PDF Report...`, "info");
    setTimeout(() => {
        showToast("CarbonWise ESG Report saved to your downloads folder!", "success");
    }, 1200);
}

// ==================== NOTIFICATIONS ====================
function renderNotificationsView() {
    const list = document.getElementById("full-notifications-list");
    if (!list) return;

    const unread = state.notifications.filter(n => !n.isRead).length;
    const badgeCount = document.getElementById("notif-badge-count");
    if (badgeCount) badgeCount.innerText = unread;

    list.innerHTML = state.notifications.map(n => `
        <div class="notification-item ${n.isRead ? "" : "unread"}" onclick="markNotificationRead('${n.id}')">
            <div class="notif-left">
                <i class="fas ${getNotifIcon(n.type)} notif-icon"></i>
                <div class="notif-info">
                    <h4>${n.title}</h4>
                    <p>${n.message}</p>
                </div>
            </div>
            <span class="notif-time">${n.time}</span>
        </div>
    `).join("");
}

function getNotifIcon(type) {
    if (type === "GRID_CLEAN") return "fa-bolt text-green";
    if (type === "BEST_CHARGING") return "fa-car-side text-cyan";
    if (type === "DAILY_REPORT") return "fa-file-lines text-yellow";
    return "fa-bell text-cyan";
}

function markNotificationRead(id) {
    const n = state.notifications.find(item => item.id === id);
    if (n) {
        n.isRead = true;
        renderNotificationsView();
        showToast(`Opened: ${n.title}`, "info");
    }
}

function markAllNotificationsRead() {
    state.notifications.forEach(n => n.isRead = true);
    renderNotificationsView();
    showToast("All notifications marked as read", "success");
}

// ==================== AREA MANAGER ====================
function initManagerView() {
    renderHouseGrid();
    renderManagerChart();
    initManagerMap();
}

function initManagerMap() {
    setTimeout(() => {
        if (!managerLeafletMap) {
            managerLeafletMap = L.map("manager-leaflet-map").setView([13.05, 80.25], 11);
            L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                attribution: "© OpenStreetMap contributors"
            }).addTo(managerLeafletMap);

            state.sensors.forEach((pos, i) => {
                L.circleMarker([pos.lat, pos.lng], {
                    radius: 8,
                    color: i % 2 === 0 ? "#00f576" : "#ff3838",
                    fillOpacity: 0.9
                }).addTo(managerLeafletMap).bindPopup(`<strong>${pos.name}</strong><br>Status: ${pos.status}`);
            });
        }
        managerLeafletMap.invalidateSize();
    }, 150);
}

function renderManagerChart() {
    const canvas = document.getElementById("manager-chart");
    if (!canvas) return;
    if (managerChart) managerChart.destroy();

    const ctx = canvas.getContext("2d");
    managerChart = new Chart(ctx, {
        type: "bar",
        data: {
            labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            datasets: [
                { label: "CO₂ Emission (kg)", data: [1240, 980, 1320, 1150, 890, 1420, 780], backgroundColor: "#ff3838", borderRadius: 6 },
                { label: "Clean Energy (MWh)", data: [42, 38, 51, 47, 35, 55, 29], backgroundColor: "#00f576", borderRadius: 6 }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                x: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } },
                y: { grid: { color: "rgba(255, 255, 255, 0.05)" }, ticks: { color: "#94a3b8" } }
            }
        }
    });
}

function renderHouseGrid(filteredHouses) {
    const container = document.getElementById("house-grid");
    if (!container) return;

    const list = filteredHouses || state.houses;
    container.innerHTML = list.map(h => `
        <div class="house-card ${h.alert ? "alert" : ""}">
            <div class="house-header">
                <span>${h.name}</span>
                <span class="dot ${h.status === "online" ? "green" : "red"}"></span>
            </div>
            <div class="house-stats">
                <span><i class="fas fa-bolt text-yellow"></i> ${h.energy} kWh</span>
                <span><i class="fas fa-cloud text-red"></i> ${h.carbon} kg CO₂</span>
            </div>
            <div class="house-footer">
                <span class="badge ${h.status === "online" ? "clean" : "red"}">${h.status.toUpperCase()}</span>
                ${h.alert ? `<span class="badge red">High Load Alert</span>` : `<span class="badge cyan">Optimal</span>`}
            </div>
        </div>
    `).join("");
}

function filterHouses(val) {
    const term = val.toLowerCase();
    const filtered = state.houses.filter(h => h.name.toLowerCase().includes(term));
    renderHouseGrid(filtered);
}

function refreshHouses() {
    showToast("Synchronized live house telemetry", "success");
    renderHouseGrid();
}

function changeDistrict(name) {
    document.getElementById("manager-area-name").innerText = name;
    showToast(`Switched sector to ${name}`, "info");
}

// ==================== USER PROFILE & MODALS ====================
function openProfileModal() {
    if (!currentUser) return;
    document.getElementById("prof-name").innerText = currentUser.name;
    document.getElementById("prof-email").innerText = currentUser.email;
    document.getElementById("prof-role").innerText = currentUser.role === "CITY_ADMIN" ? "City Area Manager" : "Home Energy Consumer";
    document.getElementById("prof-devices-count").innerText = state.appliances.length;
    document.getElementById("toggle-role-label").innerText = currentUser.role === "CITY_ADMIN" ? "Consumer View" : "Area Manager View";
    openModal("modal-profile");
}

function switchRoleToggle() {
    if (currentUser.role === "CITY_ADMIN") {
        currentUser.role = "CONSUMER";
    } else {
        currentUser.role = "CITY_ADMIN";
    }
    localStorage.setItem("carbonwise_user", JSON.stringify(currentUser));
    closeModal("modal-profile");
    enterApp();
    showToast(`Switched role to ${currentUser.role === "CITY_ADMIN" ? "Area Manager" : "Consumer"}`, "success");
}

function openModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove("hidden");
}

function closeModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.add("hidden");
}

// ==================== APP BOOTSTRAP ====================
document.addEventListener("DOMContentLoaded", () => {
    // Check saved session or pre-login
    const saved = localStorage.getItem("carbonwise_user");
    if (saved) {
        try {
            currentUser = JSON.parse(saved);
            enterApp();
        } catch (_) {
            currentUser = null;
        }
    }
});