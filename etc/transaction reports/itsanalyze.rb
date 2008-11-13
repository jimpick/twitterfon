#!/usr/bin/ruby
require 'pp'

FILE_PATTERN = '*.txt'

apps = {}

files = Dir.glob(FILE_PATTERN)
files.each do |fname|
  open(fname) do |f|
    f.gets
    while s = f.gets
      s = s.chomp
      ary = s.split(/\t/)
      appname = ary[6].to_sym
      type = ary[8].to_i
      count = ary[9].to_i
      cc = ary[14]
      
      if type == 1
        h = apps[appname]
        unless h
          h = { :count => 0 }
          apps[appname] = h
        end
        h[:count] += count
      end
    end
  end
end

apps.each do |k,h|
  puts "#{k} #{h[:count]}"
end
