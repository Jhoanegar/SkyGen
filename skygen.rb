#!/usr/bin/env ruby
require_relative './lib/skygen/parser'
require_relative './lib/skygen/opt_parser'
require_relative './lib/skygen/core_ext'
require_relative './lib/skygen/grammar'
require_relative './lib/skygen/interpreter'
require 'pp'

opt = OptParse.config_object(ARGV)
grammars = Parser.parse(opt.grammars)
int = Interpreter.new(grammars,opt)
int.run

