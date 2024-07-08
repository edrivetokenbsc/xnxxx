from flask import Flask, render_template, jsonify
import subprocess
import threading
import time

app = Flask(__name__)

logs = []

def execute_command():
    global logs
    process = subprocess.Popen(['python', 'build/main.py'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    logs = []
    for line in process.stdout:
        logs.append(line.strip())
    process.stdout.close()
    process.wait()

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/run-command')
def run_command():
    thread = threading.Thread(target=execute_command)
    thread.start()
    return "Command is running..."

@app.route('/logs')
def get_logs():
    return jsonify(logs)

if __name__ == '__main__':
    app.run(debug=True, threaded=True)
