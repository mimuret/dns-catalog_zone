# Dns::CatlogZone

[![Coverage Status](https://coveralls.io/repos/github/mimuret/dns-catlog_zone/badge.svg?branch=master)](https://coveralls.io/github/mimuret/dns-catlog_zone?branch=master)

PoC of Catlog zone(draft-muks-dnsop-dns-catalog-zones)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dns-catlog_zone'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dns-catlog_zone

## Usage

1. init config

```bash
$ catz init
```

2. check config

```bash
$ catz verify
```

3. make name server software configuration

```bash
$ catz make
```

4. setting cron script

see scripts https://github.com/mimuret/dns-catlog_zone/tree/master/share

### support software
* NSD4 (default)
* Knot dns
* YADIFA

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mimuret/dns-catlog_zone.

OR make Dns::CatlogZone::Provider::(Software) gem

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

