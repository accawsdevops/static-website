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

# Install Apache if not already installed
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

# Ensure the DocumentRoot is set to /var/www/html
echo "Ensuring Apache's DocumentRoot is correctly set..."
sudo sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|<Directory "/var/www/html">|<Directory "/var/www/html">|' /etc/httpd/conf/httpd.conf

# Remove default "It works!" page if it exists
echo "Removing default Apache index.html if it exists..."
sudo rm -f /var/www/html/index.html

# Copy files and ensure ownership and permissions
echo "Copying application files and ensuring ownership..."
sudo cp -r * /var/www/html/
sudo chown -R apache:apache /var/www/html/*
sudo chmod -R 755 /var/www/html/*

# Restart Apache to apply changes
echo "Restarting Apache..."
if ! sudo systemctl restart httpd; then
    echo "Failed to restart Apache." >&2
    exit 1
fi

echo "Finished after_install.sh script successfully."
