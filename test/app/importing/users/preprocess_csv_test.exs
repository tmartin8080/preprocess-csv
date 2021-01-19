defmodule App.Importing.Users.PreprocessCSVTest do
  @moduledoc """
  Convenience functions for processing files.
  """
  use ExUnit.Case
  alias App.Importing.Users.PreprocessCSV, as: Processor

  @data_file "test/fixtures/users.csv"

  describe "stream_file/1" do
    test "can stream existing file" do
      assert %File.Stream{line_or_bytes: :line, path: @data_file} =
               Processor.stream_file(@data_file)
    end

    test "raises error when file does not exist" do
      assert_raise RuntimeError, ~r/not found/, fn ->
        Processor.stream_file("notfound.csv")
      end
    end
  end
end
