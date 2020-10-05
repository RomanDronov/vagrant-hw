import sys
from datetime import date
from flask import request
print("Content-type: text/html")
print()
print("<h1>Hello world!</h1>")
today = date.today()
print(today)
request.headers.get('User-Agent')
def application(environ, start_response):
    status = '200 OK'
    raw_user_agent = environ.get('HTTP_USER_AGENT', None)