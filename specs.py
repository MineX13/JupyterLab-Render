from flask import Flask
import psutil, platform, time

app = Flask(__name__)

@app.route("/")
def specs():
    return f"""
    <h1>MineX13 Server Specs</h1>
    <b>System:</b> {platform.system()}<br>
    <b>CPU Usage:</b> {psutil.cpu_percent()}%<br>
    <b>RAM Used:</b> {psutil.virtual_memory().percent}%<br>
    <b>Total RAM:</b> {round(psutil.virtual_memory().total/(1024**3),2)} GB<br>
    <b>Disk Used:</b> {psutil.disk_usage('/').percent}%<br>
    <b>Uptime:</b> {time.time()-psutil.boot_time():.0f} sec<br>
    """

app.run(host="0.0.0.0", port=5000)
