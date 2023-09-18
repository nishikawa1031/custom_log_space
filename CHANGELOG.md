## [Unreleased]
## [0.1.6] - 2023-09-19
### Changed
I have modified the implementation to create a 'saved' folder.
`log/custom_log_space/#{controller_name}/#{action_name}/saved/`

## [0.1.5] - 2023-09-18
### Changed
Modify so that only 10 files can be created

## [0.1.4] - 2023-09-15
### Changed
Simplify the gem description

## [0.1.3] - 2023-09-15
### Changed
The retention period for logs within the date directory has been changed from 3 days to 2 days.

## [0.1.2] - 2023-09-15
### Changed
Modified the file path structure for logs. New structure: log/custom_log_space/#{controller_name}/#{action_name}/#{date}/#{time}.log.

## [0.1.1] - 2023-09-13
### Added
- Added `cleanup_old_directories` method to manage and delete old directories, ensuring only the two most recent date-directories remain.

## [0.1.0] - 2023-09-12
- Initial release
