# TODO: Should complain about missing libraries instead of this crap
module SQLite3; class Database; end; end
module MySQL; class Database; end; end

class SimpleModel
  
  class << self
    
    def database(value=nil)
      self.database = value unless value.nil?
      
      @database ||= nil
    end
    
    def database=(value)
      raise TypeError, 'database must be a SQLite3::Database or MySQL::Database' unless value.is_a?(SQLite3::Database) || value.is_a?(MySQL::Database)
      
      @database = value
    end
    
    def table_name(value=nil)
      self.table_name = value unless value.nil?
      
      @table_name
    end
    
    def table_name=(value)
      @table_name = value.to_s
    end
    
    # TODO: Can be set to nil? Can tables /not/ have PKs?
    def primary_key(value=nil)
      self.primary_key = value unless value.nil?
      
      @primary_key ||= :id
    end
    
    # TODO: Can be set to nil? Can tables /not/ have PKs?
    def primary_key=(value)
      raise TypeError, 'primary_key must respond to #to_sym' unless value.respond_to?(:to_sym)
      value = value.to_sym
      
      if !@primary_key.nil? && method_defined?(@primary_key)
        undef_method(@primary_key.to_sym)
        undef_method("#{@primary_key}=".to_sym)
      end
      
      # TODO: Following code is exactly the same as the attribute method but doesnt add the primary key to the @attributes list
      attr_reader(value)
      define_method("#{value}=") do |value|
        @changed = true # TODO: Unless value == current_value
        
        changed_attributes.delete(value)
        changed_attributes << value
        
        instance_variable_set( "@#{value}", value )
      end
      
      @primary_key = value
    end
    
    def attributes
      @attributes ||= []
      
      [primary_key] + @attributes
    end
    
    def attribute(*names)
      names.each do |name|
        raise TypeError, 'name must respond to #to_sym' unless name.respond_to?(:to_sym)
        name = name.to_sym
        
        @attributes ||= []
        
        unless @attributes.include?(name)
          @attributes << name
          
          attr_reader(name)
          define_method("#{name}=") do |value|
            @changed = true # TODO: Unless value == current_value
            
            changed_attributes.delete(name)
            changed_attributes << name # TODO: unless changed_attributes.include?(name) # why not
            
            instance_variable_set( "@#{name}", value )
          end
        end
      end
      
      self
    end
    
    def count
      query = "SELECT count(*) AS count FROM #{table_name} LIMIT 1"
      
      result_set = database.execute( query )
      
      result_set.next[0]
    end
    
    def all
      query = "SELECT * FROM #{table_name}"
      
      result_set = database.execute( query )
      
      convert_result_set_to_instances(result_set)
    end
    
    def first(amount=1)
      raise TypeError, 'amount must respond to #to_i' unless amount.respond_to?(:to_i)
      amount = amount.to_i
      
      query = "SELECT * FROM #{table_name} LIMIT ?"
      
      result_set = database.execute( query, amount )
      
      convert_result_set_to_instances(result_set)[0]
    end
    
    def last(amount=1)
      raise TypeError, 'amount must respond to #to_i' unless amount.respond_to?(:to_i)
      amount = amount.to_i
      
      query = "SELECT * FROM #{table_name} ORDER BY #{primary_key} DESC LIMIT ?"
      
      result_set = database.execute( query, amount )
      
      convert_result_set_to_instances(result_set)[0]
    end
    
    def create(attributes={})
      raise TypeError, 'attributes must respond to #to_hash or #to_h' unless attributes.respond_to?(:to_hash) || attributes.respond_to?(:to_h)
      attributes = attributes.to_hash rescue attributes.to_h
      
      query_interpolates = []
      attributes.length.times { query_interpolates << ?? }
      query_interpolates = query_interpolates.join(', ')
      query_keys = attributes.keys.join(', ')
      
      query = "INSERT INTO #{table_name}(#{query_keys}) values(#{query_interpolates})"
      
      result_set = database.execute( query, *attributes.values )
      
      convert_result_set_to_instances(result_set)[0]
    end
    
    protected
    
    def convert_result_set_to_instances(result_set)
      result_collection = []
      
      loop do
        columns = result_set.next
        break if result_set.eof?
        
        result_collection << columns
      end
      
      
      result_collection.collect do |values|
        instance = new
        result_set.fields.each_with_index { |name, index| instance.send( "#{name}=", values[index] ) }
        instance.instance_eval { @new, @changed = false, false } # Dirty! But works
        
        instance
      end
    end
    
  end # << self
  
  attribute :id
  
  def initialize
    @new, @changed = true, false
  end
  
  def new?
    @new
  end
  
  def changed?
    @changed
  end
  
  def changed_attributes
    @changed_attributes ||= []
  end
  
  # Returns the value of this instance's primary key
  # TODO: Should use instance_variable_get
  def primary_key
    send( self.class.primary_key )
  end
  
  def database
    self.class.database # TODO: Should set @database as self.class.database by default but settable within instance
  end
  
  def table_name
    self.class.table_name # TODO: Should set @table_name as self.class.table_name by default but settable within instance
  end
  
  def delete
    self.class.database.execute_batch( "DELETE FROM #{table_name} WHERE #{self.class.primary_key} = ?", primary_key )
  end
  
  # TODO: This needs to remove any attributes given from the changed_attributes array
  def update(attributes)
    raise TypeError, 'attributes must respond to #to_hash or #to_h' unless attributes.respond_to?(:to_hash) || attributes.respond_to?(:to_h)
    attributes = attributes.to_hash rescue attributes.to_h
    
    # TODO: Raise error if Hash is empty =(
    # TODO: Set attributes on this instance to new attributes, clear changed_attributes
    
    query = "UPDATE #{table_name} SET "
    query << attributes.keys.collect { |name| "#{name} = ?" }.join(' AND ')
    query << " WHERE #{self.class.primary_key} = ?"
    
    query_values = attributes.values
    query_values << primary_key
    
    self.class.database.execute_batch( query, *query_values )
    
    self
  end
  
  def save
    new? ? self.class.create(to_hash) : update(to_hash)
  end
  
  def save_changed
    update(changed_attributes)
  end
  
  # TODO: Should use instance_variable_get
  def to_hash
    self.class.attributes.inject({}) { |memo, name| memo[name] = send(name); memo }
  end
  
  def each
    to_hash.each
  end
  
end # SimpleModel
