from flask import Flask
from flask_migrate import Migrate

from config import SQLALCHEMY_DATABASE_URI
from models import db


def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
    db.init_app(app)
    migrate = Migrate(app, db)
    migrate.init_app(app, db)
    return app