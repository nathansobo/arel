require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Tuple do
    attr_reader :relation, :tuple_class
    before do
      @relation = Arel(:users)
      relation.attribute(:id)
      relation.attribute(:name)
      @tuple_class = Class.new do
        include Tuple
      end
    end

    describe "class methods" do
      describe ".member_of" do
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
    end

    describe "instance methods" do
      before do
        tuple_class.member_of(relation)
      end

      describe "#initialize" do
        it "calls the assignment method for each attribute defined on the tuple's relation" do
          attributes = {:id => 1, :name => "Bob", :bogus => "bogus"}
          tuple = tuple_class.new(attributes)
          tuple.should_not be_nil
          tuple.id.should == 1
          tuple.name.should == "Bob"
        end

        it "binds the given attributes hash in the relation before assigning them" # Is this needed?
      end
    end
  end
end
