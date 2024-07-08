from flask import Flask, render_template
from flask_sse import sse
import subprocess
import threading
import eventlet

app = Flask(__name__)
app.config["REDIS_URL"] = "redis://default:AZY1AAIncDFlZjkxZTczYzRkNzA0Mzg4OWQyOGE0YmUwMzAwMjhlNnAxMzg0NTM@climbing-lemming-38453.upstash.io:6379"
app.register_blueprint(sse, url_prefix='/stream')

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/run-command')
def run_command():
    def execute_command():
        process = subprocess.Popen(['python build/main.py'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        for line in process.stdout:
            sse.publish({"message": line.strip()}, type='greeting')
        process.stdout.close()
        process.wait()

    thread = threading.Thread(target=execute_command)
    thread.start()
    return "Command is running..."

if __name__ == '__main__':
    app.run(debug=True, threaded=True)
