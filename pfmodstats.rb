#!/usr/bin/ruby

require 'rubygems'
require 'httparty'
require 'optparse'
require 'json'

@options = {:user => nil, :verbose => false, :format => "text", :graphite_prefix => nil}
@reply = nil

opt = OptionParser.new

opt.on("--user [USER]", "-u", "Forge user to display stats for") do |u|
  @options[:user] = u
end

opt.on("--verbose", "-v", "Verbose output") do |v|
  @options[:verbose] = true
end

opt.on("--format [text|graphite]", "Output format") do |f|
  unless ["graphite", "text"].include?(f.downcase)
    abort "Unknown output format %s expected 'text' or 'graphite'" % f
  end

  @options[:format] = f.downcase
end

opt.on("--graphite-prefix [PREFIX]", "--prefix", "-p", "Graphite prefix") do |p|
  @options[:graphite_prefix] = p
end

opt.parse!

abort "Please specify a user to display stats for" unless @options[:user]

unless @options[:user] == "STDIN"
  response = HTTParty.get("http://forgeapi.puppetlabs.com/v2/users/%s/modules" % @options[:user])

  unless response.code == 200
    puts "Failed to retrieve module stats for user %s: %s" % [@options[:user], response.message]
    puts response.body if @options[:verbose]
    exit 1
  end

  @reply = JSON.parse(response.body)
else
  @reply = JSON.parse(STDIN.lines.to_a.join("\n"))
end

def parse_modules(json)
  modules = {}

  json.each do |mod|
    modules[ mod["name"] ] = {"downloads" => mod["downloads"]}
  end

  modules
end

def render_as_text(modules)
  padding = modules.keys.map{|k| k.size}.to_a.max + 2

  format = "%-#{padding}s"

  puts "Modules for user: %s" % @options[:user]
  puts
  puts "#{format}|Count" % "Module"
  puts "#{format}+-----" % ("-" * padding)

  modules.keys.sort_by do |k|
    modules[k]["downloads"]
  end.reverse.each do |m|
    puts "#{format}|%d" % [m, modules[m]["downloads"]]
  end
end

def render_as_graphite(modules)
  abort "Graphite rendering needs a graphite prefix supplied using --graphite-prefix" unless @options[:graphite_prefix]

  modules.keys.each do |m|
    puts "%s.%s %d %d" % [@options[:graphite_prefix], m, modules[m]["downloads"], Time.now.to_i]
  end
end

def render(modules, format)
  send("render_as_#{format}", modules)
end

render(parse_modules(@reply), @options[:format])
