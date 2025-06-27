# Dockerfile for Apigee Playground Backend (FastAPI + MongoDB)
FROM python:3.9-buster

# Install MongoDB dependencies
RUN apt-get update && \
    apt-get install -y gnupg curl lsb-release && \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg && \
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy FastAPI app
COPY main.py .

# Expose FastAPI and MongoDB ports
EXPOSE 8080 27017

# Start both MongoDB and FastAPI using supervisord
RUN pip install supervisor
COPY supervisord.conf /etc/supervisord.conf

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
