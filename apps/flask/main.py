import requests
from flask import Flask, request, jsonify, redirect

app = Flask(__name__)

@app.route('/', methods=['GET'])
def index():
    return '<samp>🔼 Sahaya Flask for Backend?</samp>'

app.run(port=5000, debug=True)
