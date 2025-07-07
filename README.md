# Dapoer Plan - AI-Powered Indonesian Recipe Generator Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.32.4-blue?logo=flutter)](https://flutter.dev)
[![Express.js](https://img.shields.io/badge/Express.js-5.1.0-black?logo=express)](https://expressjs.com)
[![Flask](https://img.shields.io/badge/Flask-3.1.1-lightgrey?logo=flask)](https://flask.palletsprojects.com)
[![Node.js](https://img.shields.io/badge/Node.js-22.12.0-green?logo=nodedotjs)](https://nodejs.org)

**Dapoer Plan** is a mobile (Android) application designed to help users manage their food ingredients and discover local Indonesian recipe ideas. This app is equipped with **Artificial Intelligence (AI)** features that allow users to detect food ingredients directly through the device’s camera or by uploading photos from the gallery. Based on the detected ingredients, the app generates **relevant Indonesian local recipe recommendations**. In addition, Dapoer Plan provides a **history feature** to record and revisit previously viewed or created recipes, and a **catalog feature** that contains a collection of diverse Indonesian recipes for users to explore.

## Features

- **AI Ingredient Detection**  
  Scan or upload food images to automatically identify ingredients

- **Smart Recipe Generation**  
  Get personalized Indonesian recipe suggestions based on detected ingredients

- **Recipe Catalog**  
  Explore diverse collection of authentic Indonesian recipes

- **Generated Recipe History**  
  Save and revisit your favorite recipes and searches

- **User-Friendly Interface**  
  Beautiful Flutter-based mobile experience

## Tech Stack
- Frontend: Flutter (Android/iOS)
- Backend: Express.js (REST API)
- AI Service (Image Detection): Flask
- Database: MongoDB
- Computer Vision: Custom YOLO model or LLM using OpenRouter

## Project Setup
### Configuration
Create .env files in the backend directory:
```
PORT=3000
MONGODB_URL='mongodb://localhost:27017/dapoerplan'
JWT_SECRET='your_jwt_secret_32_chars_minimum'
OBJECT_DETECTION_URL='http://localhost:"portforaiserver"/detect/ingredient'
OPENROUTER_API_KEY='your_openrouter_api_key'
```

### Prerequisites
- **Flutter SDK**: 3.32.4 (Dart 3.8.1)
- **Node.js**: 22.12.0
- **Python**: 3.10+ (recommended 3.11+ for better Flask compatibility)

### 1. Backend Setup (Express.js)
```
cd backend
npm install
npm run dev
```
### 2. AI Server Setup (Flask)
```
cd ai_server
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```
### 4. Frontend Setup (Flutter)
```
cd frontend
flutter pub get
flutter run
```
## Screenshots

| Login and Register | Home Screen | Katalog Recipe |
|-------------|--------------------|----------------|
| ![Home Screen](https://github.com/user-attachments/assets/b833001c-9a73-434e-809b-eb6251f1b57c) | ![Scanner](https://github.com/user-attachments/assets/3aef0d16-68cb-46eb-ac8c-c9e53ddc93d8) | ![Results](https://github.com/user-attachments/assets/13a190bd-35df-4bea-8c01-3948068d4f30) |

| Katalog Recipe Detail | Generate Recipe using Ingredient Input |
|---------------|---------------|
| ![Detail View](https://github.com/user-attachments/assets/de7cd969-3c91-45a0-b55f-cbd5892c1d31) | ![Cooking Guide](https://github.com/user-attachments/assets/39b26d46-f6af-4c85-b84b-be2dea73ea0d) |

| Detect Ingredient from Image| Generated Recipe from Detected Ingredient | Generated Recipe History |
|-----------------------|---------------|---------------|
|  ![Ingredients](https://github.com/user-attachments/assets/62ba5037-5d6b-4c95-bd1e-e7a5c1678806) | ![Shopping](https://github.com/user-attachments/assets/6c2ea942-4d52-4012-9872-231096375a46) | ![Favorites](https://github.com/user-attachments/assets/c4c57d8b-d373-47fb-86f1-4442d38a53a5) |




