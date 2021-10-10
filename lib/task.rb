require "date"

class Task < Post
  def initialize
    super

    @due_date = Time.now
  end

  def read_from_colsole
    puts "Что надо сделать?"
    @text = STDIN.gets.chomp

    puts "К камому числу? В формате ДД.ММ.ГГГГ, например 11.12.2021."
    input = STDIN.gets.chomp

    @due_date = Date.parse(input)
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime("%Y.%m.%d, %H:%M:%S")}\n\r \n\r"

    deadline = "Крайний срок: #{@due_date}."

    [time_string, deadline, @text]
  end
  end
end
