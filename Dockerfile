FROM python:3.11-slim

WORKDIR /app
COPY shashankjapani.py /app/

ENV NAME=World

CMD ["python", "shashankjapani.py"]