require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Table do
    attr_reader :relation, :tuple_class

    before do
      @relation = Table.new(:users)
      relation.attribute(:id)
      relation.attribute(:name)
      users = relation

      @tuple_class = Class.new do
        include Tuple
        member_of users
      end
    end

    describe "#insert" do
      it "adds the given object to the table's cache" do
        tuple = tuple_class.new(:id => 1, :name => "Alicia")
        relation.read.should be_empty
        relation.insert(tuple)
        relation.read.should == [tuple]
      end
    end

    describe "#read" do
      it "returns an array of all tuple instances in the relation, sorted by id" do
        tuples = [
          tuple_class.new(:id => 1, :name => "Maria"),
          tuple_class.new(:id => 2, :name => "Nick"),
          tuple_class.new(:id => 3, :name => "Barbara")
        ]

        tuples.each do |tuple|
          relation.insert(tuple)
        end

        relation.read.should == tuples
      end
    end

    describe '[]' do
      describe 'when given a', Symbol do
        it "manufactures an attribute if the symbol names an attribute within the relation" do
          relation[:id].should == Attribute.new(relation, :id)
          relation[:does_not_exist].should be_nil
        end
      end

      describe 'when given an', Attribute do
        it "returns the attribute if the attribute is within the relation" do
          relation[relation[:id]].should == relation[:id]
        end
        
        it "returns nil if the attribtue is not within the relation" do
          another_relation = Table.new(:photos)
          relation[another_relation[:id]].should be_nil
        end
      end
      
      describe 'when given an', Expression do
        before do
          @expression = relation[:id].count
        end
        
        it "returns the Expression if the Expression is within the relation" do
          relation[@expression].should be_nil
        end
      end
    end
    
    describe '#to_sql' do
      it "manufactures a simple select query" do
        relation.to_sql.should be_like("
          SELECT `users`.`id`, `users`.`name`
          FROM `users`
        ")
      end
    end
    
    describe '#column_for' do
      it "returns the column corresponding to the attribute" do
        relation.column_for(relation[:id]).should == relation.columns.detect { |c| c.name == 'id' }
      end
    end

    describe "#attribute" do
      it "adds an attribute by the given name to the table" do
        relation.reset
        relation.attribute(:id)
        relation.attribute('name')
        relation.attributes.should == [
          Attribute.new(relation, :id),
          Attribute.new(relation, :name)
        ]
      end
    end

    describe '#attributes' do
      before do
        relation.reset
      end

      it 'manufactures attributes corresponding to columns in the table' do
        relation.attributes.should == [
          Attribute.new(relation, :id),
          Attribute.new(relation, :name)
        ]
      end
      
      describe '#reset' do
        it "reloads columns from the database" do
          lambda { stub(relation.engine).columns { [] } }.should_not change { relation.attributes }
          lambda { relation.reset }.should change { relation.attributes }
        end
      end
    end
  
    describe 'hashing' do
      it "implements hash equality" do
        Table.new(:users).should hash_the_same_as(Table.new(:users))
        Table.new(:users).should_not hash_the_same_as(Table.new(:photos))
      end
    end
    
    describe '#engine' do
      it "defaults to global engine" do
        Table.engine = engine = Engine.new
        Table.new(:users).engine.should == engine
      end
      
      it "can be specified" do
        Table.new(:users, engine = Engine.new).engine.should == engine
      end
    end
  end
end