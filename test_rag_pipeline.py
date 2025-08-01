import requests
import json

try:
    response = requests.post('http://localhost:8001/api/v1/analyze', 
                           json={
                               'repositories': [
                                   {'url': 'https://github.com/test/test'}
                               ]
                           },
                           headers={'Content-Type': 'application/json'})
    print('Status:', response.status_code)
    print('Response:', response.text)
except Exception as e:
    print('Error:', e)