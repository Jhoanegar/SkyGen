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
    @output_file = options.save_file
    @skyline = nil
    @skyline_chars = []
  end

  def run 
    display_setup
    input = ""
    loop do 
      @skyline = generate_skyline
      sky_str = sky_to_str(@skyline)
      input = print_skyline(sky_str)
      case input 
      when KEY_UP
        increase_complexity
      when KEY_DOWN
        decrease_complexity
      when 's'
        save_data
      when 'e'
        break
      when 'r'
        break
      end
    end
    input
  end

  def save_data
    File.open(@output_file,"a") do |file|  
      file.puts "Skyline generated #{Time.now.strftime '%H:%M:%S'}"
      file.puts "Grammar used:"
      file.puts "  #{@grammar.name}"
      file.puts "Rules:"
      @grammar.rules.each do |rule|
        file.puts "(#{rule.id}) #{rule.symbol} => #{rule.body.join(' ')}"
      end 
      file.puts "Rules applied: "
      @skyline_rules.each_with_index do |rule,i|
        if i != @skyline_rules.size-1
          file.print "#{rule}->"
        else
          file.print "#{rule}"
        end
        if i % 25 == 0 and i > 0 then file.print "\n" end
      end
      file.puts
      file.puts "Generated string:"
      len = 0
      @skyline_chars.each do |char|
        len += char.size + 1
        if len > 75 
          file.print "\n"
          len = 0
        end
        file.print "#{char} "
      end
      file.puts
      file.puts "Expression Tree:"
      file.puts @skyline.print_tree
      file.puts
      file.print "=" * 80
      file.puts
   end
   init_screen
     msg = "Data saved succesfully!"
     move_print lines/2,((cols/2)- msg.size),msg
     wait
   close_screen

  end

  def decrease_complexity
    unless @complexity == 1    
      @complexity -= 1 
    else
      init_screen
        addstr "Minimum complexity achieved!"
        wait
      close_screen
    end
  end

 def increase_complexity
    unless @complexity == 9    
      @complexity += 1 
    else
      init_screen
        addstr "Maximum complexity achieved!"
        wait
      close_screen
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
    (@complexity*5).times do 
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
      move_print 9,6, "#{@complexity}"
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
        move_print 2,5, "Enter a complexity value."
        move_print 4,2, <<-DOC
  The complexity of a skyline depends on the number of terminal rules as well 
  as the probability associated with each one. It is very hard to produce a 
  tree with a given depth since you can't really predict the outcome of the 
  selected rules (because we are using probabilistic weights to select the 
  rules) and the algorithm must close all the not terminal nodes adding as 
  many extra nodes as needed. Hence, the number you enter here, will have 
  an unpredicted impact in the complexity of the skyline, however, IT WILL 
  influence its complexity. 

  Finally, don't worry, you will be able to change this number later.
  
  "1,2,3,4,5,6,7,8,9 are supported complexities where '1' is simple and '9' is complex."
DOC
        refresh
        input = wait("<Enter the complexity value>").to_i
        break if (1..9).include? input
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
    @skyline_chars = []
    last_char = nil
    tree = str.split
    init_screen
      stdscr.keypad(true)
        comp = "<\\Complexity: #{@complexity}>"
        setpos 0,cols-comp.size ; addstr comp
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
        @skyline_chars << char
      end
      r = wait "<UP/DOWN adjusts the complexity,'s' saves, 'e' exits,'r' resets>"
    close_screen
    return r
  end
end
