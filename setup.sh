#!/usr/bin/env bash

podman run --name nerdery-container -e POSTGRES_PASSWORD=password123 -p 5432:5432 -d --rm postgres
sleep 1 #  wait to be ready
podman exec -it -u postgres nerdery-container createdb nerdery_challenge
podman exec -i nerdery-container psql -U postgres -d nerdery_challenge < src/dump.sql