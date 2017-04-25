# Dns::CatlogZone
[![Build Status](https://travis-ci.org/mimuret/dns-catlog_zone.svg?branch=master)](https://travis-ci.org/mimuret/dns-catlog_zone)
[![Coverage Status](https://coveralls.io/repos/github/mimuret/dns-catlog_zone/badge.svg?branch=master)](https://coveralls.io/github/mimuret/dns-catlog_zone?branch=master)

PoC of Catlog zone (draft-muks-dnsop-dns-catalog-zones)
 
## supported name server softwares
* NSD4 (default)
* Knot dns
* YADIFA

## Installation

```bash
$ git clone https://github.com/mimuret/dns-catlog_zone
$ cd dns-catlog_zone
$ bundle install --path=vendor/bundle
```

## Usage

+ configuration

make CatlogZone file.

```bash
$ bundle exec catz init
$ cat CatlogZone
```

CatlogZone below
```ruby
setting("catlog.example.jp") do |s|
	s.software="nsd"
	s.source="file"
	s.zonename "catlog.example.jp"
	s.zonefile "/etc/nsd/catlog.example.jp.zone"
end
````

+ make name server config

config output to stdout
```bash
$ catz make
```


## Settings attribute
| name | value | default |
|:-----------|------------:|:------------:|
|zonename|string(domain name) default catlog.example||
|software|string default nsd||
|source|string default file||
|output|string default stdout||

### source attributes
#### source file
| name | value | required |
|:-----------|------------:|:------------:|
|source|file||
|zonefile|path|true|

#### source axfr
| name | value | required |
|:-----------|------------:|:------------:|
|source|axfr||
|server|ip or hostname|true|
|port|int default 53|false|
|tsig|string|false|
|src_address|ip|false|
|timeout|int default 30|false|

### software attributes
#### software nsd
| name | value | required |
|:-----------|------------:|:------------:|
|software|nsd||

#### software knot
| name | value | required |
|:-----------|------------:|:------------:|
|software|knot||

#### software yadifa
| name | value | required |
|:-----------|------------:|:------------:|
|software|yadifa||

### output attribute
#### software stdout
| name | value | required |
|:-----------|------------:|:------------:|
|output|stdout||

#### software file
| name | value | required |
|:-----------|------------:|:------------:|
|output|file||
|output_path|path|true|

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mimuret/dns-catlog_zone.

OR make Dns::CatlogZone::Provider::(Software) gem


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

