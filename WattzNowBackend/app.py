from datetime import datetime

from flask import Flask, request, jsonify
from flasgger import Swagger
from utils import data_utils
from utils.data_utils import *

app = Flask(__name__)
swagger = Swagger(app)

data_utils.load_and_prepare_data()


@app.route('/')
def app_home():
    return 'Eco friendly energy efficient tasks planner/scheduler!'


@app.route('/best-cfe')
def get_best_cfe():
    date_str = request.args.get('date', DEFAULT_DATE)
    start_time = request.args.get('start_time', DEFAULT_START_TIME)
    end_time = request.args.get('end_time', DEFAULT_END_TIME)
    duration = request.args.get('duration', DEFAULT_WINDOW)

    result_df = get_highest_cfe_window(date_str, start_time, end_time, duration)

    if result_df.empty:
        return jsonify({'message': 'No data available for this date/time range'}), 404

    return jsonify(result_df[['Datetime', 'CFE_Percent', 'CFE_avg']].to_dict(orient='records'))


@app.route('/least-direct-ci')
def get_least_direct_ci():
    """
        Get the top 3 start times for the lowest Direct CI duration.

        ---
        parameters:
          # - name: date
          #   in: query
          #   type: string
          #   required: true
          #   default: 2024-01-01
          - name: start_time
            in: query
            type: string
            required: true
            default: 2025-04-06 00:00 AM
          - name: end_time
            in: query
            type: string
            required: true
            default: 2025-04-06 12:00 PM
          - name: duration
            in: query
            type: integer
            required: true
            default: 1
        responses:
          200:
            description: A list of the best start times with avg direct carbon intensity
            schema:
              type: array
              items:
                type: object
                properties:
                  start:
                    type: string
                  end:
                    type: string
                  avg_direct_ci:
                    type: number
          400:
            description: Invalid input
          404:
            description: No data available for this date/time range
        """
    try:
        # Get query parameters
        # date_str = request.args.get('date')
        start_str = request.args.get('start_time')
        end_str = request.args.get('end_time')
        duration = int(request.args.get('duration'))

        # if not (date_str and start_str and end_str):
        if not (start_str and end_str):
            return jsonify({'error': 'Missing required parameters.'}), 400

        start_dt = pd.to_datetime(start_str)
        end_dt = pd.to_datetime(end_str)
        # target_date = pd.to_datetime(date_str).date()
        start_date = start_dt.date()
        end_date = end_dt.date()
        start_time = start_dt.time()
        end_time = end_dt.time()

        # Validation
        if start_date > end_date:
            return jsonify({'error': 'End time must be after start time.'}), 400

        total_hours = (datetime.combine(end_date, end_time) - datetime.combine(start_date,
                                                                             start_time)).seconds / 3600
        if duration > total_hours:
            return jsonify({'error': 'Duration is too large for the given time range.'}), 400

        # Get results
        result = get_lowest_direct_ci_window(start_date, end_date, start_time, end_time, duration)

        if not result:
            return jsonify({'message': 'No data available for this date/time range'}), 404

        return jsonify(result)

    except ValueError as e:
        return jsonify({'error': f'Invalid input: {str(e)}'}), 400
        # return jsonify({'error': 'Invalid input. Please ensure start_time, end_time, and duration are integers.'}), 400


if __name__ == '__main__':
    app.run()
