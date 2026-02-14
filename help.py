from flask import Flask

app = Flask(__name__)

@app.route("/")
def help_page():
    return """
    <h1>MineX13 Help</h1>

    <b>Workspace</b><br>
    /minex

    <b>Terminals</b><br>
    /minex/terminal<br>
    /minex/ssh

    <b>Monitoring</b><br>
    /minex/specs<br>
    /minex/gpu

    <b>Info</b><br>
    /minex/help<br>
    /minex/about

    <b>Cloud Storage</b><br>
    Mount at /mnt/cloud

    <b>Uptime Monitor</b><br>
    /health
    """

app.run(host="0.0.0.0", port=5002)
