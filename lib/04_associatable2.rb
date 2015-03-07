require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_table_name = through_options.model_class.table_name
      source_table_name = source_options.model_class.table_name

      source_obj = DBConnection.execute(<<-SQL, send(through_options.foreign_key))
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name} ON #{through_table_name}.#{source_options.foreign_key} =
                                  #{source_table_name}.#{source_options.primary_key}
        WHERE
          #{through_table_name}.#{through_options.primary_key} = ?
      SQL
      source_options.model_class.new(source_obj.first)
    end
  end
end
