from flask import Flask
import GPUtil

app = Flask(__name__)

@app.route("/")
def gpu():
    gpus = GPUtil.getGPUs()
    if not gpus:
        return "<h2>No GPU detected</h2>"

    html = "<h1>MineX13 GPU Monitor</h1>"
    for gpu in gpus:
        html += f"""
        Name: {gpu.name}<br>
        Load: {gpu.load*100:.1f}%<br>
        VRAM: {gpu.memoryUsed}/{gpu.memoryTotal} MB<br>
        Temp: {gpu.temperature} °C<br><br>
        """
    return html

app.run(host="0.0.0.0", port=5001)
