/**
 * CarbonWise Lazy Loader
 * Loads heavy third-party assets (Leaflet, jsPDF, etc.) on demand.
 * Prevents synchronous network blocking and speeds up initial page paint.
 */
window.CWLazyLoader = (function () {
    const loadedScripts = new Map();
    const loadedStyles = new Map();

    function loadScript(src) {
        if (loadedScripts.has(src)) {
            return loadedScripts.get(src);
        }

        const promise = new Promise((resolve, reject) => {
            // Check if already in DOM
            if (document.querySelector(`script[src="${src}"]`)) {
                resolve();
                return;
            }

            const script = document.createElement("script");
            script.src = src;
            script.async = true;
            script.onload = () => resolve();
            script.onerror = (err) => {
                loadedScripts.delete(src);
                reject(new Error(`Failed to load script: ${src}`));
            };
            document.head.appendChild(script);
        });

        loadedScripts.set(src, promise);
        return promise;
    }

    function loadStyle(href) {
        if (loadedStyles.has(href)) {
            return loadedStyles.get(href);
        }

        const promise = new Promise((resolve, reject) => {
            if (document.querySelector(`link[href="${href}"]`)) {
                resolve();
                return;
            }

            const link = document.createElement("link");
            link.rel = "stylesheet";
            link.href = href;
            link.onload = () => resolve();
            link.onerror = (err) => {
                loadedStyles.delete(href);
                reject(new Error(`Failed to load stylesheet: ${href}`));
            };
            document.head.appendChild(link);
        });

        loadedStyles.set(href, promise);
        return promise;
    }

    // High-level library loaders
    function loadLeaflet() {
        if (window.L) return Promise.resolve(window.L);

        return Promise.all([
            loadStyle("https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"),
            loadScript("https://unpkg.com/leaflet@1.9.4/dist/leaflet.js")
        ]).then(() => window.L);
    }

    function loadJsPDF() {
        if (window.jspdf) return Promise.resolve(window.jspdf);

        return loadScript("https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js")
            .then(() => window.jspdf);
    }

    return {
        loadScript,
        loadStyle,
        loadLeaflet,
        loadJsPDF
    };
})();
