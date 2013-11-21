require 'curses'
require 'pry'
class Interpreter
  include Curses
  def initialize(grammars,options)
    # binding.pry
    @grammars = grammars
    if options.grammar or grammars.size == 1
      @grammar = options.grammar
    else
      @grammar = get_grammar
    end
    @complexity = options.complexity || get_complexity
  end

  def get_grammar
    init_screen
      clear
      move_print 2,5, "No grammar selected, select one of the following #{@grammars.size}."
      refresh
      wait
    close_screen 
    repeat = false 
    loop do
      @grammars.each do |g|
        if print_grammar(g.name).downcase == 's'
          return g
        end
      end
    end
  end

  def get_complexity
    init_screen
      input = 0
      loop do
        move_print 2,5, "Enter a complexity value:"
        move_print 3,2, "1) Easy."
        move_print 4,2, "2) Normal."
        move_print 5,2, "3) Complex."
        move_print 6,2, "4) It won't fit in the screen!"
        move_print 7,2, "5) Random."
        refresh
        input = wait("<Enter the selected complexity (1-5)>").to_i
        break if (1..5).include? input
      end
    close_screen
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
end
