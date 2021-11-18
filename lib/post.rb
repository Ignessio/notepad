# encoding: utf-8

# Подключаем гем для общения с базой данных sqlite3
require 'sqlite3'

# Базовый класс «Запись» — здесь мы определим основные методы и свойства,
# общие для всех типов записей.
class Post
  # Используем константу для хранения названия базы данных
SQLITE_DB_FILE = 'anotepad.db'.freeze

  # Теперь нам нужно будет читать объекты из базы данных поэтому удобнее всегда
  # иметь под рукой связь между классом и его именем в виде строки
  def self.post_types
    {'Memo' => Memo, 'Task' => Task, 'Link' => Link}
  end

  # Параметром для метода create теперь является строковое имя нужного класса
  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now
    @text = []
  end

  # Метод класса find_by_id находит в базе запись по идентификатору
  def self.find_by_id(id)
    # Библиотека "optparse" обработает ошибки, если искомый id был передан пользователем некорректно
    # (OptionParser::MissingArgument,  OptionParser::InvalidOption)
    # Добавим еще одну проверку, и если id не передали, мы ничего не ищем, а возвращаем nil
    return if id.nil?

    # Если id передали, едем дальше
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true

    # Начинаем аккуратно тянуть данные из базы методом execute
    begin
      result = db.execute('SELECT * FROM posts WHERE  rowid = ?', id)
    rescue SQLite3::SQLException => error
      # Если возникла ошибка, пишем об этом пользователю и выводим текст ошибки
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort error.message
    end

    db.close

    # Если в результате запроса получили пустой массив, снова возвращаем nil
    return nil if result.empty?

    # Если результат не пуст, едем дальше
    result = result[0]

    # Создаем пост нужного типа, заполняем его данными и возвращаем
    post = create(result['type'])
    post.load_data(result)
    post
  end

  # Метод класса find_all возвращает массив записей из базы данных, который
  # можно например показать в виде таблицы на экране.
  def self.find_all(limit, type)
    db = SQLite3::Database.open(SQLITE_DB_FILE)

    db.results_as_hash = false

    query = 'SELECT * FROM posts '
    query += 'WHERE type = :type ' unless type.nil?
    query += 'ORDER by rowid DESC '
    query += 'LIMIT :limit ' unless limit.nil?

    # Перед подготовкой запроса поставим конструкцию begin, чтобы поймать
    # возможные ошибки например, если в базе нет таблицы posts.
    begin
      statement = db.prepare query
    rescue SQLite3::SQLException => e
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort e.message
    end

    statement.bind_param('type', type) unless type.nil?
    statement.bind_param('limit', limit) unless limit.nil?

    # Перед запросом поставим конструкцию begin, чтобы поймать возможные ошибки
    # например, если в базе нет таблицы posts.
    begin
      result = statement.execute!
    rescue SQLite3::SQLException => error
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort error.message
    end

    statement.close
    db.close

    result
  end

  def read_from_console
    # Этот метод должен быть реализован у каждого ребенка
  end

  def to_strings
    # Этот метод должен быть реализован у каждого ребенка
  end

  # Метод load_data заполняет переменные экземпляра из полученного хэша
  def load_data(data_hash)
    # Общее для всех детей класса Post поведение описано в методе экземпляра
    # класса Post.
    @created_at = Time.parse(data_hash['created_at'])
    @text = data_hash['text']
    # Остальные специфичные переменные должны заполнить дочерние классы в своих
    # версиях класса load_data (вызвав текущий метод с пом. super)
  end

  # Метод to_db_hash должен вернуть хэш типа {'имя_столбца' -> 'значение'} для
  # сохранения новой записи в базу данных
  def to_db_hash
    # Дочерние классы сами знают свое представление, но общие для всех детей
    # переменные экземпляра можно заполнить уже сейчас в родительском классе.
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
    # self — ключевое слово, указывает на «этот объект», то есть конкретный
    # экземпляр класса, где выполняется в данный момент этот код.
    #
    # Дочерние классы должны дополнять этот хэш массив своими полями
  end

  # Метод save_to_db, сохраняющий состояние объекта в базу данных.
  def save_to_db
    # Открываем «соединение» с базой данных SQLite и говорим, что хотим получать
    # результат в виде хэшей руби.
    db = SQLite3::Database.open(SQLITE_DB_FILE)
    db.results_as_hash = true

    # Выполняем Запрос к базе на вставку новой записи в соответствии с хэшем,
    # сформированным методом to_db_hash. Обратите внимание, что не смотря на то,
    # что каждый ребенок реализует этот метод по-своему, код save_to_db будет
    # одинаковым для всех.
    post_hash = to_db_hash

    # Перед запросом поставим конструкцию begin, чтобы поймать возможные ошибки
    # например, если в базе нет таблицы posts.
    begin
      db.execute(
        'INSERT INTO posts (' +
        post_hash.keys.join(', ') +
        ") VALUES (#{('?,' * post_hash.size).chomp(',')})",
        post_hash.values
      )
    rescue SQLite3::SQLException => error
      puts "Не удалось выполнить запрос в базе #{SQLITE_DB_FILE}"
      abort error.message
    end

    # Сохраняем в переменную id записи, которую мы только что добавили в таблицу
    insert_row_id = db.last_insert_row_id

    # Закрываем соединение
    db.close

    # Возвращаем идентификатор записи в базе
    insert_row_id
  end

  def save
    file = File.new(file_path, 'w:UTF-8')

    to_strings.each { |string| file.puts(string) }

    file.close
  end

  def file_path
    current_path = File.dirname(__FILE__)

    file_time = @created_at.strftime('%Y-%m-%d_%H-%M-%S')

    "#{current_path}/#{self.class.name}_#{file_time}.txt"
  end
end
