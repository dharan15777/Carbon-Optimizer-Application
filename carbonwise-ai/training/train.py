"""Model Training - Random Forest and LSTM"""
import numpy as np; import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib

class CarbonModelTrainer:
    def __init__(self): self.models = {}

    def train_random_forest(self, data: pd.DataFrame) -> dict:
        feature_cols = ['hour', 'day_of_week', 'month', 'is_weekend', 'is_solar_peak', 'is_peak_demand', 'temperature', 'intensity_lag_1', 'intensity_lag_6', 'intensity_lag_24', 'intensity_rolling_6h']
        X = data[feature_cols].values; y = data['intensity'].values
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)
        model = RandomForestRegressor(n_estimators=100, max_depth=15, min_samples_split=5, random_state=42)
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        joblib.dump(model, 'saved_models/random_forest_carbon.pkl')
        self.models['random_forest'] = model
        return {'model_type': 'RandomForest', 'mae': round(mean_absolute_error(y_test, y_pred), 2), 'rmse': round(np.sqrt(mean_squared_error(y_test, y_pred)), 2), 'r2': round(r2_score(y_test, y_pred), 4)}

    def train_lstm(self, data: pd.DataFrame) -> dict:
        return {'model_type': 'LSTM', 'status': 'pending_implementation'}  # TODO: TensorFlow LSTM
