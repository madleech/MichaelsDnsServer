task :default => :run

task :run do
  require_relative 'server'
  require_relative 'hosts'
  require 'celluloid'
  require 'rubydns/system'
  
  # hush it a bit
	Celluloid.logger.level = Logger::INFO
  
  # work out port to run on
  port = ENV['port'] || ENV['PORT'] || 53
  interfaces = [:udp, :tcp].collect{|protocol| [protocol, '0.0.0.0', port.to_i]}
  
  # work out upstream servers
  if upstream = ENV['upstream'] || ENV['UPSTREAM']
  	# format is <ip>,<ip>,<ip>
  	upstream = upstream.split(',').flat_map{|ip| [[:udp, ip, 53], [:tcp, ip, 53]]}
  else
  	upstream = RubyDNS::System.nameservers
  end
  
	# read in config files -- 'hosts' style files
	hosts = HostDB.from_lines(Dir.glob('config/*').flat_map{|file| File.readlines file})
  
  # start server
  server = Server.new(hosts, interfaces: interfaces, upstream: upstream)
end