# RoChecker

O-Checker Ruby implimentation

## Requirements
- Ruby 2.0

## Installation
	$ cd ro_checker
	$ bundle install
	$ bundle exec rake install

## Usage
### Command line
- Check File
    $ ro-checker -f TARGET_PATH

- help
    $ ro-checker -h

### In Ruby Script
    require 'ro_checker'

    path = 'TARGET PATH'
    results = RoChecker.check_from_path(path)
    puts (results.values.any?{|v| v == false } ? 'suspicious' : 'not suspicious')

    max_key_len = results.keys.max_by{|k| k.length }.length
    results.each do |key, val|
      k = key.to_s.gsub(/_/,' ') + ":"
      v = val ? 'yes' : 'no'
      puts "  #{k.ljust(max_key_len+2)} #{v}"
    end

