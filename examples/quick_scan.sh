#!/bin/bash

if [ -z "$1" ]; then
    echo "Scan rápido das top 100 portas"
    echo "Uso: $0 <alvo>"
    exit 1
fi

echo "Scan rápido top 100 portas em $1"
echo "Vai ser bem rápido..."

ruby ../port_scanner.rb -p 1-100 -t 100 -T 1 "$1"