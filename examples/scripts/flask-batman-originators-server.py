#!/usr/bin/env python3

from flask import Flask
import subprocess

app = Flask(__name__)

@app.route('/')
def originators():
    p = subprocess.Popen(['batctl', 'bat0', 'originators_json'],
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)

    stdout, stderr = p.communicate()

    return stdout

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
