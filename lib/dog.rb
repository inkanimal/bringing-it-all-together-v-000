class Dog 
  
  attr_accessor :name, :breed 
  attr_reader :id
  
  def initialize(id =nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
    
  end
  
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed INTEGER
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
   def self.drop_table
    sql =  <<-SQL 
        DROP TABLE  dogs  
      
        SQL
    DB[:conn].execute(sql) 
  end
  
  def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end 
end
  
  def self.create(name:, breed:)
    dog = Dog.new(name, breed)
    dog.save
    dog
  end
  
   def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  def self.new_from_db(row)
    new_dog = Dog.new(row[0], row[1], row[2])
    new_dog
   # new_student = self.new(row)
   # new_student.id = row[0]
   # new_student.name =  row[1]
   # new_student.grade = row[2]
   # new_student  # return the newly created instance
end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL
 
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(result[0], result[1], result[2])
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
end 