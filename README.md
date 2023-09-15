# CustomLogSpace

The CustomLogSpace gem organizes Rails logs by controller and action. 
With it, developers no longer need to start the rails server repeatedly just to check logs.

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
Logs are saved in the `log/custom_log_space/#{controller_name}/#{action_name}/#{date}/#{time}.log`.

```
user log % tree
.
├── custom_log_space
│   └── articles_controller
│       ├── index
│       │   ├── 2023-09-14
│       │   │   ├── 08:45.log
│       │   │   └── 08:46.log
│       │   └── 2023-09-15
│       │       ├── 02:10.log
│       │       ├── 08:10.log
│       │       └── 08:11.log
│       ├── new
│       │   └── 2023-09-14
│       │       └── 08:45.log
│       └── show
│           └── 2023-09-15
│               └── 02:10.log
└── development.log
```

## Retention Policy

To prevent excessive disk usage, logs within the `date` directory are retained for only 2 days. Any logs older than this retention period will be automatically deleted, starting with the oldest. Ensure that you archive or backup logs if you need them for longer periods.

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
