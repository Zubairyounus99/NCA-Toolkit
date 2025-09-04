FROM python:3.10-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies (ffmpeg required for media processing)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    gcc \
    g++ \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . .

# Expose API port
EXPOSE 8080

# Default values for Gunicorn (can be overridden by .env)
ENV GUNICORN_WORKERS=2
ENV GUNICORN_TIMEOUT=300

# Start the app with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", \
     "--workers=2", \
     "--timeout=300", \
     "--worker-class=sync", \
     "--keep-alive=80", \
     "app:app"]
