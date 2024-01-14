import requests
from flask import Flask, request, jsonify, redirect
from dotenv import load_dotenv
import google.generativeai as genai 
import os

load_dotenv()

WEATHER_API=os.getenv('WEATHERAPI_API_KEY')
GEMINI_API=os.getenv('GEMINI_API_KEY')

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return '<samp>🔼 Sahaya Flask for Backend?</samp>'

@app.route('/api/gemini/',methods = ['GET'])
def gemini():
    city = request.args.get('city')
    URL = f"http://api.weatherapi.com/v1/forecast.json?key={WEATHER_API}&q={city}&days=2&aqi=yes&alerts=yes"
    weather_pattern = requests.get(URL).json()
    genai.configure(api_key=GEMINI_API)
    model = genai.GenerativeModel('gemini-pro')
    prompt= f"""This is the current weather at {city} : {weather_pattern['current']['temp_c']} in celsius
    ans consider the data {weather_pattern} to determine the warninng text which is given in json file and then
    Give me a 1-2 Line warning incase of any Thunderstorm, Hurricane, Tornadoo, Tsunami, Hailstorm, Cyclone, Heatwave etc.
    The message should contain the time it is anticipated and what calamity.
    Also give me few precatuionary measures to be prepared for the particular calamity in {city}.
    Warn only if the calamity is <24hrs ahead.
    The response should be of a json of this schema 
    'Color': (Red or Orange or yellow - based on siverity of the climate action.) 1 word (red/orange/yellow)
    'Alert': (The warning about the predicted time and calamity) 1-2 lines [short and crisp & Give the nearest first occurence of such change in weather] the data from the json
    'Precautions': (Few precautions to take - based on the siverity (color) of the calamity) In points format. Tailor it to the particular city based on the input data given [A list of strings - each point is a string element in the list]
    'aqi' : (Based on the air quality from the json file)
     Incase, at current, a calamity is going on, (like its raining, etc), Give a response in the above format with a Green 'color' and Alert should consist of the Time the disaster will decrese or will get back to normal. Give the nearest first occurence.
    Also, if the weaher is normal, give the response with color 'white' and the rest of the response. Give recomendations and alert for airQuality if the color is'white' (the weather is not bad - cloudy, sunny, etc). If the airQuality is good and has no harm, """
    response = model.generate_content(prompt)
    print(response.text)
    return jsonify(response.text)

app.run(port=5000, debug=True)
