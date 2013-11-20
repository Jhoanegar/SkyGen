class String
  def cut(n=1)
    self[0..(-1-n)]
  end
end

class Array
  def add(new_item)
    self << new_item unless self.include? new_item
  end
end
