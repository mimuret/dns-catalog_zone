# Dns::CatlogZone

[![Coverage Status](https://coveralls.io/repos/github/mimuret/dns-catlog_zone/badge.svg?branch=master)](https://coveralls.io/github/mimuret/dns-catlog_zone?branch=master)

PoC of Catlog zone (draft-muks-dnsop-dns-catalog-zones)

## インストール方法


Add this line to your application's Gemfile:

```ruby
gem 'dns-catlog_zone'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dns-catlog_zone

## 使い方

1. configファイルの生成

```bash
$ catz init
```

2. config確認

```bash
$ catz verify
```

3. config生成

```bash
$ catz make
```

4. 反映用のscriptとcronを設定します。

scripts https://github.com/mimuret/dns-catlog_zone/tree/master/share

### 対応ソフトウェア
* NSD4 (default)
* Knot dns
* YADIFA

## Contributing

バグレポートとプルリクエストはGitHub(https://github.com/mimuret/dns-catlog_zone)まで

対応するソフトウェアを増やしたい場合はプルリクエストしてマージするか、

Dns::CatlogZone::Provider::(作りたい実装名)のクラスを作ってLOAD_PATHにおいてください。


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

