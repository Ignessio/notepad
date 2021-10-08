class Task < Post
  def initialize
    super
    @due_date = Time.now
  end
  def read_from_colsole
  end

  def to_string
  end
end
