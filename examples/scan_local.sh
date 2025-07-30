#!/bin/bash
echo "Testando portas locais..."
echo "Useful para ver o que está rodando na sua máquina"
echo ""

ruby ../port_scanner.rb -p 22,80,443,3306,5432,6379,27017 -v localhost

echo ""
echo "Feito! Se não apareceu nada, é porque não tem nada rodando nessas portas."