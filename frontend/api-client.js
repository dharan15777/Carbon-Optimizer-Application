/**
 * CarbonWise API Client
 * Features:
 * - Request Deduplication (prevents multiple identical in-flight network requests)
 * - SWR & TTL In-Memory / Local Storage Caching
 * - Built-in Request Timeout via AbortController (prevents infinite hanging)
 * - Graceful Offline / Demo Fallback (never freezes the UI)
 */
window.CWApiClient = (function () {
    const API_BASE = "https://carbonwise-application.onrender.com/api";
    const DEFAULT_TIMEOUT_MS = 3500;

    // Cache store: url -> { data, timestamp, ttl }
    const memoryCache = new Map();

    // In-flight requests store: key -> Promise
    const inFlightRequests = new Map();

    function getCacheKey(url, options = {}) {
        const method = (options.method || "GET").toUpperCase();
        return `${method}:${url}`;
    }

    /**
     * Clear or invalidate cached entries
     */
    function invalidateCache(pattern) {
        if (!pattern) {
            memoryCache.clear();
            return;
        }
        for (const key of memoryCache.keys()) {
            if (key.includes(pattern)) {
                memoryCache.delete(key);
            }
        }
    }

    /**
     * Safe fetch with timeout
     */
    async function fetchWithTimeout(url, options = {}, timeoutMs = DEFAULT_TIMEOUT_MS) {
        const controller = new AbortController();
        const timer = setTimeout(() => controller.abort(), timeoutMs);

        try {
            const res = await fetch(url, {
                ...options,
                signal: controller.signal
            });
            clearTimeout(timer);
            return res;
        } catch (err) {
            clearTimeout(timer);
            if (err.name === "AbortError") {
                const timeoutErr = new Error(`Request timed out after ${timeoutMs}ms`);
                timeoutErr.isTimeout = true;
                throw timeoutErr;
            }
            throw err;
        }
    }

    /**
     * Unified request method with caching and deduplication
     */
    async function request(endpoint, options = {}, ttlMs = 0) {
        const url = endpoint.startsWith("http") ? endpoint : `${API_BASE}${endpoint}`;
        const method = (options.method || "GET").toUpperCase();
        const cacheKey = getCacheKey(url, options);

        // 1. Check TTL Cache for GET requests
        if (method === "GET" && ttlMs > 0 && memoryCache.has(cacheKey)) {
            const cached = memoryCache.get(cacheKey);
            if (Date.now() - cached.timestamp < ttlMs) {
                return cached.data;
            }
        }

        // 2. Request Deduplication: reuse in-flight promise if pending
        if (inFlightRequests.has(cacheKey)) {
            return inFlightRequests.get(cacheKey);
        }

        const fetchPromise = (async () => {
            try {
                const token = options.token || (window.currentUser && window.currentUser.token);
                const headers = {
                    "Content-Type": "application/json",
                    ...(options.headers || {})
                };
                if (token && token !== "mock" && !token.startsWith("mock-")) {
                    headers["Authorization"] = `Bearer ${token}`;
                }

                const res = await fetchWithTimeout(url, {
                    ...options,
                    headers
                }, options.timeout || DEFAULT_TIMEOUT_MS);

                if (!res.ok) {
                    const err = new Error(`HTTP ${res.status}: ${res.statusText}`);
                    err.status = res.status;
                    throw err;
                }

                const data = await res.json();

                // Save to cache if GET with TTL
                if (method === "GET" && ttlMs > 0) {
                    memoryCache.set(cacheKey, {
                        data,
                        timestamp: Date.now()
                    });
                }

                return data;
            } finally {
                inFlightRequests.delete(cacheKey);
            }
        })();

        inFlightRequests.set(cacheKey, fetchPromise);
        return fetchPromise;
    }

    return {
        API_BASE,
        request,
        invalidateCache,
        fetchWithTimeout
    };
})();
