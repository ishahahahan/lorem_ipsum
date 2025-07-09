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
from s3_utils import upload_file_to_s3, download_file_from_s3
import tempfile
import uuid
from dotenv import load_dotenv

load_dotenv()

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
            # Generate unique filename and upload to S3
            filename = secure_filename(file.filename)
            unique_filename = f"{uuid.uuid4()}_{filename}"
            s3_url = upload_file_to_s3(file, unique_filename, folder='barcode_images')
            
            if not s3_url:
                return jsonify({"error": "Failed to upload to S3"}), 500
            
            # Create a temporary file to process
            with tempfile.NamedTemporaryFile(delete=False) as temp_file:
                temp_path = temp_file.name
            
            # Download from S3 to temp file
            s3_key = f"barcode_images/{unique_filename}"
            if not download_file_from_s3(s3_key, temp_path):
                return jsonify({"error": "Failed to download from S3"}), 500
            
            # Process the barcode
            result = process_barcode_image(temp_path)
            
            # Clean up temporary file
            if os.path.exists(temp_path):
                os.remove(temp_path)
            
            if result:
                if "error" in result:
                    return jsonify(result), 400
                
                # Add the S3 image URL to the response
                result['image_url'] = s3_url
                return jsonify(result), 200
            else:
                return jsonify({"error": "Failed to process image"}), 400

    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500
