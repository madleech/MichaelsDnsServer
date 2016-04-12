require 'rubydns'
require_relative '../server'

describe Server do
	Name = Resolv::DNS::Name
	IN = Resolv::DNS::Resource::IN

	let(:interfaces) {[[:udp, "0.0.0.0", 5300]]}
	
	def start_server(**opts)
		hosts = opts[:hosts] || example_hosts
		opts[:upstream] ||= false
		opts[:interfaces] ||= interfaces
		opts[:asynchronous] ||= true
		
		Celluloid.shutdown
		Celluloid.boot
		
		hosts = HostDB.from_lines(hosts)
		server = Server.new(hosts, opts)
	end
	
	let(:example_hosts) {[
		"1.2.3.4 test.domain test.differentdomain",
		"2.3.4.5 root.wildcarddomain *.wildcarddomain",
		"3.4.5.6 **.very.wild.domain",
	]}
	let(:resolver) {RubyDNS::Resolver.new(interfaces)}
	
	it "should match absolute domains" do
		start_server
		expect(resolver.query("test.domain", IN::A)).to be_ip '1.2.3.4'
		expect(resolver.query("test.differentdomain", IN::A)).to be_ip '1.2.3.4'
	end
	
	it "should skip domains we don't own" do
		start_server
		expect(resolver.query("test.notmydomain", IN::A)).to be_nxdomain
	end
	
	it "look up wildcard domains" do
		start_server
		expect(resolver.query("root.wildcarddomain", IN::A)).to be_ip '2.3.4.5'
		expect(resolver.query("another.wildcarddomain", IN::A)).to be_ip '2.3.4.5'
		expect(resolver.query("too.deep.wildcarddomain", IN::A)).to be_nxdomain
	end
	
	it "should look up arbitrarily deep wildcard domains" do
		start_server
		expect(resolver.query("very.wild.domain", IN::A)).to be_nxdomain
		expect(resolver.query("onelevel.very.wild.domain", IN::A)).to be_ip '3.4.5.6'
		expect(resolver.query("two.levels.very.wild.domain", IN::A)).to be_ip '3.4.5.6'
		expect(resolver.query("even.more.levels.very.wild.domain", IN::A)).to be_ip '3.4.5.6'
	end
	
	it "should resolve ptrs" do
		start_server
		expect(resolver.query("4.3.2.1.in-addr.arpa", IN::PTR)).to be_addr 'test.domain.'
		expect(resolver.query("5.4.3.2.in-addr.arpa", IN::PTR)).to be_addr 'root.wildcarddomain.'
		expect(resolver.query("6.5.4.3.2.in-addr.arpa", IN::PTR)).to be_nxdomain
	end
	
	it "should do recursive lookups" do
		start_server(upstream: [[:udp, '8.8.8.8', 53]])
		expect(resolver.query("www.google.com", IN::A)).to_not be_nxdomain
	end
end
