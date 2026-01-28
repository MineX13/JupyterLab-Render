# Use latest Ubuntu
FROM ubuntu:latest

# Set non-interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Update and install Python + dependencies for JupyterLab
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    libzmq3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Upgrade pip and install JupyterLab
RUN pip3 install --upgrade pip
RUN pip3 install jupyterlab

# Expose port 8080
EXPOSE 8080

# Start JupyterLab with no token
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8080", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
