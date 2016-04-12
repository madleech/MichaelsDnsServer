task :default => :run

task :run do
  require_relative 'server'
  require_relative 'hosts'
  require 'celluloid'
  
	Celluloid.logger.level = Logger::INFO
  
  port = ENV['port'] || ENV['PORT'] || 53
  interfaces = [:udp, :tcp].collect{|protocol| [protocol, '0.0.0.0', port.to_i]}
  
	# read in config files -- 'hosts' style files
	hosts = HostDB.from_lines(Dir.glob('config/*').flat_map{|file| File.readlines file})
  
  # start server
  server = Server.new(hosts, interfaces: interfaces)
end