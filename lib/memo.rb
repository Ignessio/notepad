class Memo < Post
  def initialize
    super
  end

  def read_from_colsole
    puts "Новая заметка (все, что пишите до строчки \"конец\"):"

    @text = []
    line = nil

    while line != "конец" do
      line = STDIN.gets.chomp
      @text << line
    end

    @text.pop
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\r \n\r"

    @text.unshift(time_string)
  end
end
