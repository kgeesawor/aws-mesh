#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

# Update package list
sudo apt-get update

# Install Python and pip if not already installed
if ! command_exists python3; then
    sudo apt-get install -y python3 python3-pip
fi

# Install DuckDB
pip3 install duckdb

# Install SQLMesh
pip3 install sqlmesh

# Install AWS CLI
if ! command_exists aws; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm awscliv2.zip
    rm -rf aws
fi

# Configure AWS CLI (you'll need to enter your credentials)
aws configure

# Create a new directory for your project
mkdir -p ~/projects/sqlmesh_pipeline
cd ~/projects/sqlmesh_pipeline

# Initialize a new git repository
git init

# Create a .gitignore file
echo "# Python
__pycache__/
*.py[cod]
*$py.class

# Virtual environment
venv/
ENV/

# AWS
.aws/

# DuckDB
*.db

# SQLMesh
.sqlmesh/

# Miscellaneous
*.log
*.tmp" > .gitignore

echo "Local environment setup complete!"