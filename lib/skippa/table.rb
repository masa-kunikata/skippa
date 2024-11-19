module Skippa
  class Table
    # http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table

    class << self
      def parse(sexp)
        new(sexp)
      end
    end

    attr_reader :sexp

    def initialize(sexp)
      @sexp = sexp
    end

    def inspect
      "#<#{self.class.inspect}:#{self.object_id.inspect} name=#{self.name.inspect}, comment=#{self.comment.inspect}, options=#{self.options.inspect}, columns=#{self.columns.inspect}>"
    end

    def pretty_print(q)
      q.group(2, "#<#{self.class.inspect}:#{self.object_id.inspect}") do
        q.breakable
        q.text "name="
        q.pp self.name
        q.text ","

        q.breakable
        q.text "comment="
        q.pp self.comment
        q.text ","

        q.breakable
        q.text "options="
        q.pp self.options
        q.text ","

        q.breakable
        q.group(2, "columns=[") do
          self.columns.each do |column|
            q.breakable
            q.pp column
            q.text ","
          end
        end
        q.breakable
        q.text "],"
      end
      q.breakable
      q.text ">"
    end

    def name
      sexp
        .dig(1, 2, 1, 0, 1, 1, 1)
    end

    def comment
      # TODO
    end

    def options
      key_value_array = sexp.dig(1, 2, 1, 1, 1).flat_map do |assoc_new|
        key = assoc_new.dig(1, 1).chop # chop `:`
        value = case v = assoc_new.dig(2, 1)
                when Array
                  case v[0]
                  when :@kw # bool
                    v.dig(1)
                  when :symbol #symbol
                    v.dig(1, 1)
                  when Array # array of string/symbol
                    v.map{|s| s.dig(1, 1, 1)}
                  end
                else
                  v
                end
        [key, value]
      end
      Hash[*key_value_array]
    end

    class << self
      def command_call_type(command_call)
        case command_call.dig(3, 1)
        when "index" then :index
        when "unique_constraint" then :unique_constraint
        else :column
        end
      end
    end

    def columns
      sexp
        .dig(2, 2, 1)
        .select { |command_call| Skippa::Table.command_call_type(command_call) == :column }
        .map { |command_call| Skippa::Column.parse(command_call) }
    end

    def indexes
      sexp
        .dig(2, 2, 1)
        .select { |command_call| Skippa::Table.command_call_type(command_call) == :index }
        .map { |command_call| Skippa::TableDefinitionIndex.parse(command_call, self.name) }
    end

    def unique_constraints
      sexp
        .dig(2, 2, 1)
        .select { |command_call| Skippa::Table.command_call_type(command_call) == :unique_constraint }
        .map { |command_call| Skippa::TableDefinitionUniqueConstraint.parse(command_call, self.name) }
    end
  end
end
