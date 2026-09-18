"""Data Preprocessing - Cleaning, normalization, feature engineering"""
import pandas as pd; import numpy as np

class DataCleaner:
    def clean_carbon_data(self, df: pd.DataFrame) -> pd.DataFrame:
        df = df[df['intensity'].between(50, 800)]
        df['intensity'] = df['intensity'].interpolate(method='linear')
        df = df.fillna(method='ffill').fillna(method='bfill')
        return df

    def normalize_features(self, df: pd.DataFrame) -> pd.DataFrame:
        for col in ['intensity', 'solar_wind_percent', 'hydro_percent', 'gas_percent', 'coal_percent']:
            if col in df.columns: mean, std = df[col].mean(), df[col].std(); df[f'{col}_normalized'] = (df[col] - mean) / std
        return df

class FeatureEngineer:
    def create_time_features(self, df: pd.DataFrame) -> pd.DataFrame:
        df['hour'] = df['timestamp'].dt.hour; df['day_of_week'] = df['timestamp'].dt.dayofweek
        df['month'] = df['timestamp'].dt.month; df['is_weekend'] = df['day_of_week'].isin([5, 6]).astype(int)
        df['is_solar_peak'] = df['hour'].between(10, 14).astype(int); df['is_peak_demand'] = df['hour'].isin([8, 18, 19, 20]).astype(int)
        return df

    def create_lag_features(self, df: pd.DataFrame, lags=[1, 3, 6, 12, 24]) -> pd.DataFrame:
        for lag in lags: df[f'intensity_lag_{lag}'] = df['intensity'].shift(lag)
        df['intensity_rolling_6h'] = df['intensity'].rolling(window=6).mean()
        return df

    def create_carbon_status(self, df: pd.DataFrame) -> pd.DataFrame:
        df['carbon_status'] = np.select([df['intensity'] <= 150, df['intensity'] <= 300, df['intensity'] <= 450, df['intensity'] > 450], ['CLEAN', 'MODERATE', 'DIRTY', 'CRITICAL'], default='MODERATE')
        return df
