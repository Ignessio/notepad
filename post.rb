class Post
  def initialize
    @created_at = Time.now
    @text = nil
  end

  def read_from_colsole
  end

  def to_string
  end

  def save
    file_name = @created_at.strftime("#{self.class_name}-%Y-%m-%d_%H:%M:%S")
    file = File.new("#{__dir__}/data/#{file_name}.txt", "w:UTF-8")
    for item in to_string do
      file.puts(item)
    end

    file.close

  # def save
  #   file = File.new(file_path, 'w:UTF-8')
  #   to_strings.each { |string| file.puts(string) }
  #   file.close
  # end

  # def file_path
  #   current_path = File.dirname(__FILE__)
  #   file_time = @created_at.strftime('%Y-%m-%d_%H-%M-%S')
  #   file_path = "#{current_path}/#{self.class.name}_#{file_time}.txt"
  # end
end
