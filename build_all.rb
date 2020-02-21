#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

def parse_options
	result = OpenStruct.new(:hgrev => 'HEAD')

	parser = OptionParser.new

	parser.banner = <<BANER
Build all Dockerfiles in the current directory.

Usage:

./build_all <options>

BANER

	parser.on('--hgrev REV', "Revision to use (default: #{result.hgrev})") do |rev|
		result.hgrev = rev
	end

	parser.on('-h', '--help', 'Show this message') do
		puts parser
		exit(1)
	end

	parser.parse!

	result
end

def run_docker(hgrev)
	files = Dir['*.Dockerfile']
	files.each do |dockerfile|
		tag = "restinio-#{File.basename(dockerfile, '.Dockerfile')}"
		log_file = "outputs/#{tag}.#{hgrev}.log"
		cmdline = "docker build -t #{tag} -f #{dockerfile} " +
				" --build-arg hgrev=#{hgrev} . | tee #{log_file} 2>&1"
		r = system(cmdline)
		if not r
			raise "build failed!\ncmdline: #{cmdline}\nexit code: #{$?}"
		end
	end
end

opts = parse_options
run_docker(opts.hgrev)

