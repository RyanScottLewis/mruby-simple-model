# MRuby SimpleModel

A small active record pattern for SQLite3 and MySQL, written in pure MRuby.

Note that this is not a full-blown ORM and never will be. It simply encapsulates a single record. You cannot edit the schema, 
there is no SQL AST manager (such as AREL), no special magic names or conventions, no validations, no associations, and no migrations.

This is written in pure Ruby so feel free to modify, subclass, and extend models to your every whim.

Depends on [mattn/mruby-sqlite3](https://github.com/mattn/mruby-sqlite3) or [mattn/mruby-mysql](https://github.com/mattn/mruby-mysql).

## Usage

### Defining a Model

First, initialize a database using `mruby-sqlite3` or `mruby-mysql`:

    DATABASE = SQLite3::Database.new('example/foo.db')
    # DATABASE = MySQL::Database.new('localhost', 'root', '', 'foo')

Now, define your model:

    class User < SimpleModel
      
      # Required (can be set at anytime, as long as this is not nil when a SQL method is called)
      database DATABASE
      
      # Required
      table_name 'users'
      
      # Define the primary key (default is :id, so probably not needed in most cases)
      primary_key :id
      
      # Define the table attributes (columns)
      attribute :username
      attribute :password
      attribute :age
      attribute :bio
      attribute :created_at
      
      # Or define all on one line with a Hash:
      # attribute :username, :password, ...
      
      def self.create(attributes={})
        attributes[:created_at] ||= Time.now # Set :created_at attribute to now if not given
        
        super(attributes)
      end
      
      def password=(value)
        value = Digest::SHA256.hexdigest(value) # Encrypt the password before setting the instance variable (assuming you have the mruby-sha2 gem)
        
        super(value)
      end
      
    end

### Model Class Methods

    # Get/set the database
    User.database(DATABASE)
    User.database = DATABASE
    User.database # => #<SQLite3::Database:0x000>
    
    # Get/set the table name
    User.table_name('users')
    User.table_name = 'users'
    User.table_name # => 'users'
    
    # Get/set the primary key name
    User.primary_key(:id)
    User.primary_key = :id
    User.primary_key # => :id
    
    # Define an attribute on the model (should really only do this in class definition)
    User.attribute( :some_key )
    User.attribute( :another_key, :yet_another_key )
    
    User.attributes # => [ :id, :username, :password, :age, :bio, :created_at ]
    
    User.all        # => [ #<User:0x000>, ...]
    User.first      # => #<User:0x000>
    User.last       # => #<User:0x000>
    User.count      # => 123
    User.find(1)    # => #<User:0x000>
    User[1]         # => #<User:0x000>
    
    User.create( username: 'Ryguy', password: 'love123', age: 23, bio: 'Totally rad dude' ) # => #<User:0x000>
    
    user = User.new( username: 'SomeoneElse', password: 'hooplah' )
    user.bio = 'An equally rad dude'
    user.save

### Model Instance Methods

    user = User[1]
    user.database # => #<SQLite3::Database:0x000> # Set to User.database by default
    user.database = SQLite3::Database.new('example/foo.db')
    
    user = User[1]
    user.table_name # => 'users' # Set to User.table_name by default
    user.table_name = 'people'
    
    user = User[1]
    user.primary_key # => :id # Set to User.primary_key by default
    user.primary_key = :identifier
    
    User.attributes # => [:some_key, :another_key, :yet_another_key]
    
    User[1].update( username: 'Ryan' ) # => #<User:0x000> # UPDATE users SET username = 'Ryan' WHERE (id = 1)
    User[1].delete                     # => #<User:0x000> # DELETE FROM users WHERE (id = 1)
    
    user = User[1]
    user.changed?                        # => false
    user.new?                            # => false
    user.password = 'transmorgification'
    user.changed?                        # => true
    user.changed_attributes              # => [:password]
    user.save                            # => #<User:0x000> # Creates or updates the record
    user.save_changes                    # => #<User:0x000> # Creates or updates the record, setting only the changed attributes
    
    user.each { |name, value| } # Iterate through the attributes
    user.to_hash # => { username: 'Ryan', password: 'nfdg8743hg4bw3..', age: 23, bio: 'Totally rad dude', created_at: #<Time:0x000> }
    
    another_user = User.new
    another_user.new? # => true

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* YARD

## Copyright

Copyright © 2014 Ryan Scott Lewis <ryanscottlewis@lewis-software.com>.

The MIT License (MIT) - See [LICENSE](LICENSE) for further details.
