require_relative '../hosts'

RSpec.describe Host do
	it "should process absolute record" do
		host = Host.new('1.2.3.4', 'test.example.com')
		expect(host.ip).to be == '1.2.3.4'
		expect(host.ptr_ip).to be == '4.3.2.1'
		expect(host.hostname).to be == 'test.example.com'
		expect(host.is_absolute?).to be == true
		expect(host.is_relative?).to be == false
	end
	
	it "should handle relative record" do
		host = Host.new('2.3.4.5', 'test')
		expect(host.ip).to be == '2.3.4.5'
		expect(host.hostname).to be == 'test'
		expect(host.is_absolute?).to be == false
		expect(host.is_relative?).to be == true
	end
	
	it "should match equality" do
		host = Host.new('1.2.3.4', 'test.example.com')
		expect(host == Host.new('1.2.3.4', 'test.example.com')).to be == true
		expect(host == Host.new('1.2.3.4', 'test')).to be == false
		expect(host == Host.new('2.3.4.5', 'test.example.com')).to be == false
	end
	
	it "should handle wildcards" do
		host = Host.new('1.2.3.4', '*.michael')
		expect(host.is_wildcard?).to be == true
		expect(host.hostname).to be == host.as_regex
		expect(host.hostname).to be_a Regexp
		expect(host.hostname).to match 'woof.michael'
		expect(host.hostname).to match 'asdf.michael'
		expect(host.hostname).to_not match 'asdf.michael.com'
	end
end
