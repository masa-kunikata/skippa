require "test_helper"
require "ripper"

class TableDefinitionIndexTest < Minitest::Test
  def setup
    @user_id_index = user_id_index()
  end

  def test_column_names
    assert_equal ["user_id"], @user_id_index.column_names
  end

  def test_options
    assert_equal({ "name" => "index_tbl_on_user_id" }, @user_id_index.options)
  end

  def test_table_name
    assert_equal "tbl", @user_id_index.table_name
  end

  private
  def user_id_index
    doc = <<'__EOD__'
t.index ["user_id"], name: "index_tbl_on_user_id"
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::TableDefinitionIndex.parse(sexp, "tbl")
  end
end
