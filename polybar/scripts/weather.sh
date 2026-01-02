#!/bin/bash

# Weather module for Polybar using WeatherAPI
# Location: Birmingham, AL (35242)

# API configuration
API_KEY="070fad78ae194810a8f212636250610"
ZIP="35242"

# Get weather icon based on condition using Meteocons font
get_weather_icon() {
    local condition="$1"
    local is_day="$2"

    case "${condition,,}" in
        *clear*|*sunny*)
            if [ "$is_day" = "1" ]; then
                echo "B"  # Clear/Sunny
            else
                echo "C"  # Clear Night
            fi
            ;;
        *partly*cloudy*)
            echo "H"  # Partly Cloudy (Day)
            ;;
        *mostly*cloudy*)
            echo "I"  # Mostly Cloudy (Day)
            ;;
        *cloudy*)
            echo "L"  # Cloudy
            ;;
        *overcast*)
            echo "M"  # Overcast
            ;;
        *mist*|*fog*|*haz*)
            echo "E"  # Haze/Fog
            ;;
        *thunder*storm*)
            echo "N"  # Thunderstorm
            ;;
        *thunder*)
            echo "Y"  # Thunderstorms
            ;;
        *rain*shower*)
            echo "O"  # Rain Showers
            ;;
        *rain*)
            echo "O"  # Rain
            ;;
        *snow*shower*)
            echo "Q"  # Snow Showers
            ;;
        *light*snow*)
            echo "U"  # Light Snow
            ;;
        *heavy*snow*)
            echo "V"  # Heavy Snow
            ;;
        *snow*)
            echo "G"  # Snowflake/Cold
            ;;
        *sleet*)
            echo "W"  # Sleet
            ;;
        *blizzard*)
            echo "S"  # Blizzard
            ;;
        *wind*)
            echo "F"  # Windy
            ;;
        *)
            echo "L"  # Default to cloudy
            ;;
    esac
}

# Get weather data
get_weather() {
    # Get forecast data (includes current weather and astronomy data)
    weather_data=$(curl -s "https://api.weatherapi.com/v1/forecast.json?key=${API_KEY}&q=${ZIP}&days=1&aqi=no&alerts=no" 2>/dev/null)

    # Parse current weather
    temp=$(echo "$weather_data" | grep -o '"temp_f":[0-9.]*' | head -1 | cut -d':' -f2 | cut -d'.' -f1)
    condition=$(echo "$weather_data" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4)
    is_day=$(echo "$weather_data" | grep -o '"is_day":[0-9]' | head -1 | cut -d':' -f2)

    # Parse sunset from astro data and remove AM/PM
    sunset=$(echo "$weather_data" | grep -o '"sunset":"[^"]*"' | cut -d'"' -f4 | sed 's/ [AP]M//')

    if [ -z "$temp" ] || [ -z "$condition" ]; then
        echo "Weather unavailable"
    else
        # Get the appropriate weather icon
        weather_icon=$(get_weather_icon "$condition" "$is_day")

        # Format: [Icon] Current°F, [Sunset icon] time
        if [ -n "$sunset" ]; then
            echo "%{T10}${weather_icon}%{T-} ${temp}°F, %{T10}J%{T-} ${sunset} —"
        else
            echo "%{T10}${weather_icon}%{T-} ${temp}°F —"
        fi
    fi
}

# Main
weather_info=$(get_weather)
echo "$weather_info"