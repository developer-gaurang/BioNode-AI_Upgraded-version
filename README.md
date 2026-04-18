# 🧬 BioNode AI - Next-Gen Personal Intelligence OS

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Google_Gemini-8E75B2?style=for-the-badge&logo=google-gemini&logoColor=white" />
</p>

BioNode AI is a high-end, futuristic personal operating system built with Flutter. It blends cutting-edge UI aesthetics with powerful AI-driven safety and health features. Designed with a **billion-dollar company vision**, it offers a seamless, professional experience for managing health, environment, and personal safety.

---

## ✨ Key Features

### 🔐 1. Quantum Node Authentication
*   **Encrypted Identity**: Secure registration and login synced with **Cloud Firestore**.
*   **Biometric Aesthetics**: Cinematic entry animations and fingerprint-inspired UI.
*   **Local & Cloud Hybrid**: Robust data integrity ensuring your "Node" is always accessible.

### 🌩️ 2. EcoMonitor (AI Weather Intelligence)
*   **Live Telemetry**: Real-time Temperature, Humidity, Pressure, and Wind Speed fetching.
*   **Gemini AI Insights**: Hyper-personalized health advisories based on current weather conditions.
*   **5-Hour Forecasting**: Dynamic visual updates for upcoming climate shifts.

### 🛡️ 3. CrashGuard (Accident Detection)
*   **Acoustic Intelligence**: Real-time microphone monitoring to detect high-impact sounds/crashes.
*   **Automated SOS**: High-volume emergency alarms and automated SMS alerts to 5 configured contacts.
*   **Real-time SOS Mapping**: Immediate location broadcasting via Firebase to nearby responders.

### 🏥 4. Health Vault (Secure Medical SSR)
*   **Encrypted Records**: Store sensitive medical history, allergies, and immunization data.
*   **Dynamic QR Integration**: Generate unique, read-only public links for emergency responders via QR.
*   **Public Portal**: Secure, read-only web view for medical professionals to access life-saving data quickly.

### 🎨 5. Premium UI/UX Suite
*   **Glassmorphism**: Beautiful `AcrylicCard` system with 40px sigma blurs.
*   **Mesh Backgrounds**: Animated, floating neon orbs for a premium "OS" feel.
*   **Spring Dynamics**: Custom elastic-out animations for all interactive elements.

---

## 🚀 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend/Database**: Firebase (Auth, Firestore)
- **AI Engine**: Google Gemini API
- **State Management**: Advanced StatefulWidget & AnimationControllers
- **Assets**: Google Fonts (Outfit, Inter, Roboto), `flutter_dotenv` for security

---

## 🛠️ Installation & Setup

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/developer-gaurang/BioNode-AI.git
    cd BioNode-AI
    ```

2.  **Environment Variables**:
    Create a `.env` file in the root directory and add your API keys:
    ```env
    GEMINI_API_KEY=your_gemini_api_key_here
    OPENWEATHER_API_KEY=your_weather_api_key_here
    ```

3.  **Dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 🔒 Security Note

Your `.env` file and sensitive Firebase configuration are automatically ignored by Git to prevent unauthorized access. Always ensure you never commit your private API keys.

---

<p align="center">
  Built with ❤️ for a safer, smarter future.
</p>
