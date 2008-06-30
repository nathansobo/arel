module Arel
  module Tuple
    class << self
      def included(a_module)
        a_module.extend(ClassMethods)
      end
    end

    module ClassMethods
      attr_reader :relation

      def member_of(relation)
        @relation = relation
        relation.tuple_class = self
        relation.attributes.each do |attribute|
          attr_accessor attribute.name
        end
      end

      def create(attributes)
        relation.insert(new(attributes))
      end
    end

    attr_reader :attributes

    def relation
      self.class.relation
    end

    def initialize(attributes={})
      attributes.each do |name, value|
        assignment_method = "#{name}="
        send(assignment_method, value) if respond_to?(assignment_method)
      end
    end

    def value(attribute)
      case attribute
      when Attribute
        send(attribute.name)
      when Value
        attribute.value
      else
        attribute
      end
    end
  end
end