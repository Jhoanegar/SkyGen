class Grammar

  attr_accessor :name, :rules

  def initialize(name,rules)
    @name = name
    @rules = set_rules(rules)
    set_probabilites!
  end

  def set_rules(arr_rules)
    new_rules = []
    arr_rules.each do |rule|
      temp_rule = Hash.new(0)
      temp_rule[:name] = rule.shift
      temp_rule[:probability]= rule.pop if rule.last.is_a? Float
      temp_rule[:body] = rule 
      new_rules << temp_rule
    end
    new_rules
  end

  def set_probabilites! 
    binding.pry
    number_of_rules = @rules.size
    number_of_rules_without_probability = count_simple_rules 
    probability_left = 1 - count_acc_probability
    if probability_left < 0
      raise ArgumentError, "The sum of probabilities can't exceed 1"
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
end
