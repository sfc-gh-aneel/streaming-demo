FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Java 17 for Snowflake SDK (Java 11 not available on this Debian version)
RUN apt-get update && apt-get install -y openjdk-17-jre-headless

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/
COPY config/ ./config/

# Set environment variables
ENV PYTHONPATH=/app
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64

# Create directory for data files
RUN mkdir -p /app/data

# Make the application executable
RUN chmod +x /app/src/main.py

# Run the application
CMD ["python", "/app/src/main.py"] 