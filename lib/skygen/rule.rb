class Rule
  attr_accessor :id, :symbol, :probability, :body
  def initialize(config_hash)
    @id, @symbol, @probability, @body = config_hash.map{|_,v| v}
  end

  def [](symbol)
    att = "@#{symbol}"
    self.method_missing(symbol.to_s) unless self.instance_variable_defined?(att)
    self.instance_variable_get(att)
  end

  def each_body_nt_symbol
    @body.each {|symbol| yield symbol if symbol.is_a Symbol}
  end
end
