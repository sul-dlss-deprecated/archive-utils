archive-utils
=============

[![Gem Version](https://badge.fury.io/rb/archive-utils.svg)](http://badge.fury.io/rb/archive-utils)

Ruby utilities for archival data (BagIt, Fixity, Tarfile).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'archive-utils'
```

And then execute:

```sh
$ bundle update
```

Or install it yourself as:

```sh
$ gem install archive-utils
```

## Usage

```ruby
include 'archive-utils'

bag = Archive::BagitBag.new()
```

## Contributing

1. Fork it (https://github.com/[my-github-username]/archive-utils/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

