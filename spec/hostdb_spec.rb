require_relative '../hosts'

RSpec.describe HostDB do
	describe "basic functionality" do
		let(:db) { HostDB.new }
		
		it "should add IP" do
			db.add '1.2.3.4', 'test.com'
			expect(db.records.count).to be == 1
			
			db.add_hosts_format '2.3.4.5 woof.test'
			expect(db.records.count).to be == 2
			expect(db.records.last).to be == Host.new('2.3.4.5', 'woof.test')
			
			db.add_hosts_format '2.3.4.5 another.test, something.else.com'
			expect(db.records.count).to be == 4
		end
		
		it "should yield" do
			db.add_hosts_format '2.3.4.5 another.test, something.else.com'
			expect { |b| db.each(&b) }.to yield_control.exactly(2).times
		end
		
		it "should add from lines" do
			lines = ["# comment\n", "1.2.3.4 test, woof\n", "\n", "4.5.6.7 server.hostname.domain\n"]
			db = HostDB.from_lines(lines)
			
			expect(db.records.count).to be == 3
			expect(db.records.first).to be == Host.new('1.2.3.4', 'test')
		end
	end
	
	describe "lookup functionality" do
		let (:db) {
			db = HostDB.new
			db.add_hosts_format '1.2.3.4 michael.test'
			db.add_hosts_format '2.3.4.5 another.test, something.else.com'
			db
		}
		
		it "should find all hostnames by ip" do
			expect(db.find_by_ip '1.2.3.4').to be == [Host.new('1.2.3.4', 'michael.test')]
			expect(db.find_by_ip '2.3.4.5').to be == [
				Host.new('2.3.4.5', 'another.test'),
				Host.new('2.3.4.5', 'something.else.com')
			]
			expect(db.find_by_ip '99.99.99.99').to be == []
		end
		
		it "should find ip by hostname" do
			expect(db.find_by_hostname 'michael.test').to be == Host.new('1.2.3.4', 'michael.test')
			expect(db.find_by_hostname 'another.test').to be == Host.new('2.3.4.5', 'another.test')
			expect(db.find_by_hostname 'something.else.com').to be == Host.new('2.3.4.5', 'something.else.com')
			expect(db.find_by_hostname 'null.com').to be == nil
		end
		
		it "should return all ips" do
			expect(db.ips.count).to be == 2
			expect(db.ips).to be == ['1.2.3.4', '2.3.4.5']
		end
	end
end