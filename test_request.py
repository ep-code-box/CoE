import requests
import json

try:
    response = requests.post('http://localhost:8000/test', 
                           json={'message': 'hello'},
                           headers={'Content-Type': 'application/json'})
    print('Status:', response.status_code)
    print('Response:', response.text)
except Exception as e:
    print('Error:', e)