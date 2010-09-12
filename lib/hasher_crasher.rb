module HasherCrasher
  module Ohm

    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
      include ActiveModel::Conversion
      include ActiveModel::Validations
      extend ActiveModel::Naming
      extend ActiveModel::Callbacks

      define_model_callbacks :create, :update, :destroy, :save

      define_attribute_methods [:name, :data]

      attr_reader :errors
      attr_accessor :name, :data
      attr_writer :persisted
    end

    module ClassMethods
      def namespace
        model_name.singular
      end

      def redis
        $redis
      end

      def create(options)
        ohm = new(options)
        ohm.tap do |o|
          ohm.save
        end
      end

      def find(name)
        data = redis.get(key_for(name))
        if data 
          new(:data => data, :name => name).tap do |o|
            o.persisted = true
          end
        else
          nil
        end
      end

      def all
        keys = $redis.keys([namespace, "*"].join(':'))
        keys.map do |key|
          data = redis.get(key)
          name = key.gsub(/#{namespace}:/, '')
          if data 
            new(:data => data, :name => name).tap do |o|
              o.persisted = true
            end
          else
            nil
          end
        end.reject{|o| o.nil?}
      end

      def key_for(key)
        [namespace, key].join(':')
      end
    end

    module InstanceMethods
      def initialize(options={})
        @errors = ActiveModel::Errors.new(self)

        if file = options.delete(:data_file)
          self.send(:data_file=, file)
        end

        options.each_pair do |k,v|
          if respond_to? k
            instance_variable_set :"@#{k}", v
          end
        end
      end

      def id
        persisted? ? name : nil
      end

      def data_file=(file)
        self.data = file.read
      end

      def data_file
      end

      def to_model
        self
      end

      def persisted?
        @persisted || false
      end

      def save
        return false unless valid?
        _redis.get(name) ? update : create
      end


      def create
        _run_create_callbacks do
          _redis.set(_key_for(name), data)
          @persisted = true
        end
      end

      def update
        _run_update_callbacks do
          _redis.set(name, data)
          @persisted = true
        end

      end

      private

      def _redis
        self.class.redis
      end

      def _key_for(name)
        self.class.key_for(name)
      end

    end
  end
end
