require 'curses'

class Interpreter
  include Curses
  def initialize(grammars)
    @grammars = grammars
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
     message = "<Press any key to continue>"
     move_print lines-1,cols-message.size,message
     refresh
     getch
  end

  def find_grammar(name)
    @grammars.each do |g|
      return g if g.name == name
    end
    nil
  end

  def move_print(x,y,str)
    setpos(x,y)
    addstr(str)
  end
end
