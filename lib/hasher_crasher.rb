module HasherCrasher
  module Ohm

    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::Validations
      extend ActiveModel::Naming
      extend ActiveModel::Callbacks

      define_model_callbacks :create, :update, :destroy

      define_attribute_methods [:name, :data]

      attr_reader :errors
      attr_accessor :name, :data
    end

    module ClassMethods
      def namespace
        model_name.singular
      end

      def redis
        $redis
      end

      def find(name)
        data = redis.get(key_for(name))
        data ? new(:data => data, :name => name) : nil
      end

      def key_for(key)
        [namespace, key].join(':')
      end
    end

    module InstanceMethods
      def initialize(options={})
        @errors = ActiveModel::Errors.new(self)

        options.each_pair do |k,v|
          if respond_to? k
            instance_variable_set :"@#{k}", v
          end
        end
      end

      def to_model
        self
      end

      def persisted?
        false
      end

      def save
        return false unless valid?
        _redis.get(name) ? update : create
      end

      private

      def create
        _run_create_callbacks do
          _redis.set(_key_for(name), data)
        end
      end

      def update
        _run_update_callbacks do
          _redis.set(name, data)
        end

      end

      def _redis
        self.class.redis
      end

      def _key_for(name)
        self.class.key_for(name)
      end

    end
  end
end
