[![CI](https://github.com/SixiS/rails-conflicted-credentials/actions/workflows/ci.yml/badge.svg)](https://github.com/SixiS/rails-conflicted-credentials/actions/workflows/ci.yml)

# Rails::Conflicted::Credentials

A gem to help editing rails credentials files with git merge conflicts.

## Pitch:

Are your rails credentials stuck looking like:
```
<<<<<<< HEAD
axssa4Lio6dTXKohAxnb9xGK47iD2tPguExc10WG--it7a+imKmhi2/oHn--SYem69mNPcb4PRLVghntzw==
=======
gg3TRVAh5NYnGx7Vwu8KpfmrspG75Oh0WSTFW9QC--3WhE+IKJeq4ZNPEv--BOT8y29V6OL9D8A4oN9FLg==
>>>>>>> @{-1}
```

and you wish they could be edited like:
```
baz: foo
<<<<<<< HEAD
foo: bar
=======
foo: baz
>>>>>>> @{-1}
bar: baz
```

Then this is the gem for you!  
Simply install the gem and use the new command `rails conflicted_credentials:edit`

## Installation

Add this line to your application's Gemfile:
```ruby
gem "rails-conflicted-credentials"
```
And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-conflicted-credentials

## Usage

This gem contains one new rails command:

```bash
rails conflicted_credentials:edit
```

It works with all the same options as `rails credentials:edit`.
```bash
Options:
  -e, [--environment=ENVIRONMENT]  # The environment to run `credentials` in (e.g. test / development / production).
```

More info:
```bash
rails credentials:help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sixis/rails-conflicted-credentials. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sixis/rails-conflicted-credentials/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rails::Conflicted::Credentials project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sixis/rails-conflicted-credentials/blob/master/CODE_OF_CONDUCT.md).
