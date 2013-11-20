require 'ostruct'
require 'optparse'

class OptParse
  def self.parse(args)
    options = OpenStruct.new
    options.grammars = ['./grammar.gr']
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [CONFIG]"

      opts.on("-g", "--grammar FILE1,FILE2",
             "Select the grammars to load.",
             "  Example: 'grammar.gr'") do |log|
             options.grammars = log.split(/[\s,]/) 
       end

    end

    opt_parser.parse!(args)
    options
  end

  def self.config_object(buffer)
    begin
      opt = OptParse.parse(buffer)
    rescue OptionParser::MissingArgument,OptionParser::InvalidArgument => e
      case e.message[-1]
      when "g"
        puts "Expected a list of comma separated files"
        puts " See '#{__FILE__} -h' for help."
      end
      abort
    rescue OptionParser::InvalidOption => e
      puts "#{__FILE__}: Unknown option."
      puts " See '#{__FILE__} -h' for help."
      abort
    end
  end

end
