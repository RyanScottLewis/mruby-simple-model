DATABASE = SQLite3::Database.new( File.join('test', 'test.db') )

begin
  DATABASE.execute_batch('DROP TABLE users')
rescue RuntimeError # No table =(
end

DATABASE.execute_batch('CREATE TABLE users(id integer primary key, username varchar(255), password varchar(255), bio text)')

class User < SimpleModel
  
  database DATABASE
  table_name 'users'
  
  attribute :username, :password, :bio
  
end

user = User.new
user.username = 'foo'
user.password = 'bar'
user.bio = 'Wooooow! Lots of bio stuff here!'
user.save

User.create( username: 'omgomg', password: 'lolol', bio: 'Wooooah biobiobiobio' )

assert('First user') do
  user = User.first
  
  assert_equal( user.username, 'foo' )
  assert_equal( user.password, 'bar' )
  assert_equal( user.bio, 'Wooooow! Lots of bio stuff here!' )
  assert_false( user.new? )
  assert_false( user.changed? )
end

assert('Last user') do
  user = User.last
  
  assert_equal( user.username, 'omgomg' )
  assert_equal( user.password, 'lolol' )
  assert_equal( user.bio, 'Wooooah biobiobiobio' )
  assert_false( user.new? )
  assert_false( user.changed? )
end

assert('Count') do
  assert_equal( User.count, 2 )
end

assert('All') do
  users = User.all
  user_first, user_last = users.first, users.last
  
  assert_equal( user_first.username, 'foo' )
  assert_equal( user_first.password, 'bar' )
  assert_equal( user_first.bio, 'Wooooow! Lots of bio stuff here!' )
  assert_false( user_first.new? )
  assert_false( user_first.changed? )
  
  assert_equal( user_last.username, 'omgomg' )
  assert_equal( user_last.password, 'lolol' )
  assert_equal( user_last.bio, 'Wooooah biobiobiobio' )
  assert_false( user_last.new? )
  assert_false( user_last.changed? )
  
  user_first.username = 'NO WAI'
  assert_true( user_first.changed? )
  assert_false( user_last.changed? )
  
  user_last.username = 'YA WAI'
  assert_true( user_first.changed? )
  assert_true( user_last.changed? )
end
