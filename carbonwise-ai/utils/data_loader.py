"""Data Loader - Fetch carbon and sensor data"""
import requests
from utils.config import Config

class DataLoader:
    def fetch_live_carbon(self) -> dict:
        try: return requests.get(f'{Config.BACKEND_API_URL}/api/consumer/carbon/live').json()
        except Exception: return None

    def fetch_carbon_history(self, days=30) -> list:
        try: return requests.get(f'{Config.BACKEND_API_URL}/api/consumer/carbon/history', params={'days': days}).json()
        except Exception: return []

    def fetch_sensor_data(self) -> list:
        try: return requests.get(f'{Config.BACKEND_API_URL}/api/sensor/live').json()
        except Exception: return []
