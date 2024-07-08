from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import subprocess
import threading
import eventlet

eventlet.monkey_patch()

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, async_mode='eventlet')

def execute_command():
    process = subprocess.Popen(['bash', '-c', 'ls && cd build && python main.py'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    def read_output(pipe, type):
        while True:
            line = pipe.readline()
            if not line:
                break
            socketio.emit('log', {'message': line.strip(), 'type': type}, broadcast=True)
    stdout_thread = threading.Thread(target=read_output, args=(process.stdout, 'success'))
    stderr_thread = threading.Thread(target=read_output, args=(process.stderr, 'error'))
    stdout_thread.start()
    stderr_thread.start()
    stdout_thread.join()
    stderr_thread.join()
    process.wait()

@app.route('/')
def home():
    thread = threading.Thread(target=execute_command)
    thread.start()
    return render_template('index.html')

if __name__ == '__main__':
    socketio.run(app, debug=True, threaded=True)
