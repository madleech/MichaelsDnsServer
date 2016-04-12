#!/usr/bin/env ruby

require 'rubygems'
require 'rubydns'
require 'rubydns/system'
require_relative 'hosts'

class Server
	attr_accessor :server
	
	Name = Resolv::DNS::Name
	IN = Resolv::DNS::Resource::IN
	
	INTERFACES = [
		[:udp, "0.0.0.0", 5300],
		[:tcp, "0.0.0.0", 5300]
	]
	UPSTREAM = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])

	def initialize(hosts, interfaces: INTERFACES, asynchronous: false)
		RubyDNS::run_server(:listen => interfaces, asynchronous: asynchronous) do
			fallback_resolver_supervisor = RubyDNS::Resolver.supervise(RubyDNS::System.nameservers)
			
			# set up A records
			hosts.each do |host|
				match(host.hostname, IN::A) do |request|
					request.respond! host.ip
				end
			end
			
			# set up PTR records
			hosts.ips.each do |ip|
				reverse = hosts.find_by_ip(ip).first
				addr = "#{reverse.ptr_ip}.in-addr.arpa"
				hostname = reverse.hostname
				match(addr, IN::PTR) do |transaction|
					transaction.respond! Name.create("#{hostname}.")
				end
			end
			
			# Default DNS handler
			otherwise do |transaction|
				logger.info 'Passing DNS request upstream...'
				transaction.passthrough!(fallback_resolver_supervisor.actors.first)
			end
		end
	end
end
