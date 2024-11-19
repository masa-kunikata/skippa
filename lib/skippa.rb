require "skippa/version"
require "skippa/schema"
require "skippa/extention"
require "skippa/table"
require "skippa/column"
require "skippa/index"
require "skippa/table_definition_index"
require "skippa/table_definition_unique_constraint"

require "ripper"

module Skippa
  class << self
    def parse(doc)
      sexp = Ripper.sexp(doc).dig(1, 0)
      Skippa::Schema.parse(sexp)
    end
  end
end
