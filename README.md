# RoChecker

O-Checker Ruby implimentation.

This gem is based on the following documents.

- http://www.slideshare.net/codeblue_jp/yuuhei-otsubo-enpub
- http://www.slideshare.net/codeblue_jp/yuuhei-otsubo-japub


## Installation
	$ gem install ro_checker

## Usage
### Command line
Check File

    $ ro-checker TARGET_PATH

Verbose mode

    $ ro-checker -v TARGET_PATH

Help

    $ ro-checker -h

### In Ruby Script
    require 'ro_checker'

    path = 'TARGET PATH'
    results = RoChecker::CFB.check_from_path(path)
    puts (results.values.any?{|v| v == false } ? 'suspicious' : 'not suspicious')

    max_key_len = results.keys.max_by{|k| k.length }.length
    results.each do |key, val|
      k = key.to_s.gsub(/_/,' ') + ":"
      v = val ? 'yes' : 'no'
      puts "  #{k.ljust(max_key_len+2)} #{v}"
    end

## Limitation
Only CFB file is supported now. PDF is not supported.

## Contributing

1. Fork it ( http://github.com/masatanish/ro_checker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
