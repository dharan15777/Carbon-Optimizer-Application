"""AI Module Configuration"""
import os

class Config:
    AI_SERVER_HOST = os.getenv('AI_SERVER_HOST', '0.0.0.0')
    AI_SERVER_PORT = int(os.getenv('AI_SERVER_PORT', '5000'))
    BACKEND_API_URL = os.getenv('BACKEND_API_URL', 'https://api.carbonwise.in')
    MQTT_BROKER = os.getenv('MQTT_BROKER', 'mqtt.carbonwise.in')
    MODEL_SAVE_DIR = os.getenv('MODEL_SAVE_DIR', 'saved_models/')
    DATASET_DIR = os.getenv('DATASET_DIR', 'datasets/')
    CARBON_CLEAN_THRESHOLD = float(os.getenv('CARBON_CLEAN_THRESHOLD', '150'))
    CARBON_MODERATE_THRESHOLD = float(os.getenv('CARBON_MODERATE_THRESHOLD', '300'))
    CARBON_DIRTY_THRESHOLD = float(os.getenv('CARBON_DIRTY_THRESHOLD', '450'))
