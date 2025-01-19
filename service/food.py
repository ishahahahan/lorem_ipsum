import os
from tensorflow.keras.optimizers import Adam
from tensorflow import keras
from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import cv2
from werkzeug.utils import secure_filename

# Constants
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'inceptionv3_saved_model.h5')
IMG_DIMN = 224
CALORIES_MAX = 9485.81543
MASS_MAX = 7975
FAT_MAX = 875.5410156
CARB_MAX = 844.5686035
PROTEIN_MAX = 147.491821

app = Flask(__name__)
CORS(app)

# Load model with error handling
try:
    model = keras.models.load_model(MODEL_PATH)
except Exception as e:
    print(f"Error loading model: {str(e)}")
    print(f"Expected model path: {MODEL_PATH}")
    model = None


def preprocess_image(img_path):
    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (IMG_DIMN, IMG_DIMN))
    img = (img / 255.0)
    return img

def load_model():
    custom_objects = {
        'MSE': keras.losses.MeanSquaredError(),
        'mean_squared_error': keras.losses.MeanSquaredError()
    }
    model = keras.models.load_model(MODEL_PATH, custom_objects=custom_objects)
    model.compile(
        optimizer=Adam(learning_rate=1e-5),
        loss=keras.losses.MeanSquaredError()
    )
    return model

@app.route('/predict', methods=['POST'])
def predict():
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500
    try:
        # Get image from request
        image_file = request.files['image']
        
        # Save the image temporarily
        image_path = 'temp_image.png'
        image_file.save(image_path)
        
        # Process image
        preprocessed_img = preprocess_image(image_path)
        img_array = np.array([preprocessed_img])
        
        # Get prediction
        model = load_model()
        outputs = model.predict(x=img_array)
        
        # Process results
        cal = outputs[0][0] * CALORIES_MAX
        mass = outputs[1][0] * MASS_MAX
        fat = outputs[2][0] * FAT_MAX
        carb = outputs[3][0] * CARB_MAX
        prot = outputs[4][0] * PROTEIN_MAX
        
        return jsonify({
            'calories': round(float(cal), 2),
            'mass': round(float(mass), 2),
            'fat': round(float(fat), 2),
            'carbohydrates': round(float(carb), 2),
            'protein': round(float(prot), 2)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)