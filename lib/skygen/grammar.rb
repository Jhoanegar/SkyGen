class Grammar

  attr_accessor :name, :rules

  def initialize(name,rules)
    @name = name
    @rules = set_rules(rules)
    set_probabilites!
    @nt_symbols = get_not_terminal_symbols
    @t_symbols = get_terminal_symbols
    @start_symbol = @rules[0][:symbol]
  end

  def set_rules(arr_rules)
    new_rules = []
    arr_rules.each do |rule|
      temp_rule = Hash.new(0)
      temp_rule[:id] = new_rules.size + 1
      temp_rule[:symbol] = rule.shift
      temp_rule[:probability]= rule.pop if rule.last.is_a? Float
      temp_rule[:body] = rule 
      new_rules << temp_rule
    end
    new_rules
  end

  def set_probabilites! 
    number_of_rules = @rules.size
    number_of_rules_without_probability = count_simple_rules 
    probability_left = 1 - count_acc_probability
    if probability_left < 0 
      puts "In #{@name}: The sum of probabilities can't exceed 1."
      abort
    elsif probability_left <= 0 and 
          number_of_rules_without_probability != 0
      puts "In #{@name}: No probability left to assign."
      abort
    end
    assign_probabilites(
        probability_left*1.0 / number_of_rules_without_probability)
  end

  def count_simple_rules
    @rules.select{|r| r[:probability] == 0}.size
  end

  def count_acc_probability
    @rules.inject(0) {|total,r| total + r[:probability]}
  end

  def assign_probabilites(p)
    @rules.map! do |rule|
      if rule[:probability] == 0
        rule[:probability] = p
      end
      rule
    end
  end

  def get_not_terminal_symbols
    nts = []
    @rules.each do |rule|
      nts.add rule[:symbol]
    end
    nts
  end
 
  def get_terminal_symbols
    ts = []
    @rules.each do |rule|
      rule[:body].each do |sym|
        ts.add sym if sym.is_a? String
      end
    end
    ts
  end
end
