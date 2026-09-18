"""Carbon Recommendation Engine - Device-specific scheduling recommendations"""
from datetime import datetime, timedelta
from typing import Dict, Any

class CarbonRecommender:
    DEVICE_PROFILES = {
        'EV_CHARGER': {'ideal_window': (10, 14), 'duration_hours': 4, 'priority': 'high'},
        'AIR_CONDITIONER': {'ideal_window': (10, 13), 'duration_hours': 3, 'priority': 'medium'},
        'WASHING_MACHINE': {'ideal_window': (10, 14), 'duration_hours': 2, 'priority': 'low'},
        'WATER_HEATER': {'ideal_window': (10, 12), 'duration_hours': 1, 'priority': 'medium'},
        'SMART_PLUG': {'ideal_window': (10, 14), 'duration_hours': 1, 'priority': 'low'},
    }

    def get_recommendation(self, prediction: Dict) -> Dict[str, Any]:
        data_points = prediction.get('data_points', [])
        clean_windows = [dp for dp in data_points if dp['predictedIntensity'] < 150]
        moderate_windows = [dp for dp in data_points if 150 <= dp['predictedIntensity'] < 300]
        if clean_windows:
            best = min(clean_windows, key=lambda x: x['predictedIntensity'])
            hour = datetime.fromisoformat(best['time']).hour
            return {'best_charging_time': f"{hour}:00 - {hour+4}:00", 'best_appliance_time': f"{hour}:00 - {hour+2}:00", 'text': "✅ Optimal carbon window detected! Schedule heavy loads now."}
        elif moderate_windows:
            best = min(moderate_windows, key=lambda x: x['predictedIntensity'])
            hour = datetime.fromisoformat(best['time']).hour
            return {'best_charging_time': f"{hour}:00 - {hour+4}:00", 'best_appliance_time': f"{hour}:00 - {hour+2}:00", 'text': "⚠️ Moderate window. Schedule loads during cleaner period."}
        else:
            return {'best_charging_time': "Not available", 'best_appliance_time': "Not available", 'text': "❌ High carbon intensity. Delay heavy loads."}

    def get_recommendation_for_device(self, device_type: str) -> Dict[str, Any]:
        profile = self.DEVICE_PROFILES.get(device_type, self.DEVICE_PROFILES['SMART_PLUG'])
        ideal_start, ideal_end = profile['ideal_window']
        now = datetime.now()
        if now.hour < ideal_start: next_ideal = now.replace(hour=ideal_start, minute=0); status = "Wait for optimal window"
        elif now.hour <= ideal_end: next_ideal = now; status = "Currently in optimal window!"
        else: next_ideal = (now + timedelta(days=1)).replace(hour=ideal_start, minute=0); status = "Next window tomorrow"
        return {'deviceType': device_type, 'idealWindow': f"{ideal_start}:00 - {ideal_end}:00", 'durationHours': profile['duration_hours'], 'priority': profile['priority'], 'nextAvailable': next_ideal.isoformat(), 'status': status, 'estimatedCarbonSaving': "~30% reduction"}
