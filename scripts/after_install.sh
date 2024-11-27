#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

echo "Starting after_install.sh script..."

# Remove existing .git directory if it exists
if [ -d /var/www/html/.git ]; then
    echo "Removing existing .git directory..."
    sudo rm -rf /var/www/html/.git
fi

# Clean up existing files in /var/www/html
echo "Removing existing files in /var/www/html..."
sudo rm -rf /var/www/html/*

# Check if Apache is installed
if ! command -v httpd &> /dev/null; then
    echo "Apache (httpd) is not installed. Installing..."
    sudo yum install -y httpd || { echo "Failed to install Apache."; exit 1; }
else
    echo "Apache is already installed."
fi

# Start Apache if it's not running
if ! systemctl is-active --quiet httpd; then
    echo "Starting Apache..."
    sudo systemctl start httpd || { echo "Failed to start Apache."; exit 1; }
else
    echo "Apache is already running."
fi

# Wait for files to be copied or check if they exist
echo "Checking if files exist in /var/www/html/..."
if [ -d /var/www/html ] && [ "$(ls -A /var/www/html)" ]; then
    echo "Files exist in /var/www/html, changing ownership..."
    sudo chown -R apache:apache /var/www/html/*
else
    echo "No files found in /var/www/html, skipping ownership change."
fi

# Restart the web server and log any errors
if ! sudo systemctl restart httpd; then
    echo "Failed to restart Apache." >&2
    exit 1
fi

echo "Finished after_install.sh script successfully."
