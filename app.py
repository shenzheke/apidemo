from flask import Flask

app = Flask(__name__)

@app.route("/apidemo")
def hello():
    return {"msg": "hello from gitlab ci pipeline"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

