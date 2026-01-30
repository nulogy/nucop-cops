# Nucop Cops

Custom [RuboCop](https://github.com/rubocop-hq/rubocop) cops for Nulogy's Ruby projects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "nucop-cops"
```

And then execute:

```bash
bundle install
```

## Usage

Add the following to your `.rubocop.yml`:

```yaml
require:
  - nucop
```

## Custom Cops

This gem provides the following custom cops:

### Nucop/ExplicitFactoryBotUsage

Detects explicit usage of `FactoryBot.create`, `FactoryGirl.build`, etc. in spec files. The factory methods are globally available, so the explicit constant reference is unnecessary.

### Nucop/NoCoreMethodOverrides

Detects method definitions that override Ruby/Rails core methods like `blank?`, `present?`, and `empty?`.

### Nucop/NoWipSpecs

Detects specs tagged with `:wip` (work in progress) which should not be committed.

### Nucop/ReleaseTogglesUseSymbols

Ensures that release toggle names are specified as symbols rather than strings.

### Nucop/ShadowingFactoryBotCreationMethods

Detects method definitions in spec files that would shadow FactoryBot methods like `create`, `build`, `build_list`, etc.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
