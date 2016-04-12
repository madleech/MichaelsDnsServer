task :default => :run

task :run do
  require_relative 'server'
  require_relative 'hosts'
  require 'celluloid'
  
	Celluloid.logger.level = Logger::INFO
  
	# read in config. config is 'hosts' style file
	hosts = HostDB.from_lines(File.readlines 'config/hosts')
  
  server = Server.new(hosts)
end