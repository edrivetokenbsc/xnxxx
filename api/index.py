from flask import Flask, jsonify
import subprocess
import logging

app = Flask(__name__)

# Konfigurasi logging
logging.basicConfig(filename='command_output.log', level=logging.INFO, format='%(asctime)s - %(message)s')

@app.route('/')
def run_command():
    # Perintah bash yang ingin dijalankan
    bash_command = 'cd build && bash main.sh'
    
    # Jalankan perintah bash
    result = subprocess.run(bash_command, shell=True, capture_output=True, text=True)
    
    # Tulis output dan error ke file log
    logging.info(result.stdout)
    logging.error(result.stderr)
    
    # Gabungkan stdout dan stderr untuk ditampilkan di web
    combined_output = result.stdout + result.stderr
    
    return combined_output

if __name__ == '__main__':
    app.run(debug=True)
