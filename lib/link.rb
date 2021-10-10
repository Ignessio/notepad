class Link < Post
  def initialize
    super

    @url = ""
  end

  def read_from_colsole
    puts "Адрес ссылки:"
    @url = STDIN.gets.chomp

    puts "Введите описание:"
    @text = STDIN.gets.chomp
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\r \n\r"

    [time_string, @url, @text]
  end
end
