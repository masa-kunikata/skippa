require "test_helper"
require "ripper"

class TableDefinitionUniqueConstraintTest < Minitest::Test
  def setup
    @id1_id2_id3_unique_constraint = id1_id2_id3_unique_constraint()
  end

  def test_column_names
    assert_equal ["id1", "id2", "id3"], @id1_id2_id3_unique_constraint.column_names
  end

  def test_options
    assert_equal({ "name" => "tbl_id1_id2_id3" }, @id1_id2_id3_unique_constraint.options)
  end

  def test_table_name
    assert_equal "tbl", @id1_id2_id3_unique_constraint.table_name
  end

  private
  def id1_id2_id3_unique_constraint
    doc = <<'__EOD__'
t.unique_constraint ["id1", "id2", "id3"], name: "tbl_id1_id2_id3"
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::TableDefinitionUniqueConstraint.parse(sexp, "tbl")
  end
end
