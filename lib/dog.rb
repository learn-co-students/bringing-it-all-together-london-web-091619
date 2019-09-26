class Dog
    attr_accessor :name, :breed, :id
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "
        CREATE TABLE IF NOT EXISTS dogs
        (id INTEGER PRIMARY KEY,name TEXT, breed TEXT)
        "
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "
        DROP TABLE dogs
        "
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql =  "
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
            "
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        new_dog =self.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        Dog.new(name: name, breed: breed,id: id)
    end

    def self.find_by_id(id)
        sql = "
        SELECT * 
        FROM dogs
        WHERE id = ?
        "
        dog_from_db = DB[:conn].execute(sql, id)[0]
        self.new_from_db(dog_from_db)
    end

    def self.find_or_create_by(name:,breed:)
        sql = "
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
        "
        dog = DB[:conn].execute(sql, name,breed)
        if !dog.empty?
            new_dog = dog[0]
            dog = new_from_db(new_dog)
        else
            dog = create(name:name, breed:breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "
        SELECT *
        FROM dogs
        WHERE name = ?
        "
        dog = DB[:conn].execute(sql, name)[0]
        new_from_db(dog)
    end

    def update
        sql = "
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        "
        dog = DB[:conn].execute(sql, name, breed, id)
    end
end