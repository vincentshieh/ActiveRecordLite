require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || (name + "_id").to_sym
    @class_name = options[:class_name] || name.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || (self_class_name.downcase + "_id").to_sym
    @class_name = options[:class_name] || name.singularize.capitalize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name.to_s, options)
    define_method(name) do
      foreign_key_name = options.send(:foreign_key)
      foreign_key = self.send(foreign_key_name)
      target_model_class = options.send(:model_class)
      target_model_class.where({ id: foreign_key }).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name.to_s, self.name, options)
    define_method(name) do
      foreign_key_name = options.send(:foreign_key)
      primary_key = self.send(:id)
      target_model_class = options.send(:model_class)
      target_model_class.where({ foreign_key_name => primary_key })
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Searchable
  extend Associatable
end
