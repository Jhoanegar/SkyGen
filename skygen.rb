#!/usr/bin/env ruby
require 'pp'
require 'pry'
require 'tree'
require_relative './lib/skygen/parser'
require_relative './lib/skygen/opt_parser'
require_relative './lib/skygen/core_ext'
require_relative './lib/skygen/grammar'
require_relative './lib/skygen/interpreter'
require_relative './lib/skygen/skyline'
require_relative './lib/skygen/parse_node'
require_relative './lib/skygen/rule'
require_relative './lib/skygen/tree_node_ext'
opt = OptParse.config_object(ARGV)
grammars = Parser.parse(opt.grammars)
int = Interpreter.new(grammars,opt)
int.run

