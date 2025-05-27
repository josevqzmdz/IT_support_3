#!/bin/bash

# Démarrer le service Cron
service cron start

# Configurer Nginx
nginx -t

# Lancer la commande originale (WordPress + Nginx)
exec "$@"