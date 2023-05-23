from flask import Flask

app = Flask(__name__)

# API Route

@app.route("/123")
def trial():
    return 'daje'


if __name__== "__main__":
    app.run(debug=True)