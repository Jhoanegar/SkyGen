class String
  def cut(n=1)
    self[0..(-1-n)]
  end
end
