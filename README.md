# CustomLogSpace

The CustomLogSpace gem allows Rails developers to direct Rails logs to files, organized by each controller and action. This organization simplifies debugging and analysis.

## Installation

To begin, add the gem to your application's Gemfile:

```ruby
group :development do
  gem 'custom_log_space'
end
```

Next, run:

```bash
$ bundle install
```

Alternatively, you can install it directly using:

```bash
$ gem install custom_log_space
```

## Usage
Logs are saved in the `log/custom_log_space/[date]/[time]/[controller_name]/` directory. The filenames follow the pattern: `[action_name].log`.

<img width="492" alt="スクリーンショット 2023-09-12 8 37 43" src="https://github.com/nishikawa1031/custom_log_space/assets/53680568/95cf44c8-e256-44d0-b0cb-9d6367601985">

## Ignoring Logs in Git
If needed, add `/log/custom_log_space/*` to your `.gitignore` to ensure the logs aren't committed to your repository.
```
/log/custom_log_space/*
```

## Supported environments
- Rails 7
- Ruby 3

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/custom_log_space. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/custom_log_space/blob/main/CODE_OF_CONDUCT.md).

## License

This gem is open-sourced under the [MIT License](https://opensource.org/licenses/MIT) terms.

## Code of Conduct

All participants in the CustomLogSpace project, whether they're interacting with codebases, issue trackers, chat rooms, or mailing lists, are expected to follow the [code of conduct](https://github.com/nishikawa1031/custom_logger/blob/main/CODE_OF_CONDUCT.md).
