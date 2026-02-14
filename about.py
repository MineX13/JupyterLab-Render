from flask import Flask

app = Flask(__name__)

@app.route("/")
def about():
    return """
    <h1>MineX13 Workspace</h1>
    Built for cloud development & automation.

    <p><b>Created by:</b> MineX13</p>
    <p><b>GitHub:</b> https://github.com/MineX13</p>

    Persistent terminals • Monitoring • Cloud storage • Web SSH
    """

app.run(host="0.0.0.0", port=5003)
