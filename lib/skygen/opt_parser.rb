require 'ostruct'
require 'optparse'

class OptParse
  def self.parse(args)
    options = OpenStruct.new
    options.grammars = ['./grammar.gr']
    options.grammar = nil
    options.complexity = nil
    options.save_file = './output.txt'
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [CONFIG]"

      opts.on("-f", "--file FILE1,FILE2",
             "The files that contain the grammars to load.",
             "  Default: 'grammar.gr") do |file|
             options.save_file = file
       end

      opts.on("-g", "--grammar GRAMMAR_NAME",
             "The grammars to use by the generator.",
             "  Default: N/A") do |g|
             options.grammar = g
       end
      
      opts.on("-c", "--complexity COMPLEXITY",
             "The complexity of the skyline (1-9)",
             "  Default: N/A") do |c|
             raise OptionParser::InvalidArgument unless (1..9).include? c.to_i
             options.complexity = c.to_i
       end

       opts.on("-o", "--output FILE",
             "The file to save the results",
             "  Default: 'output.txt'") do |c|
             raise OptionParser::InvalidArgument unless (1..9).include? c.to_i
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
