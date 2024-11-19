require "test_helper"
require "ripper"

class TableTest < Minitest::Test
  def setup
    @access_log_table = access_log_table()
    @users_table = users_table()
    @composite_pkey_table = composite_pkey_table()
    @indexes_table = indexes_table()
    @unique_constraints_table = unique_constraints_table()
  end

  def test_name
    assert_equal "access_log", @access_log_table.name
    assert_equal "users", @users_table.name
    assert_equal "composite_pkey", @composite_pkey_table.name
    assert_equal "indexes_table", @indexes_table.name
    assert_equal "unique_constraints_table", @unique_constraints_table.name
  end

  def test_options
    assert_equal({ "id" => "false", "force" => "cascade" }, @access_log_table.options)
    assert_equal({ "force" => "cascade" }, @users_table.options)
    assert_equal({ "id" => "false", "force" => "cascade", "primary_key" => ["pkey1", "pkey2"] }, @composite_pkey_table.options)
    assert_equal({ "force" => "cascade" }, @indexes_table.options)
    assert_equal({ "force" => "cascade" }, @unique_constraints_table.options)
  end

  def test_columns
    assert_equal ["user_id", "timestamp"], @access_log_table.columns.map(&:name)
    assert_equal ["email", "password"], @users_table.columns.map(&:name)
    assert_equal ["pkey1", "pkey2", "timestamp"], @composite_pkey_table.columns.map(&:name)
    assert_equal ["col1", "col2", "col3"], @indexes_table.columns.map(&:name)
    assert_equal ["col1", "col2", "col3"], @unique_constraints_table.columns.map(&:name)
  end

  def test_indexes
    assert_equal [], @access_log_table.indexes
    assert_equal [], @users_table.indexes
    assert_equal [], @composite_pkey_table.indexes
    assert_equal [], @unique_constraints_table.indexes

    assert_equal [
      ["col1"],
      ["col2"],
      ["col2", "col3"],
    ], @indexes_table.indexes.map(&:column_names)
    assert_equal [
      "index_indexes_table_on_col1",
      "index_indexes_table_on_col2",
      "index_indexes_table_on_col2_col3",
    ], @indexes_table.indexes.map{ |index| index.options["name"] }
  end

  def test_unique_constraints
    assert_equal [], @access_log_table.unique_constraints
    assert_equal [], @users_table.unique_constraints
    assert_equal [], @composite_pkey_table.unique_constraints
    assert_equal [], @indexes_table.unique_constraints

    assert_equal [
      ["col1"],
      ["col2", "col3"],
    ], @unique_constraints_table.unique_constraints.map(&:column_names)
    assert_equal [
      "unique_constraints_table_col1_key",
      "unique_constraints_table_col2_col3_key",
    ], @unique_constraints_table.unique_constraints.map{ |index| index.options["name"] }
  end

  private
  def access_log_table
    doc = <<'__EOD__'
create_table "access_log", id: false, force: :cascade do |t|
  t.integer "user_id"
  t.datetime "timestamp", limit: 8
end
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::Table.parse(sexp)
  end

  def users_table
    doc = <<'__EOD__'
create_table "users", force: :cascade do |t|
  t.string "email", limit: 255, default: "", null: false
  t.string "password", limit: 255, default: "", null: false
end
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::Table.parse(sexp)
  end
  
  def composite_pkey_table
    doc = <<'__EOD__'
create_table "composite_pkey", id: false, force: :cascade, primary_key: [:pkey1, :pkey2] do |t|
  t.string "pkey1"
  t.integer "pkey2"
  t.datetime "timestamp", limit: 8
end
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::Table.parse(sexp)
  end

  def indexes_table
    doc = <<'__EOD__'
create_table "indexes_table", force: :cascade do |t|
  t.string "col1"
  t.integer "col2"
  t.integer "col3"
  t.index ["col1"], name: "index_indexes_table_on_col1"
  t.index ["col2"], name: "index_indexes_table_on_col2"
  t.index ["col2", "col3"], name: "index_indexes_table_on_col2_col3"
end
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::Table.parse(sexp)
  end

  def unique_constraints_table
    doc = <<'__EOD__'
create_table "unique_constraints_table", force: :cascade do |t|
  t.string "col1"
  t.integer "col2"
  t.integer "col3"
  t.unique_constraint ["col1"], name: "unique_constraints_table_col1_key"
  t.unique_constraint ["col2", "col3"], name: "unique_constraints_table_col2_col3_key"
end
__EOD__
    sexp = Ripper.sexp(doc).dig(1, 0)
    Skippa::Table.parse(sexp)
  end
end
