[![Build Status](https://travis-ci.org/sul-dlss/archive-utils.svg?branch=master)](https://travis-ci.org/sul-dlss/archive-utils)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/archive-utils/badge.svg)](https://coveralls.io/github/sul-dlss/archive-utils)
[![Dependency Status](https://gemnasium.com/badges/github.com/sul-dlss/archive-utils.svg)](https://gemnasium.com/github.com/sul-dlss/archive-utils)
[![Gem Version](https://badge.fury.io/rb/archive-utils.svg)](https://badge.fury.io/rb/archive-utils)

# archive-utils

Ruby gem containing utilities for archival data (BagIt, Fixity, Tarfile).

**Note** As of Q1 2018, this repository is in the process of being replaced by https://github.com/sul-dlss/preservation_robots (not yet complete as of this writing).

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
