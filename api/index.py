from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import subprocess
import threading
import eventlet
import re

eventlet.monkey_patch()

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, async_mode='eventlet')

def execute_command():
    process = subprocess.Popen(['bash', '-c', 'ls && cd build && python main.py'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    while True:
        output = process.stdout.readline() + process.stderr.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            log_type = 'error' if re.search(r'\bERROR\b|\bTraceback\b', output) else 'success'
            socketio.emit('log', {'message': output.strip(), 'type': log_type}, broadcast=True)

    process.stdout.close()
    process.stderr.close()
    process.wait()

@app.route('/')
def home():
    thread = threading.Thread(target=execute_command)
    thread.start()
    return render_template('index.html')

if __name__ == '__main__':
    socketio.run(app, debug=True, threaded=True)
