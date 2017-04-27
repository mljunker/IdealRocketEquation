#!/usr/bin/env ruby
require "fileutils"

FILES = Dir['Group*']

FILES.each { |f|
  if File.ftype(f) == "link"
  realpath = File.readlink(f)
  FileUtils.rm("./#{f}")
  FileUtils.cp(realpath, "./#{f}")
  end
}
