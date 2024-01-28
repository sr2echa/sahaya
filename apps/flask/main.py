import requests
from flask import Flask, request, jsonify, redirect
from dotenv import load_dotenv
import google.generativeai as genai 
import os

import firebase_admin
from firebase_admin import credentials, initialize_app,firestore
load_dotenv()

project_id = os.getenv('PROJECT_ID')
private_key_id = os.getenv('PRIVATE_KEY_ID')
private_key = os.getenv('PRIVATE_KEY')
client_email = os.getenv('CLIENT_EMAIL')
client_id = os.getenv('CLIENT_ID')
auth_uri = os.getenv('AUTH_URI')
client_x509_cert_url = os.getenv('CLIENT_X509_CERT_URL')

credentials_dict = {
    "type": "service_account",
    "project_id": project_id,
    "private_key_id": private_key_id,
    "private_key": private_key,
    "client_email": client_email,
    "client_id": client_id,
    "auth_uri": auth_uri,
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": client_x509_cert_url,
    "universe_domain": "googleapis.com"
}

# Initialize Firebase with the credentials
cred = credentials.Certificate(credentials_dict)
firebase_app = initialize_app(cred)




WEATHER_API=os.getenv('WEATHERAPI_API_KEY')
GEMINI_API=os.getenv('GEMINI_API_KEY')

app = Flask(__name__)

db=firestore.client()

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
    prompt= f"""This is the current weather at {city} :   consider the data {weather_pattern} to determine the warninng text which is given in json file and then
    Give me a 1-2 Line warning incase of any Thunderstorm, Hurricane, Tornadoo, Tsunami, Hailstorm, Cyclone, Heatwave etc.
    The message should contain the time it is anticipated and what calamity.
    Also give me few precatuionary measures to be prepared for the particular calamity in {city}.
    Warn only if the calamity is <24hrs ahead.
    The response should be of a json of this schema 
    'Color': (Red or Orange or yellow - based on siverity of the climate action.) 1 word (red/orange/yellow)
    'weather': (The weather at the moment) 1 word (sunny/cloudy/rainy) in the exact name of font awesome icon pack (https://fontawesome.com/v5.15/icons?d=gallery&p=2&q=weather&m=free) using the data from json
    'Alert': (The warning about the predicted time and calamity) 1-2 lines [short and crisp & Give the nearest first occurence of such change in weather] the data from the json
    'Precautions': (Few precautions to take - based on the siverity (color) of the calamity) In points format. Tailor it to the particular city based on the input data given [A list of strings - each point is a string element in the list]
     Incase, at current, a calamity is going on, (like its raining, etc), Give a response in the above format with a Green 'color' and Alert should consist of the Time the disaster will decrese or will get back to normal. Give the nearest first occurence.
    Also, if the weaher is normal, give the response with color 'white' and the rest of the response. Give recomendations and alert for airQuality if the color is'white' (the weather is not bad - cloudy, sunny, etc). If the airQuality is good and has no harm, """
    response = model.generate_content(prompt)
    print(response.text)
    return jsonify(response.text)

@app.route('/api/debug/backend/',methods = ['GET'])
def backend():
    return jsonify(requests.get('https://raw.githubusercontent.com/sr2echa/sahaya/main/apps/mobile/assets/backend.schema.json').text)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
