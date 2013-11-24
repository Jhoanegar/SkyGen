class ParseNode < Tree::TreeNode
  def initialize(rule)
    raise ArgumentError unless rule.respond_to? :body
    super rule[:symbol],rule[:body]
  end

  def each_nt_node
    self.each do |node|
      yield node unless node.not_terminal_node? 
    end
  end

  def not_terminal_node?
    not terminal_node?
  end

  def terminal_node?
    found_nt_symbol = false
    self.content.each {|element| found_nt_symbol = true if element.is_a? Symbol}
    return found_nt_symbol
  end
end
