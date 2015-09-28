# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - 2015-10-04
### Changed
- Significant changes to API for `identikon`. Please see updated documentation. Related to [#16](https://github.com/DarrenN/identikon/issues/16)
- Two new functions provided: `save-identikon`, `identikon->string`. Related to [#15](https://github.com/DarrenN/identikon/issues/15)
- `identikon` can now take a file as input via the `#:filename` flag.
- Added tests, dealt with weird errors in test submod w/ quickcheck
- Updated documentation

### Fixed
- [#18](https://github.com/DarrenN/identikon/issues/18) Contract-violation when saving identikon to file
