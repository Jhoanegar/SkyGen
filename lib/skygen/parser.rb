require 'pry'
module Parser
  NTSymbol = /[A-Z]+/
  TSymbol = /[a-z]+/
  AssignSymbol = /(?:->|::=)/
  Probability = /\.[0-9]+/
  def self.parse(grammars)
    binding.pry
    parsed_grammars = []
    begin
      grammars.each do |g|
        f = File.open(g)
        self.get_grammars(f,parsed_grammars)
      end
    rescue Errno::ENOENT => e
      puts e.message
      abort
    end
    return parsed_grammars
  end

  def self.get_grammars(file,output)
    line = body = ""
    i = 0
    body_grammar = []
    name = ""
    loop do 
      line = file.gets
      break if line.nil?
      next if line.strip.empty?
      line.strip!
      body_grammar = []
      name = line.cut
      loop do
        body = file.gets
        break if body.nil?
        break if body.strip == "end"
        next if body.empty?
        body_grammar << body.strip
      end 
      output << self.create_grammar(name,body_grammar) 
    end
  end
  
  def self.create_grammar(name,body)
    rules = []
    body.each do |rule|
      new_rule = []
      tokens = rule.split(" ")
      tokens.each_with_index do |t,i|
        if i == 0
          new_rule << t.to_sym
        else
          next if t =~ AssignSymbol
          new_rule << case t
                   when TSymbol
                     t
                   when NTSymbol
                     t.to_sym
                   when Probability
                     t.to_f
                   else
                     raise SyntaxError , " in rule #{rule}" 
                   end
        end #if
      end #token  
      rules << new_rule
    end #rule
    return Grammar.new(name,rules)
  end
  
  class SyntaxError < StandardError
  end
end

