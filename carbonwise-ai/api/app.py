"""CarbonWise AI Prediction Server"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from prediction.predictor import CarbonPredictor
from recommendation.recommender import CarbonRecommender

app = Flask(__name__)
CORS(app)
predictor = CarbonPredictor()
recommender = CarbonRecommender()

@app.route('/api/prediction/<int:hours>h', methods=['GET'])
def get_prediction(hours):
    try:
        if hours not in [6, 12, 24]: return jsonify({'error': 'Invalid window'}), 400
        prediction = predictor.predict(hours)
        recommendation = recommender.get_recommendation(prediction)
        return jsonify({'id': f'pred_{hours}h_{prediction["timestamp"]}', 'predictedAt': prediction['timestamp'], 'dataPoints': prediction['data_points'], 'bestChargingTime': recommendation['best_charging_time'], 'bestApplianceTime': recommendation['best_appliance_time'], 'recommendation': recommendation['text']})
    except Exception as e: return jsonify({'error': str(e)}), 500

@app.route('/api/prediction/live', methods=['GET'])
def get_live(): return jsonify(predictor.get_live_intensity())

@app.route('/api/recommendation', methods=['GET'])
def get_recommendation():
    device_type = request.args.get('device', 'general')
    return jsonify(recommender.get_recommendation_for_device(device_type))

@app.route('/api/gis/interpolate', methods=['POST'])
def spatial_interpolation():
    data = request.json
    return jsonify(predictor.spatial_interpolation(data.get('sensor_data', []), data.get('grid_resolution', 12)))

@app.route('/health', methods=['GET'])
def health(): return jsonify({'status': 'healthy', 'service': 'carbonwise-ai'})

if __name__ == '__main__': app.run(host='0.0.0.0', port=5000, debug=True)
