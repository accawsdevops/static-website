#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Change ownership of files and log any errors.
if ! sudo chown -R apache:apache /var/www/html/*; then
    echo "Failed to change ownership of files." >&2
    exit 1
fi

# Restart the web server and log any errors.
if ! sudo systemctl restart httpd; then
    echo "Failed to restart Apache." >&2
    exit 1
fi
