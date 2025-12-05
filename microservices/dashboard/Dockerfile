# ================================
# Base Image
# ================================
FROM python:3.11-slim

# ================================
# Set work directory
# ================================
WORKDIR /app

# ================================
# Install required system packages
# ================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ================================
# Install Python dependencies
# ================================
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ================================
# Copy application code
# ================================
COPY . .

# ================================
# Create non-root user (security best practice)
# ================================
RUN useradd -m appuser
USER appuser

# ================================
# Expose port
# ================================
EXPOSE 8080

# ================================
# Launch FastAPI Dashboard
# ================================
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
