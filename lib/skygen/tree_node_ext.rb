class Tree::TreeNode
  alias_method :preordered_each , :each
  def add(child, at_index = -1)
  raise ArgumentError, "Attempting to add a nil node" unless child
  raise ArgumentError, "Attempting no add node to itself" if self == child
  if insertion_range.include?(at_index)
    @children.insert(at_index,child)
  else
    raise "Position not available"
  end

  @children_hash[child.name] = child
  child.parent = self
  end
  
  def not_terminal_node?
    self.name.is_a? Symbol
  end

  def terminal_node?
    self.name.is_a? String
  end

  def each(condition=nil,&block)
    condition ||= Proc.new {true}
    children { |child| child.each(condition, &block) }
    yield self if condition.call(self)
  end

end
