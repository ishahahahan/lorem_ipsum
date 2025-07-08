from tensorflow.keras.optimizers import Adam
from tensorflow.keras.losses import MeanSquaredError
from tensorflow import keras
from flask import Flask, request, jsonify
from tensorflow import keras
import numpy as np
import base64
import cv2
import re
from werkzeug.utils import secure_filename
from flask_cors import CORS
from s3_utils import upload_file_to_s3, download_file_from_s3
import os
import uuid
import tempfile

# -------------------------
IMG_DIMN = 224
CALORIES_MAX = 9485.81543
MASS_MAX = 7975
FAT_MAX = 875.5410156
CARB_MAX = 844.5686035
PROTEIN_MAX = 147.491821
# -------------------------

app = Flask(__name__)
CORS(app)


@app.route('/')
def home():
    return "Hello World!"


@app.route('/upload')
def upload_form():
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Upload Image</title>
    </head>
    <body>
        <h1>Upload Image for Prediction</h1>
        <form action="/predict" method="post" enctype="multipart/form-data">
            <input type="file" name="file" accept="image/*">
            <input type="submit" value="Upload Image">
        </form>
    </body>
    </html>
    '''


def convertImage(imgData):
    img_str = re.search(b'base64,(.*)', imgData).group(1)
    with open('input_image.png', 'wb') as output:
        output.write(base64.b64decode(img_str))


def preprocess_image(img_path):
    img = cv2.imread(img_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (IMG_DIMN, IMG_DIMN))
    img = (img / 255.0)
    return img


# def load_model():
#     model = keras.models.load_model('inceptionv3_saved_model.h5')
#     model.compile(
#         optimizer=Adam(learning_rate=1e-5),  # Note: 'lr' is deprecated, use 'learning_rate' instead
#         loss=keras.losses.MeanSquaredError()  # Use the full class instead of string
#     )
#     return model

def load_model():
    custom_objects = {
        'MSE': keras.losses.MeanSquaredError(),
        'mean_squared_error': keras.losses.MeanSquaredError()
    }
    # Use a relative path or environment variable for model path
    model_path = os.environ.get('MODEL_PATH', 'inceptionv3_saved_model.h5')
    model = keras.models.load_model(model_path, custom_objects=custom_objects)
    model.compile(
        optimizer=Adam(learning_rate=1e-5),
        loss=keras.losses.MeanSquaredError()
    )
    return model


# def denormalize_outputs(outputs):
#     print("Outputs shape:", outputs.shape)  # Debugging statement
#     cal = outputs[0] * CALORIES_MAX
#     mass = outputs[1] * MASS_MAX
#     fat = outputs[2] * FAT_MAX
#     carb = outputs[3] * CARB_MAX
#     prot = outputs[4] * PROTEIN_MAX
#     return {'cal:': str(cal),
#             'mass': str(mass),
#             'fat': str(fat),
#             'carb': str(carb),
#             'prot': str(prot)}

def denormalize_outputs(outputs):
    cal = outputs[0][0] * CALORIES_MAX
    mass = outputs[1][0] * MASS_MAX
    fat = outputs[2][0] * FAT_MAX
    carb = outputs[3][0] * CARB_MAX
    prot = outputs[4][0] * PROTEIN_MAX
    return {
        'calories': str(cal),
        'mass': str(mass),
        'fat': str(fat),
        'carbohydrates': str(carb),
        'protein': str(prot)
    }

# def denormalize_outputs(outputs):
#     cal = float(round(outputs[0][0] * CALORIES_MAX, 2))
#     mass = float(round(outputs[1][0] * MASS_MAX, 2))
#     fat = float(round(outputs[2][0] * FAT_MAX, 2))
#     carb = float(round(outputs[3][0] * CARB_MAX, 2))
#     prot = float(round(outputs[4][0] * PROTEIN_MAX, 2))
#     return {
#         'calories': cal,
#         'mass': mass,
#         'fat': fat,
#         'carbohydrates': carb,
#         'protein': prot
#     }


@app.route('/predict', methods=['POST'])
def predict():
    print("received request for prediction")
    if 'file' not in request.files:
        print("no files here")
        return jsonify({"error": "No file part"})
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"})
    
    if file:
        # Generate unique filename and upload to S3
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        s3_url = upload_file_to_s3(file, unique_filename, folder='food_images')
        
        if not s3_url:
            return jsonify({"error": "Failed to upload to S3"})
        
        # Create a temporary file to process
        with tempfile.NamedTemporaryFile(delete=False) as temp_file:
            temp_path = temp_file.name
        
        # Download from S3 to temp file
        s3_key = f"food_images/{unique_filename}"
        if not download_file_from_s3(s3_key, temp_path):
            return jsonify({"error": "Failed to download from S3"})
        
        # Process the image
        preprocessed_img = preprocess_image(img_path=temp_path)
        img_list = [np.array(preprocessed_img)]
        preprocessed_reshaped_img = np.asarray(img_list)

        model = load_model()
        outputs = model.predict(x=preprocessed_reshaped_img)
        print("Model outputs:", outputs)

        # Clean up temporary file
        if os.path.exists(temp_path):
            os.remove(temp_path)

        # Get predictions
        response = denormalize_outputs(outputs)
        
        # Add S3 URL to response
        response['image_url'] = s3_url
        
        return jsonify(response)

    return jsonify({"error": "File upload failed"})