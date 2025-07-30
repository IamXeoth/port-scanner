#!/usr/bin/env ruby

require 'socket'
require 'timeout'
require 'optparse'
require 'json'
require 'thread'

class AdvancedPortScanner
  COMMON_PORTS = {
    21 => 'FTP',
    22 => 'SSH',
    23 => 'Telnet',
    25 => 'SMTP',
    53 => 'DNS',
    80 => 'HTTP',
    110 => 'POP3',
    143 => 'IMAP',
    443 => 'HTTPS',
    993 => 'IMAPS',
    995 => 'POP3S',
    3389 => 'RDP',
    5432 => 'PostgreSQL',
    3306 => 'MySQL',
    1433 => 'MSSQL',
    6379 => 'Redis',
    27017 => 'MongoDB'
  }

  def initialize(options = {})
    @target = options[:target]
    @ports = options[:ports] || (1..1000).to_a
    @threads = options[:threads] || 50
    @timeout = options[:timeout] || 2
    @verbose = options[:verbose] || false
    @output_file = options[:output]
    @scan_type = options[:scan_type] || :tcp
    @results = []
    @mutex = Mutex.new
  end

  def scan
    puts "🔍 Iniciando scan avançado em #{@target}"
    puts "📊 Portas: #{@ports.size} | Threads: #{@threads} | Timeout: #{@timeout}s"
    puts "🔧 Tipo de scan: #{@scan_type.upcase}"
    puts "-" * 60

    start_time = Time.now

    # Divide as portas em chunks para as threads
    port_chunks = @ports.each_slice(@ports.size / @threads + 1).to_a
    threads = []

    port_chunks.each do |chunk|
      threads << Thread.new do
        chunk.each { |port| scan_port(port) }
      end
    end

    threads.each(&:join)

    end_time = Time.now
    duration = end_time - start_time

    display_results(duration)
    save_results if @output_file
  end

  private

  def scan_port(port)
    case @scan_type
    when :tcp
      result = tcp_scan(port)
    when :udp
      result = udp_scan(port)
    when :syn
      result = syn_scan(port)
    end

    if result[:status] == 'open'
      @mutex.synchronize do
        @results << result
        puts "✅ #{result[:port]}/#{result[:protocol]} - #{result[:service]} - #{result[:status]}" if @verbose
      end
    end
  end

  def tcp_scan(port)
    begin
      Timeout::timeout(@timeout) do
        socket = TCPSocket.new(@target, port)
        banner = grab_banner(socket, port)
        socket.close
        
        {
          port: port,
          protocol: 'tcp',
          status: 'open',
          service: COMMON_PORTS[port] || 'unknown',
          banner: banner,
          timestamp: Time.now
        }
      end
    rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH
      {
        port: port,
        protocol: 'tcp',
        status: 'closed',
        service: COMMON_PORTS[port] || 'unknown',
        timestamp: Time.now
      }
    end
  end

  def udp_scan(port)
    begin
      Timeout::timeout(@timeout) do
        socket = UDPSocket.new
        socket.connect(@target, port)
        socket.send("test", 0)
        
        # UDP é stateless, então assumimos que está aberto se não der erro
        socket.close
        
        {
          port: port,
          protocol: 'udp',
          status: 'open|filtered',
          service: COMMON_PORTS[port] || 'unknown',
          timestamp: Time.now
        }
      end
    rescue => e
      {
        port: port,
        protocol: 'udp',
        status: 'closed',
        service: COMMON_PORTS[port] || 'unknown',
        timestamp: Time.now
      }
    end
  end

  def syn_scan(port)
    # Simulação de SYN scan (requer privilégios root para implementação real)
    puts "⚠️  SYN scan requer privilégios administrativos. Usando TCP connect como fallback."
    tcp_scan(port)
  end

  def grab_banner(socket, port)
    return nil unless socket

    begin
      Timeout::timeout(1) do
        case port
        when 21, 25, 110, 143
          # Serviços que enviam banner automaticamente
          banner = socket.recv(1024).strip
        when 22
          # SSH
          socket.send("SSH-2.0-Scanner\r\n", 0)
          banner = socket.recv(1024).strip
        when 80, 443
          # HTTP/HTTPS
          socket.send("HEAD / HTTP/1.0\r\n\r\n", 0)
          banner = socket.recv(1024).split("\n").first&.strip
        else
          # Tenta receber qualquer resposta
          banner = socket.recv(1024).strip if socket.ready?
        end
        
        banner&.gsub(/[^\x20-\x7E]/, '') # Remove caracteres não imprimíveis
      end
    rescue
      nil
    end
  end

  def display_results(duration)
    puts "\n" + "=" * 60
    puts "📋 RESULTADOS DO SCAN"
    puts "=" * 60
    puts "🎯 Alvo: #{@target}"
    puts "⏱️  Duração: #{duration.round(2)}s"
    puts "🔍 Portas abertas: #{@results.size}"
    puts

    if @results.empty?
      puts "❌ Nenhuma porta aberta encontrada"
      return
    end

    @results.sort_by { |r| r[:port] }.each do |result|
      status_icon = result[:status] == 'open' ? '🟢' : '🟡'
      puts "#{status_icon} #{result[:port]}/#{result[:protocol]} - #{result[:service]}"
      puts "   📝 Banner: #{result[:banner]}" if result[:banner] && !result[:banner].empty?
      puts
    end

    # Estatísticas
    puts "-" * 40
    protocols = @results.group_by { |r| r[:protocol] }
    protocols.each do |protocol, results|
      puts "📊 #{protocol.upcase}: #{results.size} portas"
    end
  end

  def save_results
    report = {
      target: @target,
      scan_date: Time.now.iso8601,
      scan_duration: nil,
      scan_type: @scan_type,
      total_ports_scanned: @ports.size,
      open_ports: @results.size,
      results: @results
    }

    File.write(@output_file, JSON.pretty_generate(report))
    puts "💾 Relatório salvo em: #{@output_file}"
  end
end

# CLI Interface
if __FILE__ == $0
  options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Uso: #{$0} [opções] TARGET"
    
    opts.on("-p", "--ports PORTS", "Range de portas (ex: 1-1000, 80,443,22)") do |ports|
      if ports.include?('-')
        range = ports.split('-').map(&:to_i)
        options[:ports] = (range[0]..range[1]).to_a
      else
        options[:ports] = ports.split(',').map(&:to_i)
      end
    end
    
    opts.on("-t", "--threads THREADS", Integer, "Número de threads (padrão: 50)") do |threads|
      options[:threads] = threads
    end
    
    opts.on("-T", "--timeout TIMEOUT", Float, "Timeout em segundos (padrão: 2)") do |timeout|
      options[:timeout] = timeout
    end
    
    opts.on("-v", "--verbose", "Modo verboso") do
      options[:verbose] = true
    end
    
    opts.on("-o", "--output FILE", "Arquivo de saída JSON") do |file|
      options[:output] = file
    end
    
    opts.on("-s", "--scan-type TYPE", "Tipo de scan: tcp, udp, syn") do |type|
      options[:scan_type] = type.to_sym
    end
    
    opts.on("-h", "--help", "Mostra esta ajuda") do
      puts opts
      exit
    end
  end.parse!

  if ARGV.empty?
    puts "❌ Erro: especifique um alvo"
    puts "Exemplo: #{$0} -p 1-1000 -t 100 -v google.com"
    exit 1
  end

  options[:target] = ARGV[0]
  
  scanner = AdvancedPortScanner.new(options)
  scanner.scan
end
