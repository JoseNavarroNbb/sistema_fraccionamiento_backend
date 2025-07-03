# Sistema de Administración de Fraccionamiento

Backend construido con **FastAPI (Python)** y **MySQL**, listo para integrarse con una aplicación web (Vue.js) y móvil (Ionic - Android/iOS).  
Permite gestionar pagos de mantenimiento, gastos comunes, usuarios y más.

## Descripción

Este sistema permite la gestión completa de un fraccionamiento, incluyendo:

- Registro de propietarios y arrendatarios
- Control de pagos de mantenimiento por usuario
- Registro de gastos comunes como:
  - Luz comunal
  - Mantenimientos (rejas, portones, etc.)
  - Sueldos de guardias o personal de la mesa directiva
- API RESTful lista para consumirse desde cualquier frontend

## Tecnologías Utilizadas

- **Backend:** FastAPI (Python 3.11)
- **Base de datos:** MySQL
- **ORM:** SQLAlchemy
- **Autenticación:** JWT (JSON Web Tokens)
- **Entorno Docker:** Docker Compose
- **Despliegue:** Compatible con Docker, Nginx, Heroku, AWS, GCP

## Estructura del Proyecto

fastapi-backend/
│
├── app/
│ ├── init.py
│ ├── main.py # Punto de entrada de FastAPI
│ ├── database.py # Configuración de conexión a BD
│ ├── models/ # Modelos de base de datos (SQLAlchemy)
│ │ └── user.py
│ ├── schemas/ # Modelos Pydantic para validación
│ │ └── user.py
│ ├── routers/ # Rutas organizadas por módulos
│ │ ├── users.py
│ │ └── payments.py
│ └── utils/ # Funciones auxiliares (JWT, hashing, etc.)
│ ├── auth.py
│ └── jwt.py
│
├── requirements.txt # Dependencias de Python
├── Dockerfile # Construcción de imagen FastAPI
├── docker-compose.yml # Orquesta FastAPI + MySQL
└── .env # Variables de entorno



## Endpoints Principales

### Usuarios y Roles

- **POST /users/** – Registrar un nuevo usuario
- **GET /users/me** – Obtener información del usuario actual
- **PUT /users/{id}** – Actualizar información de usuario
- **DELETE /users/{id}** – Eliminar un usuario

### Autenticación

- **POST /login** – Iniciar sesión y obtener token JWT

### Pagos de Mantenimiento

- **POST /payments/owner** – Registrar pago de mantenimiento
- **GET /payments/owner/{id}** – Ver historial de pagos de un propietario
- **POST /payments/expenses** – Registrar gasto común (luz, guardia, etc.)
- **GET /payments/expenses** – Listar todos los gastos comunes

## Requisitos del Sistema

- Docker Desktop instalado (Windows 11)
- Visual Studio Code (opcional pero recomendado)
- Extensiones útiles: Remote Containers, Python, Docker

## Problema Común: AttributeError 'NoneType' object has no attribute 'get'

Este error ocurre cuando intentas usar `.get()` sobre una variable que es None.

## Cómo Levantar el Proyecto
Clonar el repositorio:

git clone https://github.com/tu-usuario/fastapi-backend.git
cd fastapi-backend

Construir y levantar los contenedores:

docker-compose up -d --build

Acceder a la documentación interactiva:

http://localhost:8000/docs

Aquí podrás probar todos los endpoints.

Variables de Entorno
Reenombra el .env y configurar a su entorno de desarrollo

Ejemplo:

```python
@app.get("/")
def home():
    return {"message": "FastAPI funcionando con MySQL"}


Puede fallar si:

No se crea correctamente la instancia de app = FastAPI()

Hay errores antes de esa línea (importaciones incorrectas, variables None, etc.)

Solución
Revisa tu archivo main.py y asegúrate de que sea así:

from fastapi import FastAPI
from app.database import engine, Base

# Crear tablas si no existen
Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def home():
    return {"message": "FastAPI funcionando con MySQL"}  


