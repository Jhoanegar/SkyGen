require 'curses'
require 'pry'
class Interpreter
  include Curses

  EASY = 1
  NORMAL = 2
  COMPLEX = 3
  AUTO = 4

  def initialize(grammars,options)
    @grammars = grammars
    @grammar = get_grammar(options.grammar)
    @complexity = options.complexity || get_complexity
  end

  def run 
    display_setup
  end


  def display_setup
    init_screen
      move_print 1,2, "You've selected:"
      move_print 3,4, "Grammar:"
      move_print 5,6, @grammar.name
      move_print 7,4, "Complexity:"
      move_print 9,6, complexity_to_s
      wait "<Press any key to generate a skyline>" 
    close_screen
  end
  def get_grammar(grammar_name)
    if grammar_name == nil and @grammars.size == 1
      return @grammar.first
    elsif grammar_name and @grammars.size > 1
      grammar = find_grammar(grammar_name)
      return grammar unless grammar.nil?
    end
    init_screen
      clear
      move_print 2,5, "No grammar selected, select one of the following #{@grammars.size}."
      refresh
      wait
    close_screen 
    loop do
      @grammars.each do |g|
        if print_grammar(g.name).downcase == 's'
          return g
        end
      end
    end
    return nil
  end

  def get_complexity
    init_screen
      input = 0
      loop do
        move_print 2,5, "Enter a complexity value:"
        move_print 3,2, "1) Easy."
        move_print 4,2, "2) Normal."
        move_print 5,2, "3) Complex."
        move_print 6,2, "4) Auto."
        refresh
        input = wait("<Enter the selected complexity (1-4)>").to_i
        break if (1..4).include? input
      end
    close_screen
    return input
  end


  def print_grammar(name)
    init_screen
      col = (cols/3)
      output = ""
      tab = "\t"
      def_symbol = "->"
      grammar = find_grammar(name)
      move_print 2,2, "Name:"
      move_print 2,col, name
      move_print 4,2, "Nonterminal symbols: " 
      move_print 4,col, grammar.nt_symbols.join(" ")
      move_print 6,2, "Terminal symbols: "
      move_print 6,col, grammar.t_symbols.join(" ")
      move_print 8,2, "Start symbol: " 
      move_print 8,col, grammar.start_symbol.to_s
      move_print 10,2, "Production rules:" 
      move_print 11,cols*2/3-2, "Probability"
      i = 12
      grammar.rules.each do |rule|
        output = ""
        output = "(" << rule[:id].to_s << ")" << tab <<
               rule[:symbol].to_s << " " << def_symbol << " " <<
               rule[:body].join(" ") << " " 
        move_print i,6, output 
        move_print i,cols*2/3 ,rule[:probability].to_s << "\n"
        move_print i,6,output
        i += 1
      end
      ret = wait "<Press 's' to select. Press any other key to see the next>"
      refresh
    close_screen
    ret
  end

  def wait(message="<Press any key to continue>")
     move_print lines-1,cols-message.size,message
     getch
  end

  def find_grammar(name)
    @grammars.each do |g|
      return g if g.name == name
    end
    nil
  end

  def move_print(x=nil,y=nil,str)
    x ||= lines
    y ||= cols
    setpos(x,y)
    addstr(str)
  end

  def complexity_to_s
    self.class.constants.each do |c|
      val = self.class.const_get(c)
      if val == @complexity 
        return c.to_s.capitalize
      end
    end
  end
end
