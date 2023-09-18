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
│       │   ├── 2023-09-19
│       │   │   ├── 09:13.log
│       │   │   └── 20:00.log
│       │   └── saved
│       └── show
│           ├── 2023-09-18
│           │   ├── 21:29.log
│           │   └── 22:02.log
│           ├── 2023-09-19
│           │   └── 20:00.log
│           └── saved
└── development.log
```

## Log Retention Policy
To maintain system performance and manage disk space:

* Date Directory: Max of 2 date-folders, excluding 'saved'. A third will remove the oldest.
* File Limit: Up to 10 log files per date folder. Monitor your logs to stay within this.
* Extended Retention: Need logs longer? Archive or back up them. Accidental losses are avoided this way.
Remember: Files in the 'saved' directory won't be deleted. To keep a log, move it there:
`log/custom_log_space/#{controller_name}/#{action_name}/saved/`

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
