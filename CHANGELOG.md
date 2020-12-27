# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]
### Added
- Start using file `CHANGELOG.md` to make it easier for users and contributors
  to see precisely what notable changes have been made between each release (or
  version) of the project.
- A short documentation is now in file `README.md`.
- Print number of lines processed after each *pass*.
- Print number of bytes written to `outfile` after second pass.
- Support for all missing `Jcc` aliases.
- Support `loope` and `loopne` aliases.
- Support `rep`, `repe`, and `repne` aliases.

### Changed
- Correct capitalization for error messages.

### Removed
- Print updated number of lines processed after each *line* to speed up.

### Fixed
- Line number in message "Error at line ..." is off by one.
- Prints incomplete error message, if symbol name too long or too many symbols.
- Uses DOS 2.0 functions, but doesn't check version.
- On command line if source file name is not specified with an extension, then
  the file will be overwritten by the assembler, i.e., source code is lost.
- Crash when trying to use `inc`/`dec` instruction on a segment register.
