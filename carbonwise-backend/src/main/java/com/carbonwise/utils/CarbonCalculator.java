package com.carbonwise.utils;
import org.springframework.stereotype.Component;

@Component
public class CarbonCalculator {
    public double calculateCarbonFootprint(double kWh, double carbonIntensity) { return kWh * carbonIntensity / 1000; }
    public double calculateSavingsPercentage(double baseline, double optimized) { if (baseline == 0) return 0; return ((baseline - optimized) / baseline) * 100; }
    public String getCarbonStatus(double intensity) { if (intensity <= 150) return "CLEAN"; else if (intensity <= 300) return "MODERATE"; else if (intensity <= 450) return "DIRTY"; else return "CRITICAL"; }
}
