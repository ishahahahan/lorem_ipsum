from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import requests
from pyzbar.pyzbar import decode
import numpy as np
import io
from PIL import Image
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all domains

# Create upload folder if it doesn't exist
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/')
def home():
    return "Barcode Nutrition API is running!"

def process_barcode_image(image_path):
    """Process the barcode image and return nutrition information"""
    try:
        # Read the image
        image = cv2.imread(image_path)
        
        if image is None:
            return {"error": "Unable to process image"}

        # Decode the barcode(s)
        barcodes = decode(image)
        if not barcodes:
            return {"error": "No barcode detected in the image"}
        
        # Process the first detected barcode
        barcode = barcodes[0]
        barcode_data = barcode.data.decode('utf-8')
        
        # Get nutrition information
        nutrition_info = get_nutrition_info(barcode_data)
        if nutrition_info:
            return nutrition_info
        else:
            return {"error": "Product not found or no nutrition data available"}

    except Exception as e:
        return {"error": f"Error processing image: {str(e)}"}

def get_nutrition_info(barcode):
    """Fetch nutrition information from Open Food Facts API"""
    try:
        url = f"https://world.openfoodfacts.org/api/v0/product/{barcode}.json"
        response = requests.get(url)
        
        if response.status_code == 200:
            data = response.json()
            if data['status'] == 1:
                product = data.get('product', {})
                nutrition = product.get('nutriments', {})
                
                return {
                    'name': product.get('product_name', 'Unknown product'),
                    'calories': float(nutrition.get('energy-kcal_100g', 0)),
                    'fat': float(nutrition.get('fat_100g', 0)),
                    'carbohydrates': float(nutrition.get('carbohydrates_100g', 0)),
                    'protein': float(nutrition.get('proteins_100g', 0)),
                    'barcode': barcode
                }
        return None
    except Exception as e:
        print(f"Error fetching nutrition info: {str(e)}")
        return None

@app.route('/predict', methods=['POST'])
def predict():
    """Endpoint to process barcode image and return nutrition information"""
    try:
        # Check if file was uploaded
        if 'file' not in request.files:
            return jsonify({"error": "No file uploaded"}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        if file:
            # Save the uploaded file
            filename = secure_filename(file.filename)
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            file.save(filepath)

            # Process the image
            result = process_barcode_image(filepath)

            # Clean up - remove the uploaded file
            if os.path.exists(filepath):
                os.remove(filepath)

            if result:
                if "error" in result:
                    return jsonify(result), 400
                return jsonify(result), 200
            else:
                return jsonify({"error": "Failed to process image"}), 400

    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=6000)