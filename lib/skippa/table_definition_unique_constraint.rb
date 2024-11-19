module Skippa
  class TableDefinitionUniqueConstraint
    # https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQL/TableDefinition.html#method-i-unique_constraint

    class << self
      def parse(sexp, table_name)
        new(sexp, table_name)
      end
    end

    attr_reader :sexp

    def initialize(sexp, table_name)
      @sexp = sexp
      @table_name = table_name
    end

    def inspect
      "#<#{self.class.inspect}:#{self.object_id.inspect} table_name=#{self.table_name.inspect}, column_names=#{self.column_names.inspect}, options=#{self.options.inspect}>"
    end

    def pretty_print(q)
      q.group(2, "#<#{self.class.inspect}:#{self.object_id.inspect}") do
        q.breakable
        q.text "table_name="
        q.pp self.table_name
        q.text(",")

        q.breakable
        q.text "column_names="
        q.pp self.column_names
        q.text ","

        q.breakable
        q.text "options="
        q.pp self.options
        q.text ","
      end
      q.breakable
      q.text(">")
    end

    def table_name
      @table_name
    end

    def column_names
      sexp
        .dig(4, 1, 0, 1)
        .map { |array| array.dig(1, 1, 1) }
    end

    def options
      key_value_array = Array(sexp.dig(4, 1, 1, 1)).flat_map do |assoc_new|
        key = assoc_new.dig(1, 1).chop # chop `:`
        value = case v = assoc_new.dig(2, 1)
                when [:string_content]
                  # empty string
                  ""
                when Array
                  # symbol or string
                  case v2 = v.dig(1)
                  when Array
                    v2.dig(1)
                  else
                    v2
                  end
                else
                  v
                end
        [key, value]
      end
      Hash[*key_value_array]
    end
  end
end
