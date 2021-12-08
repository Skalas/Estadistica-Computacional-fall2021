import psycopg2

DB_USER = "root"
DB_PASSWORD = "root"
DB_HOST = "db"
DB_PORT = "5432"
DB_NAME = "rodent"

SQLALCHEMY_DATABASE_URI = f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"