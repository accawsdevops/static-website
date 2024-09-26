#!/bin/bash
# Give ownership of the files to the web server user (usually 'apache' or 'www-data')
sudo chown -R apache:apache /var/www/html/*
# Restart the web server (Apache)
sudo systemctl restart httpd
