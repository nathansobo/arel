require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')

module Arel
  describe Where do
    attr_reader :relation, :predicate

    before do
      @users_relation = users_relation
      @predicate = users_relation[:id].eq(1)
    end
  
    describe '#initialize' do
      it "manufactures nested where relations if multiple predicates are provided" do
        another_predicate = users_relation[:name].lt(2)
        Where.new(users_relation, predicate, another_predicate). \
          should == Where.new(Where.new(users_relation, another_predicate), predicate)
      end
    end

    describe "#read" do
      context "restricting a table relation" do
        attr_reader :where

        before do
          @where = Where.new(users_relation, predicate)
        end

        it "returns all the tuple objects of the restricted relation which meet the criteria" do
          farb = user_tuple_class.new(:id => 1, :name => "Farb")
          kate = user_tuple_class.new(:id => 2, :name => "Kate")
          emily = user_tuple_class.new(:id => 3, :name => "Emily")
          users_relation.insert(farb)
          users_relation.insert(kate)
          users_relation.insert(emily)

          where.read.should == [farb]
        end
      end
    end
    
    describe '#to_sql' do
      describe 'when given a predicate' do
        it "manufactures sql with where clause conditions" do
          Where.new(users_relation, predicate).to_sql.should be_like("
            SELECT `users`.`id`, `users`.`name`
            FROM `users`
            WHERE `users`.`id` = 1
          ")
        end
      end
      
      describe 'when given a string' do
        it "passes the string through to the where clause" do
          Where.new(users_relation, 'asdf').to_sql.should be_like("
            SELECT `users`.`id`, `users`.`name`
            FROM `users`
            WHERE asdf
          ")
        end
      end
    end
  end
end