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
    for line in process.stdout:
        socketio.emit('log', {'message': line.strip(), 'type': 'success'}, broadcast=True)
    for line in process.stderr:
        socketio.emit('log', {'message': line.strip(), 'type': 'error'}, broadcast=True)
    process.stdout.close()
    process.stderr.close()
    process.wait()

@app.route('/')
def home():
    # Jalankan perintah saat halaman dimuat
    thread = threading.Thread(target=execute_command)
    thread.start()
    return render_template('index.html')

if __name__ == '__main__':
    socketio.run(app, debug=True, threaded=True)
