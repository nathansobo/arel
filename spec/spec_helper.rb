dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require 'rubygems'
require 'spec'
require 'pp'
require 'fileutils'
require 'arel'

[:matchers, :doubles].each do |helper|
  Dir["#{dir}/#{helper}/*"].each { |m| require "#{dir}/#{helper}/#{File.basename(m)}" }
end

Spec::Runner.configure do |config|  
  config.include(BeLikeMatcher, HashTheSameAsMatcher, DisambiguateAttributesMatcher)
  config.mock_with :rr
  config.before do
    Arel::Table.engine = Arel::Engine.new(Fake::Engine.new)
    @users_relation = users_relation = Arel::Table.new(:users)
    users_relation.attribute(:id)
    users_relation.attribute(:name)
    @user_tuple_class = Class.new do
      include Arel::Tuple
      member_of users_relation
    end
  end
end

class Spec::ExampleGroup
  attr_reader :users_relation, :user_tuple_class
end