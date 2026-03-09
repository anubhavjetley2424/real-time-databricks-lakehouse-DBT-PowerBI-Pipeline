# Use a slim Python image to keep the size small
FROM python:3.10-slim

# Install system dependencies if needed (e.g., git)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/app

# Install dbt-databricks
RUN pip install --no-cache-dir dbt-databricks

# Copy your dbt project files into the container
COPY . .

# Set environment variables for dbt to find the profile
ENV DBT_PROFILES_DIR=.

# The command to run when the container starts
ENTRYPOINT ["dbt"]