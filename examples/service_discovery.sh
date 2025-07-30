#!/bin/bash

if [ -z "$1" ]; then
    echo "Descoberta de serviços"
    echo "Foca nas portas onde geralmente tem coisa interessante"
    echo "Uso: $0 <alvo>"
    exit 1
fi

echo "Procurando serviços interessantes em $1..."

SERVICES="21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1433,1521,3306,3389,5432,5900,6379,8080,8443,27017"

ruby ../port_scanner.rb -p "$SERVICES" -t 30 -v "$1"