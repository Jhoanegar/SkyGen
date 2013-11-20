require_relative './lib/skygen/parser'
require_relative './lib/skygen/opt_parser'
require_relative './lib/skygen/core_ext'
require_relative './lib/skygen/grammar'
require 'pp'
opt = OptParse.config_object(ARGV)
grammars = Parser.parse(opt.grammars)
pp grammars
