# Advanced Port Scanner

Um scanner de portas que fiz em Ruby. Funciona bem e é rápido.

## O que faz

- Scanneia portas TCP e UDP
- Mostra quais serviços estão rodando
- Captura banners quando possível  
- Usa threads para ir mais rápido
- Salva resultado em JSON

## Como usar

Básico:
```bash
ruby port_scanner.rb google.com
```

Com mais opções:
```bash
ruby port_scanner.rb -p 1-1000 -t 50 -v google.com
```

Scan UDP:
```bash
ruby port_scanner.rb -s udp -p 53,67,123 google.com
```

Salvar resultado:
```bash
ruby port_scanner.rb -p 80,443,22 -o resultado.json github.com
```

## Opções disponíveis

- `-p` - portas para scanear (ex: 1-1000 ou 80,443,22)
- `-t` - quantas threads usar (padrão: 50)
- `-T` - timeout em segundos (padrão: 2)  
- `-s` - tipo de scan: tcp, udp ou syn (padrão: tcp)
- `-v` - mostrar mais detalhes
- `-o` - salvar em arquivo JSON

## Exemplo do que sai

```
🔍 Iniciando scan avançado em google.com
📊 Portas: 1000 | Threads: 50 | Timeout: 2s
🔧 Tipo de scan: TCP
------------------------------------------------------------
✅ 80/tcp - HTTP - open
✅ 443/tcp - HTTPS - open

================================================================
📋 RESULTADOS DO SCAN
================================================================
🎯 Alvo: google.com
⏱️  Duração: 12.34s
🔍 Portas abertas: 2

🟢 80/tcp - HTTP
   📝 Banner: Apache/2.4.41

🟢 443/tcp - HTTPS
```

## Aviso

Use só em sistemas seus ou onde você tem permissão. Não seja idiota.

## Requisitos

Ruby 2.7+ (deve funcionar em versões mais antigas também)
