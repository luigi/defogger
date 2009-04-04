require 'sunlight'
Sunlight::Base.api_key = Key.find_by_name('sunlight').key
