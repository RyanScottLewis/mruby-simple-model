class MyModel < SimpleModel; end

database_1 = SQLite3::Database.new(':memory:')
database_2 = SQLite3::Database.new(':memory:')

assert("SimpleModel.database return the model's associated database") do
  MyModel.database.nil?
end

assert("SimpleModel.database( value ) should set the model's associated database") do
  MyModel.database(database_1)
  
  assert_equal( MyModel.database, database_1 )
end

assert("SimpleModel.database( value ) should raise error if anything other than a SQLite3::Database or MySQL::Database is passed") do
  assert_raise(TypeError) { MyModel.database('foobar') }
end

assert("SimpleModel.database=( value ) should set the model's associated database") do
  MyModel.database = database_2
  
  assert_equal( MyModel.database, database_2 )
end

assert("SimpleModel.database=( value ) should raise error if anything other than a SQLite3::Database or MySQL::Database is passed") do
  assert_raise(TypeError) { MyModel.database = 'foobar' }
end

assert("SimpleModel.table_name return the model's associated table name") do
  assert_nil( MyModel.table_name )
end

assert("SimpleModel.table_name( value ) should set the model's associated table name") do
  MyModel.table_name('some_table_name')
  
  assert_equal( MyModel.table_name, 'some_table_name' )
end

assert("SimpleModel.table_name=( value ) should set the model's associated table name") do
  MyModel.table_name = 'another_table_name'
  
  assert_equal( MyModel.table_name, 'another_table_name' )
end

assert("SimpleModel.primary_key return :id by default") do
  assert_equal( MyModel.primary_key, :id )
end

assert("SimpleModel.primary_key( value ) should set the model's associated table name") do
  MyModel.primary_key(:identifier)
  
  assert_equal( MyModel.primary_key, :identifier )
end

assert("SimpleModel.primary_key=( value ) should set the model's associated table name") do
  MyModel.primary_key = :some_id
  
  assert_equal( MyModel.primary_key, :some_id )
end

assert("SimpleModel.attributes should return a list of attributes defined on the model") do
  assert_equal( MyModel.attributes, [:some_id] )
end

assert("SimpleModel.attribute( name ) should define an attribute") do
  MyModel.attribute(:username)
  MyModel.attribute(:password)
  
  assert_equal( MyModel.attributes, [:some_id, :username, :password] )
end

assert("SimpleModel.attribute( name ) should not define an attribute if it already exists") do
  MyModel.attribute(:username) # Second definition
  
  assert_equal( MyModel.attributes, [:some_id, :username, :password] )
end

assert("SimpleModel.attribute( name ) should define getter/setter methods") do
  instance = MyModel.new
  
  assert_equal( instance.username, nil )
  assert_equal( instance.password, nil )
  
  instance.username = 'foo'
  instance.password = 'bar'
  
  assert_equal( instance.username, 'foo' )
  assert_equal( instance.password, 'bar' )
end

assert("SimpleModel#new? should only return true when dealing with a new record (not saved, not loaded from the database)") do
  instance = MyModel.new
  
  assert_true( instance.new? )
end

assert("SimpleModel#changed? should return true when attributes have been changed") do
  instance = MyModel.new
  
  assert_false( instance.changed? )
  instance.username = 'foobar'
  
  assert_true( instance.changed? )
end

assert("SimpleModel#changed_attributes should return an Array of attribute names in the order they were changed") do
  instance = MyModel.new
  
  instance.password = 'foo'
  assert_equal( instance.changed_attributes, [:password] )
  
  instance.username = 'bar'
  assert_equal( instance.changed_attributes, [:password, :username] )
  
  instance.password = 'something'
  assert_equal( instance.changed_attributes, [:username, :password] )
end
