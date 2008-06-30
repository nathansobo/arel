module Arel
  class Table < Relation
    include Recursion::BaseCase

    cattr_accessor :engine
    attr_reader :name, :engine, :members_by_id
    hash_on :name
    
    def initialize(name, engine = Table.engine)
      @name, @engine, @members_by_id = name.to_s, engine, {}
    end

    def attribute(name)
      @attributes ||= []
      @attributes.push(Attribute.new(self, name.to_sym))
    end

    def attributes
      @attributes ||= columns.collect do |column|
        Attribute.new(self, column.name.to_sym)
      end
    end

    def column_for(attribute)
      has_attribute?(attribute) and columns.detect { |c| c.name == attribute.name.to_s }
    end
    
    def columns
      @columns ||= engine.columns(name, "#{name} Columns")
    end
    
    def reset
      @attributes = @columns = nil
    end
    
    def ==(other)
      Table      === other and
      name       ==  other.name
    end

    def read
      members_by_id.values.sort_by {|tuple| tuple.id}
    end

    def insert(tuple)
      members_by_id[tuple.id] = tuple
    end
  end
end