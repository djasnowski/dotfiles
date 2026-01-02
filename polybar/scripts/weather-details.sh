#!/bin/bash

# Weather details popup for Polybar using WeatherAPI
# Location: Birmingham, AL (35242)

API_KEY="070fad78ae194810a8f212636250610"
ZIP="35242"

# Get detailed weather data
weather_data=$(curl -s "https://api.weatherapi.com/v1/forecast.json?key=${API_KEY}&q=${ZIP}&days=1&aqi=no&alerts=no" 2>/dev/null)

# Parse data
location=$(echo "$weather_data" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
temp=$(echo "$weather_data" | grep -o '"temp_f":[0-9.]*' | head -1 | cut -d':' -f2)
feels=$(echo "$weather_data" | grep -o '"feelslike_f":[0-9.]*' | head -1 | cut -d':' -f2)
condition=$(echo "$weather_data" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4)
humidity=$(echo "$weather_data" | grep -o '"humidity":[0-9]*' | head -1 | cut -d':' -f2)
wind=$(echo "$weather_data" | grep -o '"wind_mph":[0-9.]*' | head -1 | cut -d':' -f2)
wind_dir=$(echo "$weather_data" | grep -o '"wind_dir":"[^"]*"' | head -1 | cut -d'"' -f4)
uv=$(echo "$weather_data" | grep -o '"uv":[0-9.]*' | head -1 | cut -d':' -f2)

# Get high/low
high=$(echo "$weather_data" | grep -o '"maxtemp_f":[0-9.]*' | head -1 | cut -d':' -f2 | cut -d'.' -f1)
low=$(echo "$weather_data" | grep -o '"mintemp_f":[0-9.]*' | head -1 | cut -d':' -f2 | cut -d'.' -f1)

# Get sunrise/sunset
sunrise=$(echo "$weather_data" | grep -o '"sunrise":"[^"]*"' | cut -d'"' -f4)
sunset=$(echo "$weather_data" | grep -o '"sunset":"[^"]*"' | cut -d'"' -f4)

# Format details for Rofi
details="📍 ${location}
━━━━━━━━━━━━━━━━━━━━
🌡️  Current: ${temp}°F
🤔 Feels like: ${feels}°F
📊 High/Low: ${high}°F / ${low}°F
━━━━━━━━━━━━━━━━━━━━
☁️  ${condition}
💧 Humidity: ${humidity}%
💨 Wind: ${wind} mph ${wind_dir}
☀️  UV Index: ${uv}
━━━━━━━━━━━━━━━━━━━━
🌅 Sunrise: ${sunrise}
🌇 Sunset: ${sunset}"

# Show in Rofi
echo -e "$details" | rofi -dmenu -p "Weather Details" \
    -theme /home/dan/.local/share/rofi/themes/matrix.rasi \
    -theme-str 'window {width: 400px;} listview {lines: 13;}'