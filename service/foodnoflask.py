import sys
import json
import numpy as np
import cv2
from tensorflow import keras
from tensorflow.keras.optimizers import Adam

# Constants
IMG_DIMN = 224
CALORIES_MAX = 9485.81543
MASS_MAX = 7975
FAT_MAX = 875.5410156
CARB_MAX = 844.5686035
PROTEIN_MAX = 147.491821

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
    model = keras.models.load_model('inceptionv3_saved_model.h5', custom_objects=custom_objects)
    model.compile(
        optimizer=Adam(learning_rate=1e-5),
        loss=keras.losses.MeanSquaredError()
    )
    return model

def analyze_image(image_path):
    try:
        # Process image
        preprocessed_img = preprocess_image(image_path)
        img_array = np.array([preprocessed_img])
        
        # Get prediction
        model = load_model()
        outputs = model.predict(x=img_array)
        
        # Process results
        cal = float(outputs[0][0] * CALORIES_MAX)
        mass = float(outputs[1][0] * MASS_MAX)
        fat = float(outputs[2][0] * FAT_MAX)
        carb = float(outputs[3][0] * CARB_MAX)
        prot = float(outputs[4][0] * PROTEIN_MAX)
        
        # Return results as JSON
        result = {
            'calories': round(cal, 2),
            'mass': round(mass, 2),
            'fat': round(fat, 2),
            'carbohydrates': round(carb, 2),
            'protein': round(prot, 2)
        }
        
        print(json.dumps(result))
        
    except Exception as e:
        error_result = {'error': str(e)}
        print(json.dumps(error_result))
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(json.dumps({'error': 'Please provide an image path'}))
        sys.exit(1)
        
    image_path = sys.argv[1]
    analyze_image(image_path)