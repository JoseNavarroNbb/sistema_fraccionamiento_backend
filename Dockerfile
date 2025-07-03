# Usamos una imagen oficial de Python
FROM python:3.11-slim

# Directorio dentro del contenedor donde vivirá el código
WORKDIR /app

# Copiamos las dependencias
COPY requirements.txt .

# Instalamos las dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto del proyecto
COPY . .

# Puerto expuesto
EXPOSE 8000

# Comando para ejecutar la app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]