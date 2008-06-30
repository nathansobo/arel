require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Tuple do
    describe "class methods" do
      describe ".member_of" do
        attr_reader :relation, :tuple_class
        before do
          @relation = Arel(:users)
          relation.attribute(:id)
          relation.attribute(:name)
          @tuple_class = Class.new do
            include Tuple
          end
        end

        it "associates the class with a #relation and the relation with a #tuple_class" do
          tuple_class.member_of(relation)
          tuple_class.relation.should == relation
          relation.tuple_class.should == tuple_class
        end

        it "defines an attr_accessor for each attribute in the relation" do
          tuple_class.member_of(relation)
          tuple_class.method_defined?(:id=).should be_true
          tuple_class.method_defined?(:name=).should be_true
        end

        it "causes a new attr_accessor to be defined for attributes added to the relation subsequently"
      end

      describe ".create" do
        it "instantiates an instance and inserts it in the relation" do
          users_relation.read.should be_empty
          user = user_tuple_class.create(:id => 1, :name => "Maria")
          users_relation.read.should == [user]
        end
      end
    end

    describe "instance methods" do
      describe "#initialize" do
        it "calls the assignment method for each attribute defined on the tuple's relation" do
          attributes = {:id => 1, :name => "Bob", :bogus => "bogus"}
          tuple = user_tuple_class.new(attributes)
          tuple.should_not be_nil
          tuple.id.should == 1
          tuple.name.should == "Bob"
        end

        it "binds the given attributes hash in the relation before assigning them" # Is this needed?
      end

      describe "#value" do
        attr_reader :tuple
        before do
          @tuple = user_tuple_class.new(:id => 1, :name => "Alice")
        end

        it "maps an attribute in the tuple's relation to its value in the tuple" do
          tuple.value(users_relation[:id]).should == tuple.id
        end

        it "maps a non-attribute to itself" do
          tuple.value(1).should == 1
        end
      end
    end
  end
end
