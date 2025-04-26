# Weather App

## 📜 Project Overview
This **Weather App** provides real-time weather information using the OpenWeatherMap API, offering features like current weather, a 5-day forecast, and location-based weather updates. The app leverages **CoreLocation** to fetch the user's current location and displays weather details with a clean and user-friendly interface. The app also supports search functionality for other cities and refresh capabilities to get the latest weather updates.


## 🌟 Features
- **Current Weather:** Displays the current temperature, weather description, and weather icon for the selected city.
- **5-Day Forecast:** Provides a horizontal scrollable view of the 5-day weather forecast, showing temperature and time for each day.
- **Location-based Weather:** Automatically detects the user's location and displays weather information for that city.
- **Search Functionality:** Allows users to search for weather information by city name.
- **Refresh Button:** Manually refreshes the weather data based on the user's current location or the last searched city.
- **Error Handling:** Provides error alerts for network issues or incorrect city names.
- **Dark Mode Support:** The app adapts to Dark Mode for a consistent experience across light and dark themes.
- **Favorite Cities:** Users can save and view their favorite cities.


## ⚙️ Requirements
- Xcode 12.0 or higher
- iOS 13.0 or higher
- OpenWeatherMap API key (add your API key in `WeatherService.swift`)


## 🛠️ Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/WeatherApp.git
2. Install dependencies: This project uses Alamofire for networking. Use CocoaPods to install dependencies:
   ```bash
   pod install
3. Set up the API key: Replace the placeholder API key in WeatherService.swift with your own OpenWeatherMap API key.
4. Run the project: Open the .xcworkspace file in Xcode:
   ```bash
   open WeatherApp.xcworkspace


## 📱 How to Use the App

- **Launch the App:** On startup, the app will show the weather information of your current location.
- **Search for a City:** Use the search bar at the top to search for weather details of any city.
- **Refresh Weather Data:** Tap the **Refresh** button to update the weather information based on your current location.
- **View 5-Day Forecast:** The app shows a horizontal scrollable forecast with temperature and time for the next 5 days.
- **Save Favorite Cities:** Add cities to your favorites for quick access.



## Output Image
Below is an example output of the app displaying current weather and the 5-day forecast:

<img width="458" alt="image" src="https://github.com/user-attachments/assets/c70851dc-fb2b-47cf-8389-f27f0990668f" />
<img width="459" alt="image" src="https://github.com/user-attachments/assets/a71fd78f-5ea9-4361-bb00-8fa66079c5ed" />

