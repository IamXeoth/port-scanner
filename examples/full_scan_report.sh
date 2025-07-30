#!/bin/bash

if [ -z "$1" ]; then
    echo "Scan completo com relatório"
    echo "Uso: $0 <alvo>"
    exit 1
fi

TARGET="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="scan_${TARGET}_${TIMESTAMP}.json"

echo "Fazendo scan completo de $TARGET"
echo "Relatório será salvo em: $REPORT_FILE"
echo "Isso pode demorar alguns minutos..."
echo ""

ruby ../port_scanner.rb -p 1-1000 -t 200 -v -o "$REPORT_FILE" "$TARGET"

echo ""
echo "Pronto! Relatório salvo em $REPORT_FILE"
echo "Você pode abrir o JSON para ver todos os detalhes"