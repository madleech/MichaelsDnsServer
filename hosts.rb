class Host
	attr_reader :ip
	
	def initialize(ip, hostname)
		@ip = ip
		@hostname = hostname
	end
	
	def ptr_ip
		@ip.split('.').reverse.join('.')
	end
	
	# absolute style host (e.g. includes hostname)
	def is_absolute?
		@hostname.include? '.'
	end
	
	# relative style host (e.g. just hostname)
	def is_relative?
		!is_absolute?
	end
	
	def is_wildcard?
		@hostname.include? '*'
	end
	
	def hostname
		is_wildcard? ? as_regex : @hostname
	end
	
	def as_regex
		Regexp.new('^' + @hostname.gsub('.', '\\.').
			gsub('**', '.+'). # multi-depth
			gsub('*', '[^.]+') + # single depth
			'$')
	end
	
	def ==(other)
		self.class == other.class and self.ip == other.ip and self.hostname == other.hostname
	end
end

class HostDB
	attr_reader :records
	
	def initialize
		@records = []
	end
	
	def self.from_lines(lines)
		db = self.new
		lines.each do |line|
			db.add_hosts_format line
		end
		db
	end
	
	def add(ip, hostname)
		@records << Host.new(ip, hostname)
	end
	
	# adds a hosts record style format
	# i.e. "<ip> <host 1> <host 2> <host 3>"
	def add_hosts_format(line)
		if line.strip =~ /([\d\.]+)\s+(.*)/
			ip = $1
			$2.split(/[,\s]+/).each { |host| self.add(ip, host.strip) }
		end
	end
	
	def each
		@records.each do |record|
			yield record
		end
	end
	
	def find_by_ip(ip)
		@records.collect do |record|
			record if record.ip == ip
		end.compact
	end
	
	def find_by_hostname(hostname)
		@records.each do |record|
			return record if record.hostname == hostname
		end
		nil
	end
	
	def ips
		@records.collect{|_| _.ip}.uniq
	end
end
