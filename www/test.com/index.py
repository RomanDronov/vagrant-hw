#!/usr/bin/env python3
from datetime import date
import bfa
print("Content-type: text/html")
print()
print("<h1>Hello world!</h1>")
today = date.today()
print("Today's date:", today)
print(bfa.fingerprint.get())