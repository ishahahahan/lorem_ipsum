import os
import sys

# Add the current directory to the path so Python can find the modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import both Flask applications
from mediator import app as food_app
from barcodebackend import app as barcode_app

# Determine which app to run based on the environment variable
app_name = os.environ.get('FLASK_APP', 'food')
if app_name == 'food':
    app = food_app
else:  # 'barcode'
    app = barcode_app

if __name__ == '__main__':
    app.run()