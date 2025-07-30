#!/bin/bash

if [ -z "$1" ]; then
    echo "Como usar: $0 <alvo>"
    echo "Exemplo: $0 google.com"
    exit 1
fi

echo "Scanning portas comuns em $1..."
echo "Isso vai demorar uns 30 segundos"
echo ""

ruby ../port_scanner.rb -p 21,22,23,25,53,80,110,143,443,993,995,3389,8080,8443 -t 20 -v "$1"