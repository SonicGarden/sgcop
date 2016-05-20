# Sgcop

SonicGarden標準のrobocop設定支援をするツール

## Installation

```ruby
gem install specific_install
gem specific_install git@github.com:SonicGarden/sgcop.git
```

## Usage

For non-Rails projects, add the following to the top of your .rubocop.yml file:

```
inherit_gem:
  sgcop: ruby/rubocop.yml
```

If your project is a Rails project, you should use the instruction below, which includes all the standard Ruby house styles, with Rails-specific cops:

```
inherit_gem:
  sgcop: rails/rubocop.yml
```

And then execute:

```
rubocop <options...>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

