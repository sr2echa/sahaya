FROM python:3.10-slim

ENV PYTHONUNBUFFERED True
WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT 8080
ENV HOST 0.0.0.0

EXPOSE 8080 

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
