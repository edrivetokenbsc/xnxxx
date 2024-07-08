from flask import Flask
from flask_socketio import SocketIO
import subprocess
import threading
import eventlet
import re

eventlet.monkey_patch()

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, async_mode='eventlet')

def execute_command():
    process = subprocess.Popen(['bash', '-c', 'ls && cd build && bash main.sh'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
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

if __name__ == '__main__':
    thread = threading.Thread(target=execute_command)
    thread.start()
    socketio.run(app, debug=True, threaded=True)
