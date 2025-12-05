# ================================
# Base image
# ================================
FROM python:3.11-slim

# ================================
# Working directory
# ================================
WORKDIR /app

# ================================
# System dependencies for psycopg2
# ================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ================================
# Python dependencies
# ================================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ================================
# Copy processor code
# ================================
COPY . .

# ================================
# Non-root user for security
# ================================
RUN useradd -m appuser
USER appuser

# ================================
# Run the worker
# ================================
CMD ["python", "main.py"]
