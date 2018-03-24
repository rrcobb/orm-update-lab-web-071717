require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    DB[:conn].execute('CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, grade TEXT)')
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS students')
  end

  def save
    if id.nil?
      DB[:conn].execute('INSERT INTO students(name, grade) VALUES (?, ?)', @name, @grade)
      @id = DB[:conn].last_insert_row_id
      self
    else
      DB[:conn].execute('UPDATE students SET name = ?, grade = ? WHERE id = ?', @name, @grade, @id)
      self
    end
  end
  alias_method :update, :save

  def self.create(name, grade)
    self.new(name, grade).save
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute('SELECT * FROM students WHERE name = ? LIMIT 1', name).first
    self.new_from_db(row) if row
  end

end
