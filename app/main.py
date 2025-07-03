from fastapi import FastAPI
from app.database import engine, Base

# Crea las tablas en la BD si no existen
Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def home():
    return {"message": "FastAPI funcionando con MySQL"}