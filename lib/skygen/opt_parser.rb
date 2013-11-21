require 'ostruct'
require 'optparse'

class OptParse
  def self.parse(args)
    options = OpenStruct.new
    options.grammars = ['./grammar.gr']
    options.grammar = nil
    options.complexity = nil
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [CONFIG]"

      opts.on("-f", "--file FILE1,FILE2",
             "Select the FILES that contain the grammars to load.",
             "  Example: 'grammar.gr,g.txt'") do |log|
             options.grammars = log.split(/[\s,]/) 
       end

      opts.on("-g", "--grammar GRAMMAR_NAME",
             "Select the grammars to use by the generator.",
             "  Example: 'Grammar1'") do |g|
             options.grammar = g
       end
      
      opts.on("-c", "--complexity COMPLEXITY",
             "The complexity of the skyline (1-4)",
             "  Example: '1'") do |c|
             raise OptionParser::InvalidArgument unless (1..4).include? c.to_i
             options.complexity = c.to_i
       end
      
    end

    opt_parser.parse!(args)
    options
  end

  def self.config_object(buffer)
    begin
      OptParse.parse(buffer)
    rescue OptionParser::MissingArgument,OptionParser::InvalidArgument => e
      case e.message[-1]
      when "f"
        puts "Expected a list of comma separated files"
        puts " See '#{__FILE__} -h' for help."
      when "c"
        puts "Complexity must be between 1 and 4"
      end
      abort
    rescue OptionParser::InvalidOption => e
      puts "#{__FILE__}: Unknown option."
      puts " See '#{__FILE__} -h' for help."
      abort
    end
  end

end
