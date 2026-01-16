# Nucop::Cops

This gem contains custom [RuboCop](https://github.com/rubocop-hq/rubocop) cops for Nulogy's Ruby projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nucop-cops'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nucop-cops

## Usage

Add the following to your `.rubocop.yml` file:

```yaml
require: nucop-cops
```

## Custom Cops

This gem includes the following custom cops:

### Nucop/ExplicitFactoryBotUsage

Looks for usages of `FactoryGirl.create`, etc. and suggests using the factory method directly.

**Example:**

```ruby
# bad
job = FactoryGirl.create(:job, project: project)
FactoryGirl.build(:project, code: "Super Project")

# good
job = create(:job, project: project)
build(:project, code: "Super Project")
```

### Nucop/NoCoreMethodOverrides

Prevents overriding core Ruby methods.

### Nucop/NoWipSpecs

Prevents WIP specs from being committed.

### Nucop/OrderedHash

Ensures hashes are ordered consistently.

### Nucop/ReleaseTogglesUseSymbols

Ensures release toggles use symbols.

### Nucop/ShadowingFactoryBotCreationMethods

Prevents shadowing FactoryBot creation methods.

## Development

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
