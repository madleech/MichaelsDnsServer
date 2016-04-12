# Michaels Dns Server
Simple DNS server built on top of [RubyDNS](https://github.com/ioquatix/rubydns). Suitable for handling DNS for a home lan.

## Usage
* Create some host files in `config/`, they can be named whatever you like. See below for format.
* Run `bundle exec rake` to start the server. Set the env-var `PORT` to us a different port; default is port 53.
* Test the output: `dig @127.0.0.1 -p <port> <your dns query>`

## Config File Format
Config file is more-or-less a `/etc/hosts` style file. You can copy your existing hosts file there and it should work without any changes.

To make things more interesting, it supports some extra parameters:

* Wildcards: use a `*` to match a single level.
* More wildcards: use a `**` to match arbitrary depth.

E.g.:

	1.2.3.4 sample.domain.tld alias.domain.tld
	2.3.4.5 *.wildcard.tld
	3.4.5.6 **.very.wild.tld

Results:

* Lookup for `sample.domain.tld` gives 1.2.3.4.
* Lookup for `test.wildcard.tld` gives 2.3.4.5, while a lookup for `something.else.wildcard.tld` gives no results.
* Lookup for `test.very.wild.tld` gives 3.4.5.6, as does `another.test.very.wild.tld` and `super.deep.down.the.rabbit.hole.very.wild.tld`.

## Reverse Lookups
Always useful to have, the server will automatically create a reverse DNS entry for the _first_ hostname against each IP address.

E.g. using the sample host file above:

	$ dig +short @localhost -p 5300 -x 1.2.3.4
	sample.domain.tld.
