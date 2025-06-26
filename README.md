# AI-Powered Calorie Tracker

This repository contains a cross-platform mobile application for tracking daily caloric and nutritional intake, built with Flutter. The app features AI-powered food recognition from images, barcode scanning for quick lookups, and user authentication and data persistence using Supabase.

## Features

-   **User Authentication**: Secure sign-up and sign-in functionality powered by Supabase.
-   **Personalized Goals**: Users can set up their profile with height, current weight, and desired weight to establish health goals.
-   **Interactive Dashboard**: A home screen that provides an at-a-glance view of daily calorie consumption against goals, visualized with pie charts.
-   **Macronutrient Tracking**: Detailed tracking of carbohydrates, protein, and fats.
-   **AI Food Recognition**: Log meals by simply taking a picture. A backend TensorFlow model analyzes the image and returns an estimated nutritional breakdown.
-   **Barcode Scanning**: Use the device's camera to scan product barcodes, automatically fetching and logging nutritional data from the Open Food Facts database.
-   **Meal History**: A persistent log of all food intake, viewable on the main dashboard.
-   **Cross-Platform**: Built on Flutter for a consistent experience across Android, iOS, and other supported platforms.

## Architecture

The application is composed of a Flutter frontend and a Python-based backend for specialized services.

-   **Frontend**: A Flutter application responsible for the UI, state management, and communication with backend services.
-   **Backend Services**:
    -   **Supabase**: Used for user authentication, session management, and as the primary database (PostgreSQL) for storing user profiles and meal logs.
    -   **AI Nutrition Service (`service/mediator.py`)**: A Python Flask server that exposes an endpoint (`/predict`). It hosts a pre-trained InceptionV3 model to analyze food images and predict nutritional values.
    -   **Barcode Service (`service/barcodebackend.py`)**: A Python Flask server that processes images containing barcodes. It uses `pyzbar` to decode the barcode and queries the Open Food Facts API to retrieve product information.

## Technology Stack

-   **Frontend**: Flutter, Dart
-   **Backend**: Python, Flask
-   **Database & Auth**: Supabase
-   **Machine Learning**: TensorFlow, Keras, OpenCV
-   **APIs & Libraries**: Open Food Facts, `pyzbar`

## Setup and Installation

To run this project, you need to set up the Flutter frontend, the Python backend services, and a Supabase project.

### Prerequisites

-   Flutter SDK
-   Dart SDK
-   Python 3.8+
-   A Supabase account

### 1. Supabase Setup

1.  Go to [Supabase](https://supabase.com/) and create a new project.
2.  Navigate to the **SQL Editor** and run the following queries to create the necessary tables:

    ```sql
    -- Create user profile table
    CREATE TABLE user_profile (
      id UUID PRIMARY KEY REFERENCES auth.users(id),
      name TEXT,
      height NUMERIC,
      weight NUMERIC,
      desired_weight NUMERIC,
      profile_completed BOOLEAN DEFAULT false,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    -- Create food intake log table
    CREATE TABLE food_intake (
      id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
      user_id UUID REFERENCES auth.users(id),
      calories NUMERIC,
      carbohydrates NUMERIC,
      protein NUMERIC,
      fats NUMERIC,
      meal_time TIMESTAMPTZ,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );
    ```

3.  In your Supabase project settings, go to the **API** section and find your **Project URL** and **anon public key**.

### 2. Backend Services Setup

1.  Navigate to the `service` directory in your terminal:
    ```bash
    cd service
    ```
2.  Install the required Python dependencies:
    ```bash
    pip install Flask flask_cors opencv-python requests pyzbar numpy Pillow werkzeug tensorflow
    ```
3.  Run the two Flask servers in separate terminal windows. These servers handle AI prediction and barcode scanning.

    *Terminal 1 (Food Recognition):*
    ```bash
    python mediator.py
    ```
    This server will run on `http://0.0.0.0:5000`.

    *Terminal 2 (Barcode Scanning):*
    ```bash
    python barcodebackend.py
    ```
    This server will run on `http://0.0.0.0:6000`.

### 3. Frontend Setup

1.  Clone the repository:
    ```bash
    git clone https://github.com/ishahahahan/lorem_ipsum.git
    cd lorem_ipsum
    ```
2.  **Configure Supabase Credentials**:
    -   Open `lib/main.dart` and replace the placeholder URL with your Supabase Project URL.
    -   Open `lib/const.dart` and replace the placeholder key with your Supabase anon public key.

    ```dart
    // lib/main.dart
    const supabaseUrl = 'YOUR_SUPABASE_URL';

    // lib/const.dart
    const SUPABASE_KEY = "YOUR_SUPABASE_ANON_KEY";
    ```
3.  **Configure Backend IP Address**:
    -   The application is hardcoded to connect to a local backend. Find your computer's local IP address.
    -   Open `lib/screens/home_screen.dart` and replace the hardcoded IP address `10.79.9.136` with your local IP address in the `_buildCircularNavItem` function.

    ```dart
    // Example in lib/screens/home_screen.dart
    var uri = Uri.parse('http://YOUR_LOCAL_IP:5000/predict');
    // ...
    var uri = Uri.parse('http://YOUR_LOCAL_IP:6000/predict');
    ```

4.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```
5.  Run the application on an emulator or a physical device:
    ```bash
    flutter run
