import os

import pymysql
from flask import Flask, make_response, render_template, request
from werkzeug.middleware.proxy_fix import ProxyFix

app = Flask(__name__)

# Nginx kertoo alkuperäisen yhteyden tiedot ja sovelluksen alipolun (/viikko2).
app.wsgi_app = ProxyFix(
    app.wsgi_app,
    x_for=1,
    x_proto=1,
    x_prefix=1,
)

def hae_laskuri():
    yhteys = pymysql.connect(
        unix_socket="/run/mysqld/mysqld.sock",
        user="viikko2app",
        password=os.environ["DB_PASSWORD"],
        database="viikko2",
        charset="utf8mb4",
        autocommit=True,
    )
    try:
        with yhteys.cursor() as kursori:
            kursori.execute(
                "SELECT kaynnit FROM laskuri WHERE id = 1"
            )
            kaynnit = kursori.fetchone()[0]
        return kaynnit
    finally:
        yhteys.close()


@app.route("/")
def etusivu():
    kaynnit = hae_laskuri()

    if request.script_root == "/viikko4":
        sivupohja = "viikko4.html"
    else:
        sivupohja = "index.html"

    vastaus = make_response(render_template(sivupohja, kaynnit=kaynnit))
    vastaus.headers["Cache-Control"] = "no-store"
    return vastaus
