// script.js - CarbonWise AI Platform Logic

document.addEventListener("DOMContentLoaded", () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // ==========================================
    // TOAST NOTIFICATIONS
    // ==========================================
    const toastContainer = document.getElementById("toastContainer");
    
    function showToast(message, iconName = "check-circle") {
        const toast = document.createElement("div");
        toast.className = "toast";
        toast.innerHTML = `<i data-lucide="${iconName}"></i> <span>${message}</span>`;
        toastContainer.appendChild(toast);
        lucide.createIcons({ node: toast });

        setTimeout(() => {
            toast.classList.add("removing");
            setTimeout(() => {
                toast.remove();
            }, 400);
        }, 3000);
    }

    // ==========================================
    // TAB SYSTEM NAVIGATION
    // ==========================================
    const navButtons = document.querySelectorAll(".nav-btn");
    const tabContents = document.querySelectorAll(".tab-content");
    const tabTitle = document.getElementById("tabTitle");
    const tabSubtitle = document.getElementById("tabSubtitle");

    const tabDescriptions = {
        "tab-overview": {
            title: "Grid Overview",
            subtitle: "Real-time tracking of carbon intensity, grid mix, and emission optimization indicators."
        },
        "tab-appliances": {
            title: "Appliance Scheduler",
            subtitle: "Automatically align heavy household appliance loads with grid carbon drops to reduce carbon footprint."
        },
        "tab-city": {
            title: "City Spatial Grid Map",
            subtitle: "GIS mapping overlay exposing carbon hotspots, wind dispersion plumes, and mitigation planning."
        },
        "tab-rewards": {
            title: "Eco Rewards & Offsets",
            subtitle: "Earn virtual carbon credits and redeem them for environmental projects or utility credits."
        }
    };

    navButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            // Remove active classes
            navButtons.forEach(b => b.classList.remove("active"));
            tabContents.forEach(c => c.classList.remove("active"));

            // Add active class to clicked button
            btn.classList.add("active");
            const tabId = btn.getAttribute("data-tab");
            const contentTab = document.getElementById(tabId);
            contentTab.classList.add("active");

            // Update Header titles
            const meta = tabDescriptions[tabId];
            if (meta) {
                tabTitle.textContent = meta.title;
                tabSubtitle.textContent = meta.subtitle;
            }

            // Custom tab initializations
            if (tabId === "tab-city") {
                initializeCityMap();
            }
        });
    });

    // ==========================================
    // TAB 1: LIVE CARBON DIAL GAUGE SIMULATOR
    // ==========================================
    const liveIntensityVal = document.getElementById("liveIntensity");
    const gaugeFill = document.getElementById("gaugeFill");
    const intensityStatusText = document.getElementById("intensityStatusText");
    const headerCarbonLabel = document.getElementById("headerCarbonLabel");

    const mixSolarWind = document.getElementById("mixSolarWind");
    const mixHydro = document.getElementById("mixHydro");
    const mixGas = document.getElementById("mixGas");
    const mixCoal = document.getElementById("mixCoal");

    const mixBarSolarWind = document.getElementById("mixBarSolarWind");
    const mixBarHydro = document.getElementById("mixBarHydro");
    const mixBarGas = document.getElementById("mixBarGas");
    const mixBarCoal = document.getElementById("mixBarCoal");

    let currentIntensity = 145; // base

    function updateCarbonIntensityDial() {
        // Add subtle fluctuations
        const fluctuation = Math.floor((Math.random() - 0.5) * 16);
        currentIntensity = Math.max(80, Math.min(480, currentIntensity + fluctuation));
        
        liveIntensityVal.textContent = currentIntensity;

        // Animate Gauge SVG stroke-dashoffset
        // Stroke dasharray is 125.6 (representing the arc). We divide by max intensity 500.
        const maxIntensity = 500;
        const fillPercentage = currentIntensity / maxIntensity;
        const offset = 125.6 - (fillPercentage * 125.6);
        gaugeFill.style.strokeDashoffset = offset;

        // Update color text and headers based on levels
        if (currentIntensity < 180) {
            intensityStatusText.textContent = "Optimal Carbon Mix";
            intensityStatusText.className = "status green";
            headerCarbonLabel.innerHTML = `<i data-lucide="check-circle"></i> Clean Energy Window`;
            headerCarbonLabel.className = "val green";
        } else if (currentIntensity < 300) {
            intensityStatusText.textContent = "Standard Grid Mix";
            intensityStatusText.className = "status yellow";
            headerCarbonLabel.innerHTML = `<i data-lucide="info"></i> Standard Intensity`;
            headerCarbonLabel.className = "val yellow";
        } else {
            intensityStatusText.textContent = "Dirty Grid Mix (Heavy Coal)";
            intensityStatusText.className = "status red";
            headerCarbonLabel.innerHTML = `<i data-lucide="alert-triangle"></i> Grid Emission Warning`;
            headerCarbonLabel.className = "val red";
        }
        lucide.createIcons({ node: headerCarbonLabel });

        // Update grid generation mixes slightly
        updateGridMixBars(currentIntensity);
    }

    function updateGridMixBars(intensity) {
        // Approximate mixes matching intensity levels
        let solarPercentage = Math.round(55 - (intensity / 10));
        solarPercentage = Math.max(5, Math.min(85, solarPercentage));

        let coalPercentage = Math.round((intensity / 10) - 5);
        coalPercentage = Math.max(5, Math.min(80, coalPercentage));

        const remaining = 100 - (solarPercentage + coalPercentage);
        const hydroPercentage = Math.round(remaining * 0.3);
        const gasPercentage = 100 - (solarPercentage + coalPercentage + hydroPercentage);

        // Update labels
        mixSolarWind.textContent = `${solarPercentage}%`;
        mixHydro.textContent = `${hydroPercentage}%`;
        mixGas.textContent = `${gasPercentage}%`;
        mixCoal.textContent = `${coalPercentage}%`;

        // Update bar widths
        mixBarSolarWind.style.width = `${solarPercentage}%`;
        mixBarHydro.style.width = `${hydroPercentage}%`;
        mixBarGas.style.width = `${gasPercentage}%`;
        mixBarCoal.style.width = `${coalPercentage}%`;
    }

    // Set interval to run dial updates
    setInterval(updateCarbonIntensityDial, 4000);
    updateCarbonIntensityDial(); // run initial

    // ==========================================
    // TAB 2: APPLIANCE SCHEDULER (B2C)
    // ==========================================
    const masterAutomationToggle = document.getElementById("masterAutomationToggle");
    const applianceToggles = document.querySelectorAll(".appliance-toggle");

    // Device status mapping
    const deviceConfigs = {
        ev: {
            cardId: "card-ev",
            statusId: "status-ev",
            windowId: "window-ev",
            rating: "7.2 kW",
            co2Weight: 3.4, // kg CO2 shifted
            title: "Electric Vehicle Charger",
            manualText: "Charging Now (Grid Peak)",
            manualClass: "status-badge red",
            manualGlow: "border-glow-red",
            autoText: "Auto-scheduled (2:00 PM Window)",
            autoClass: "status-badge green",
            autoGlow: "border-glow-green",
            autoWindow: "2:00 PM (Solar Peak)",
            manualWindow: "Immediate"
        },
        hvac: {
            cardId: "card-hvac",
            statusId: "status-hvac",
            windowId: "window-hvac",
            rating: "3.5 kW",
            co2Weight: 1.1,
            title: "Smart Heat Pump",
            manualText: "Active cooling cycle",
            manualClass: "status-badge yellow",
            manualGlow: "border-glow-yellow",
            autoText: "Eco Pre-cooling Active",
            autoClass: "status-badge green",
            autoGlow: "border-glow-green",
            autoWindow: "Dynamic optimization active",
            manualWindow: "Manual control"
        },
        laundry: {
            cardId: "card-laundry",
            statusId: "status-laundry",
            windowId: "window-laundry",
            rating: "2.0 kW",
            co2Weight: 1.2,
            title: "Washing Machine & Dryer",
            manualText: "Idle (Standby)",
            manualClass: "status-badge grey",
            manualGlow: "border-glow-grey",
            autoText: "Delayed start (2:30 PM Window)",
            autoClass: "status-badge green",
            autoGlow: "border-glow-green",
            autoWindow: "2:30 PM (Clean Window)",
            manualWindow: "Waiting for delay"
        }
    };

    let activeAutomations = { ev: false, hvac: false, laundry: false };

    applianceToggles.forEach(toggle => {
        toggle.addEventListener("change", () => {
            const device = toggle.getAttribute("data-device");
            handleDeviceToggleChange(device, toggle.checked);
            recalculateWalletPoints();
        });
    });

    masterAutomationToggle.addEventListener("change", () => {
        const isChecked = masterAutomationToggle.checked;
        applianceToggles.forEach(toggle => {
            toggle.checked = isChecked;
            const device = toggle.getAttribute("data-device");
            handleDeviceToggleChange(device, isChecked);
        });
        recalculateWalletPoints();
    });

    function handleDeviceToggleChange(device, isChecked) {
        const config = deviceConfigs[device];
        if (!config) return;

        const card = document.getElementById(config.cardId);
        const statusSpan = document.getElementById(config.statusId);
        const windowSpan = document.getElementById(config.windowId);

        activeAutomations[device] = isChecked;

        if (isChecked) {
            // Apply Auto-pilot styles
            card.className = `appliance-card ${config.autoGlow}`;
            statusSpan.textContent = config.autoText;
            statusSpan.className = config.autoClass;
            windowSpan.textContent = config.autoWindow;
            showToast(`${config.title} rescheduled to optimal clean energy window!`, "check-circle");
        } else {
            // Apply Manual default styles
            card.className = `appliance-card ${config.manualGlow}`;
            statusSpan.textContent = config.manualText;
            statusSpan.className = config.manualClass;
            windowSpan.textContent = config.manualWindow;
            showToast(`${config.title} automation disabled. Running immediate mode.`, "info");
        }
        
        // Sync master toggle if all are checked/unchecked
        const allChecked = Array.from(applianceToggles).every(t => t.checked);
        masterAutomationToggle.checked = allChecked;
    }

    // Impact Calculator
    const calcState = document.getElementById("calcState");
    const calcBill = document.getElementById("calcBill");
    const calcBaseCo2 = document.getElementById("calcBaseCo2");
    const calcSavedCo2 = document.getElementById("calcSavedCo2");

    const emissionFactors = {
        tn: 0.82, // kg CO2 per kWh
        ka: 0.25,
        mh: 0.65
    };

    function recalculateCarbonReduction() {
        const factor = emissionFactors[calcState.value] || 0.6;
        const monthlyKwh = parseFloat(calcBill.value) || 0;
        
        const baseCo2 = monthlyKwh * factor;
        const savedCo2 = baseCo2 * 0.30; // avg 30% reduction by load shifting

        calcBaseCo2.textContent = `${baseCo2.toFixed(1)} kg CO₂`;
        calcSavedCo2.textContent = `${savedCo2.toFixed(1)} kg CO₂ (-30%)`;
    }

    calcState.addEventListener("change", recalculateCarbonReduction);
    calcBill.addEventListener("input", recalculateCarbonReduction);
    recalculateCarbonReduction(); // run initial

    // ==========================================
    // TAB 3: SMART CITY GIS GRID (B2G)
    // ==========================================
    const cityGisGrid = document.getElementById("cityGisGrid");
    
    const btnOverlayKriging = document.getElementById("btnOverlayKriging");
    const btnOverlayWind = document.getElementById("btnOverlayWind");
    const btnToolBrush = document.getElementById("btnToolBrush");

    const lblGisVirtualNodes = document.getElementById("lblGisVirtualNodes");
    const lblGisHotspots = document.getElementById("lblGisHotspots");
    const lblGisMitigations = document.getElementById("lblGisMitigations");

    const mapTooltipCard = document.getElementById("mapTooltipCard");
    const mapTooltipText = document.getElementById("mapTooltipText");

    // Grid details
    const totalGisCells = 144; // 12x12
    const gisPhysicalSensors = [28, 54, 89, 115]; // indexes
    const hotspotHubs = [
        { center: 20, radius: 2.2, label: "Industrial Plant Alpha" },
        { center: 111, radius: 1.8, label: "Highway Interchange Beta" }
    ];

    let gisMapRendered = false;
    let krigingActive = false;
    let windActive = false;
    let mitigationPlantedCells = new Set();

    function initializeCityMap() {
        if (gisMapRendered) return;
        cityGisGrid.innerHTML = "";

        for (let i = 0; i < totalGisCells; i++) {
            const cell = document.createElement("div");
            cell.className = "gis-cell";
            cell.setAttribute("data-index", i);

            // Mark physical sensors
            if (gisPhysicalSensors.includes(i)) {
                cell.classList.add("sensor-phys");
            }

            // Click listener for details inspection or planting trees
            cell.addEventListener("click", () => handleCellClick(i, cell));

            cityGisGrid.appendChild(cell);
        }
        gisMapRendered = true;
    }

    function handleCellClick(index, cell) {
        const cellX = index % 12;
        const cellY = Math.floor(index / 12);

        // If Mitigation Tool is active, let them plant trees
        if (btnToolBrush.classList.contains("active")) {
            if (cell.classList.contains("sensor-phys")) {
                showToast("Cannot overlay mitigation on active physical sensor nodes.", "alert-triangle");
                return;
            }
            if (mitigationPlantedCells.has(index)) {
                // remove trees
                mitigationPlantedCells.delete(index);
                cell.classList.remove("mitigation-green");
                showToast("Mitigation buffer removed.", "info");
            } else {
                // Plant trees
                mitigationPlantedCells.add(index);
                cell.classList.add("mitigation-green");
                showToast("Buffer trees planted! +20 Eco Points awarded.", "leaf");
                addEcoWalletPoints(20);
            }
            
            lblGisMitigations.textContent = `${mitigationPlantedCells.size} Cells`;
            updateCellTelemetryDisplay(index);
            
            // Recalculate heatmap grid values around this point if Kriging is active
            if (krigingActive) {
                runKrigingHeatmapSweep();
            }
            return;
        }

        // Just inspect cell details
        updateCellTelemetryDisplay(index);
    }

    function updateCellTelemetryDisplay(index) {
        const cellX = index % 12;
        const cellY = Math.floor(index / 12);
        
        let typeText = "Virtual Grid Coordinate";
        let carbonValue = 180 + Math.round((Math.random() - 0.5) * 40);
        let aqi = "Good";

        if (gisPhysicalSensors.includes(index)) {
            typeText = "Physical Monitoring Station";
            carbonValue = 210; // hardware reading
        } else if (mitigationPlantedCells.has(index)) {
            typeText = "Mitigation Buffer Zone (Active)";
            carbonValue = 90; // reduced by trees
        } else if (krigingActive) {
            typeText = "AI Interpolated Virtual Node";
            carbonValue = calculateCarbonEmissionsValue(index);
        }

        if (carbonValue > 380) {
            aqi = "Hazardous (Hotspot)";
        } else if (carbonValue > 250) {
            aqi = "Moderate (Pollution Alert)";
        } else {
            aqi = "Good / Clean Air";
        }

        mapTooltipCard.innerHTML = `
            <h4>Cell Telemetry [X:${cellX}, Y:${cellY}]</h4>
            <p><strong>Type:</strong> ${typeText}</p>
            <p><strong>Emissions Level:</strong> <span class="${carbonValue > 250 ? 'accent-red' : 'accent-green'}">${carbonValue} ppm (CO₂)</span></p>
            <p><strong>Air Quality Index:</strong> ${aqi}</p>
        `;
    }

    function calculateCarbonEmissionsValue(index) {
        // Math to calculate emissions based on hotspots and mitigations
        const cellX = index % 12;
        const cellY = Math.floor(index / 12);

        let value = 140; // baseline

        // Add from hotspot Alpha
        const alphaX = 20 % 12;
        const alphaY = Math.floor(20 / 12);
        const distAlpha = Math.sqrt((cellX - alphaX)**2 + (cellY - alphaY)**2);
        if (distAlpha <= hotspotHubs[0].radius + 1) {
            value += Math.round(300 / (distAlpha + 0.8));
        }

        // Add from hotspot Beta
        const betaX = 111 % 12;
        const betaY = Math.floor(111 / 12);
        const distBeta = Math.sqrt((cellX - betaX)**2 + (cellY - betaY)**2);
        if (distBeta <= hotspotHubs[1].radius + 1) {
            value += Math.round(260 / (distBeta + 0.8));
        }

        // Subtract for close mitigation cells
        mitigationPlantedCells.forEach((mitIndex) => {
            const mitX = mitIndex % 12;
            const mitY = Math.floor(mitIndex / 12);
            const distMit = Math.sqrt((cellX - mitX)**2 + (cellY - mitY)**2);
            if (distMit < 2) {
                value = Math.max(60, value - Math.round(120 / (distMit + 0.5)));
            }
        });

        return value;
    }

    // Kriging Interpolation toggle
    btnOverlayKriging.addEventListener("click", () => {
        krigingActive = !krigingActive;
        btnOverlayKriging.classList.toggle("active", krigingActive);

        if (krigingActive) {
            runKrigingHeatmapSweep();
            lblGisVirtualNodes.textContent = "140 Virtual Nodes";
            lblGisHotspots.textContent = "2 Active Hubs";
            showToast("AI spatial kriging loaded. 140 virtual sensors generated.");
        } else {
            // Remove heat classes
            const cells = document.querySelectorAll(".gis-cell");
            cells.forEach(c => c.classList.remove("heat-green", "heat-yellow", "heat-red"));
            lblGisVirtualNodes.textContent = "--";
            lblGisHotspots.textContent = "--";
            showToast("AI spatial mapping disabled.");
        }
    });

    function runKrigingHeatmapSweep() {
        const cells = document.querySelectorAll(".gis-cell");
        cells.forEach((cell, idx) => {
            if (gisPhysicalSensors.includes(idx)) return;
            
            // clear old levels
            cell.classList.remove("heat-green", "heat-yellow", "heat-red");

            // calculate value
            const emissions = calculateCarbonEmissionsValue(idx);

            // Add delay wave effect based on column coordinates
            const colX = idx % 12;
            cell.style.transitionDelay = `${colX * 30}ms`;

            if (emissions > 320) {
                cell.classList.add("heat-red");
            } else if (emissions > 220) {
                cell.classList.add("heat-yellow");
            } else {
                cell.classList.add("heat-green");
            }
        });
    }

    // Wind Dispersion toggle
    btnOverlayWind.addEventListener("click", () => {
        windActive = !windActive;
        btnOverlayWind.classList.toggle("active", windActive);

        if (windActive) {
            cityGisGrid.classList.add("wind-active");
            showToast("Dispersion active: Plumes dispersing North-East.", "wind");
        } else {
            cityGisGrid.classList.remove("wind-active");
            showToast("Wind dispersion simulation stopped.");
        }
    });

    // Mitigation Brush Tool Toggle
    btnToolBrush.addEventListener("click", () => {
        // Toggle tool brush state
        const isToolActive = btnToolBrush.classList.contains("active");
        btnToolBrush.classList.toggle("active", !isToolActive);
        
        if (!isToolActive) {
            showToast("Mitigation planner active. Click cells on map to plant tree buffers.", "leaf");
        } else {
            showToast("Tree planting tool deactivated.");
        }
    });

    // ==========================================
    // TAB 4: ECO REWARDS (GAMIFICATION)
    // ==========================================
    const walletPoints = document.getElementById("walletPoints");
    const redeemButtons = document.querySelectorAll(".redeem-btn");

    let currentEcoPoints = 340;

    function addEcoWalletPoints(points) {
        currentEcoPoints += points;
        walletPoints.textContent = currentEcoPoints;
        updateLeaderboardPosition();
        updateStoreButtonStates();
    }

    function recalculateWalletPoints() {
        // Calculate points based on active appliance automations
        let bonusPoints = 0;
        if (activeAutomations.ev) bonusPoints += 150;
        if (activeAutomations.hvac) bonusPoints += 50;
        if (activeAutomations.laundry) bonusPoints += 50;

        // Reset and add
        currentEcoPoints = 340 + bonusPoints;
        walletPoints.textContent = currentEcoPoints;
        updateLeaderboardPosition();
        updateStoreButtonStates();
    }

    function updateLeaderboardPosition() {
        const leaderboardList = document.querySelector(".leaderboard-list");
        // Update user rank visually based on score thresholds
        let rankHtml = `
            <div class="leaderboard-item">
                <span>🥇 1. Aarav S.</span>
                <strong>890 pts</strong>
            </div>
            <div class="leaderboard-item">
                <span>🥈 2. Priyanka K.</span>
                <strong>740 pts</strong>
            </div>
        `;

        if (currentEcoPoints >= 740) {
            rankHtml = `
                <div class="leaderboard-item" style="border: 1px solid var(--accent-green)">
                    <span>🥇 1. Muhil A. (You)</span>
                    <strong class="accent-green">${currentEcoPoints} pts</strong>
                </div>
                ${rankHtml}
            `;
        } else if (currentEcoPoints >= 500) {
            rankHtml = `
                ${rankHtml}
                <div class="leaderboard-item" style="border: 1px solid var(--accent-green)">
                    <span>🥉 3. Muhil A. (You)</span>
                    <strong class="accent-green">${currentEcoPoints} pts</strong>
                </div>
            `;
        } else {
            rankHtml = `
                ${rankHtml}
                <div class="leaderboard-item">
                    <span>🥉 3. Rajesh V.</span>
                    <strong>510 pts</strong>
                </div>
                <div class="leaderboard-item" style="border: 1px solid var(--accent-green)">
                    <span>4. Muhil A. (You)</span>
                    <strong class="accent-green">${currentEcoPoints} pts</strong>
                </div>
            `;
        }
        leaderboardList.innerHTML = rankHtml;
    }

    function updateStoreButtonStates() {
        redeemButtons.forEach(btn => {
            const cost = parseInt(btn.getAttribute("data-cost"));
            if (currentEcoPoints >= cost) {
                btn.removeAttribute("disabled");
                btn.textContent = "Redeem Reward";
            } else {
                btn.setAttribute("disabled", "true");
                btn.textContent = `${cost} Points Needed`;
            }
        });
    }

    redeemButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const cost = parseInt(btn.getAttribute("data-cost"));
            if (currentEcoPoints >= cost) {
                currentEcoPoints -= cost;
                walletPoints.textContent = currentEcoPoints;
                showToast(`Offset redeemed successfully! -${cost} Eco Points.`, "award");
                updateLeaderboardPosition();
                updateStoreButtonStates();
            }
        });
    });

    updateStoreButtonStates(); // run initial
});
