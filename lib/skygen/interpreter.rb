require 'curses'
require 'tree'
class Interpreter
  include Curses
  include Tree
  #Complexities
  EASY = 1
  NORMAL = 2
  COMPLEX = 3
  AUTO = 4
  #Characters
  LEFT = /^l$/
  RIGHT = /^r$/
  UP = /^u$/
  DOWN = /^d$/
  EMPTY = /^e$/
  NORTH_EAST = /^(:?ne|ru|ur)$/
  SOUTH_EAST = /^(:?se|rd|dr)$/
  
  @@characters = { 
    :l => "_",
    :u => "|",
    :r => "_",
    :d => "|",
    :ne => "/",
      :ru => "/",
      :ur => "/",
    :se => "\\",
      :dr => "\\",
      :rd => "\\"
  }
  def initialize(grammars,options)
    @grammars = grammars
    @grammar = get_grammar(options.grammar)
    @complexity = options.complexity || get_complexity
    @probabilites = nil
    @skyline_rules = []
  end

  def run 
    display_setup
    loop do 
      sky = generate_skyline
      sky_str = sky_to_str(sky)
      print_skyline(sky_str)
    end
  end

  def sky_to_str(sky)
    str = ""
    sky.each_leaf {|leaf| str << "#{leaf.name} "}
    str
  end


  def create_tree(rule)
    tree_root = TreeNode.new(rule.symbol,rule.id)
    rule.body.each {|element| tree_root << TreeNode.new(element,rule.id)}
    return tree_root
  end

  def generate_skyline
    @skyline_rules = []
    @probabilites = get_probabilites 
    nt_leafs_only = Proc.new {|n| n.name.is_a? Symbol and n.is_leaf?}
    index = pick_random_index {|i| i < @grammar.start_rules.size}
    root_node = create_tree(@grammar.rules[index])
    @skyline_rules << @grammar.rules[index].id
    #choose next 
    (@complexity*10).times do 
      root_node.each(nt_leafs_only) do |node|
        next if node == root_node
        index = pick_random_index {|i| node.name == 
                                 @grammar.rules[i].symbol}
        node << create_tree(@grammar.rules[index])
        @skyline_rules << @grammar.rules[index].id
      end
    end
    #Close open leafs
    root_node.each(nt_leafs_only) do |node|
      next if node == root_node
      index = Random.rand(0..@grammar.terminal_rules.size-1)
      node << create_tree(@grammar.terminal_rules[index])
      @skyline_rules << @grammar.terminal_rules[index].id
    end
    root_node
  end
  
  def pick_random_index(&block)
    block ||= Proc.new {true}
    passed = false
    index = 0
        # binding.pry
    loop do 
      random = Random.rand
      index = 0
      loop do
        if random <= @probabilites[index] 
          passed = true if block.call(index)
          break
        end
        index += 1
        break if index == @probabilites.size - 1
      end
      break if passed
    end
    index - 1
  end
  
  def display_setup
    init_screen
      stdscr.keypad(true)
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
      stdscr.keypad(true)
      clear
      move_print 2,5, "No grammar selected, #{@grammars.size} available."
      refresh
      wait
    close_screen 
    loop do
      @grammars.each do |g|
        if print_grammar(g.name) == 's'
          return g
        end
      end
    end
    return nil
  end

  def get_complexity
    init_screen
      stdscr.keypad(true)
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
      stdscr.keypad(true)
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

  def get_probabilites
    acc = 0
    ret = [0]
    @grammar.rules.each do |rule| 
      ret << (rule[:probability] + acc)
      acc += rule[:probability]
    end
    ret
  end

  def print_skyline(str)
    last_char = nil
    tree = str.split
    init_screen
      stdscr.keypad(true)
        setpos 2,0 ; addstr "String: " + str
        setpos 3+(str.size / cols),0 ; addstr "Rules: " + @skyline_rules.join(" ")
        row = lines - 2
        col = 0
      tree.each do |char|
        case char
        when RIGHT
          if last_char
            if last_char =~ UP or last_char =~ NORTH_EAST
              row -= 1 ; col += 1
            elsif last_char =~ DOWN or last_char =~ SOUTH_EAST
              col += 1
            elsif last_char =~ RIGHT
              col += 1
            else
              raise "#{char} after #{last_char} is not supported"
            end
          end
          # setpos row,col; addstr "_"
        when UP
          if last_char
            if last_char =~ UP
              row -= 1
            elsif last_char =~ DOWN
              #nothing
            elsif last_char =~ RIGHT
              col += 1
            elsif last_char =~ NORTH_EAST
              col += 1 ; row -= 1
            elsif last_char =~ SOUTH_EAST
              col += 1
            else
              raise "#{char} after #{last_char} is not supported"
            end
          end
          # setpos row,col; addstr "|"
        when DOWN
          if last_char
            if last_char =~ UP
              #nothing
            elsif last_char =~ DOWN
              row += 1
            elsif last_char =~ RIGHT or last_char =~ SOUTH_EAST
              col += 1 ; row += 1
            elsif last_char =~ NORTH_EAST
              col += 1
            else
              raise "#{char} after #{last_char} is not supported"
            end
          end
          # setpos row,col; addstr "|"
        when NORTH_EAST
          if last_char
            if last_char =~ UP
              row -= 1
            elsif last_char =~ DOWN
              row += 1
            elsif last_char =~ RIGHT or last_char =~ SOUTH_EAST
              col += 1 
            elsif last_char =~ NORTH_EAST
              col += 1 ; row -= 1
            else
              raise "#{char} after #{last_char} is not supported"
            end
          end

         when SOUTH_EAST
          if last_char
            if last_char =~ UP or last_char =~ NORTH_EAST
              col += 1
            elsif last_char =~ DOWN or RIGHT
              row += 1 ; col += 1
            else
              raise "#{char} after #{last_char} is not supported"
            end
          end

          when EMPTY
            #nothing
          else 
            raise "#{char} not supported"
          end
        # puts char
        setpos row,col ; addstr @@characters[char.to_sym] unless char =~ EMPTY
        last_char = char unless char =~ EMPTY
      end
      wait "Press UP/DOWN to increase/decrease the complexity, 's' to save, 'e' to exit."
    close_screen
  end
end
