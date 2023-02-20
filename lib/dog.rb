

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    ## CREATE TABLE ROWS
    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
    
        # insert the dog
        DB[:conn].execute(sql, self.name, self.breed)
    
        # get the dog ID from the database and save it to the Ruby instance
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
        # return the Ruby instance
        self
      end

    ## INSTANTIATES NEW DOG and SAVE IT TO  MAKE IT PERSIST
    def self.create(name:, breed:)
        ## instantiates
        dog = Dog.new(name: name, breed: breed)
        ## save
        dog.save
    end


    #### CONVERTING DB RECORDS TO RUBY OBJECTS
    def self.new_from_db(row)
        ## fetches each row data from the table
            self.new(id:row[0], name:row[1],breed:row[2])
    end

    def self.all
        ## returns all the data from the database
        sql=<<-SQL
            SELECT *
            FROM dogs
        SQL

        ## returns an array of rows fro the database and iterates through it to create a new ruby object
        DB[:conn].execute(sql).map{|row| self.new_from_db(row)}
    end

    def self.find_by_name(name)
        sql=<<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql,name).map{|row| self.new_from_db(row)}.first
    end

    def self.find(id)
        sql=<<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql,id).map{|row| self.new_from_db(row)}.first
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
end


