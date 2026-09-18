"""Model Evaluation - Metrics and comparison"""
import numpy as np
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, mean_absolute_percentage_error

class ModelEvaluator:
    def evaluate_predictions(self, actual, predicted) -> dict:
        actual, predicted = np.array(actual), np.array(predicted)
        return {'MAE': round(mean_absolute_error(actual, predicted), 2), 'RMSE': round(np.sqrt(mean_squared_error(actual, predicted)), 2), 'R2': round(r2_score(actual, predicted), 4), 'MAPE': round(mean_absolute_percentage_error(actual, predicted) * 100, 2)}

    def compare_models(self, models_results: dict) -> dict:
        best_model = min(models_results, key=lambda k: models_results[k]['RMSE'])
        return {'comparison': models_results, 'best_model': best_model, 'best_rmse': models_results[best_model]['RMSE']}
