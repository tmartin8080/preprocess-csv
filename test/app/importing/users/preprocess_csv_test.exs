defmodule App.Importing.Users.PreprocessCSVTest do
  @moduledoc """
  Convenience functions for processing files.
  """
  use ExUnit.Case
  @moduletag capture_log: true
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

    test "raises error when arg is non binary" do
      assert_raise RuntimeError, ~r/File path must be a string./, fn ->
        Processor.stream_file(123)
      end
    end
  end

  describe "preprocess_row_fun/2" do
    test "trims keys and values" do
      row_data = %{" SpaceKey" => " spacevalue "}

      assert Processor.preprocess_row_fun({:ok, row_data}) == %{
               "SpaceKey" => "spacevalue"
             }
    end

    test "handles decode errors" do
      row_data = {:error, "Row has length 5 - expected length 4 on line 8"}

      assert Processor.preprocess_row_fun(row_data) ==
               {:error, "Row has length 5 - expected length 4 on line 8"}
    end
  end

  describe "filter_errors_fun/1" do
    test "true when map" do
      assert Processor.filter_errors_fun(%{}) == true
    end

    test "false when tuple" do
      assert Processor.filter_errors_fun({:error, "error"}) == false
    end
  end

  describe "dudup_by/2" do
    test "dedup by email" do
      data = duplicate_data(:email)
      assert Processor.dedup_by(data, "email") == [%{"Email" => "test@test.com"}]
    end

    test "dedup case-insensitive by email keeps first row found" do
      data = [%{"Email" => "TEST@test.com"} | duplicate_data(:email)]
      assert Processor.dedup_by(data, "email") == [%{"Email" => "TEST@test.com"}]
    end

    test "dedup by phone" do
      data = duplicate_data(:phone)
      assert Processor.dedup_by(data, "phone") == [%{"Phone" => "111-111-1111"}]
    end

    test "dedup by email_or_phone" do
      data = duplicate_data(:email_or_phone)

      assert Processor.dedup_by(data, "email_or_phone") == [
               %{"Phone" => "111-111-1111", "Email" => "second@test.com"},
               %{"Email" => "other@test.com", "Phone" => "222-111-1111"}
             ]
    end
  end

  defp duplicate_data(:email) do
    [%{"Email" => "test@test.com"}, %{"Email" => "test@test.com"}]
  end

  defp duplicate_data(:phone) do
    [%{"Phone" => "111-111-1111"}, %{"Phone" => "111-111-1111"}]
  end

  defp duplicate_data(:email_or_phone) do
    [
      %{"Email" => "first@test.com", "Phone" => "111-111-1111"},
      %{"Email" => "second@test.com", "Phone" => "111-111-1111"},
      %{"Email" => "other@test.com", "Phone" => "222-111-1111"},
      %{"Email" => "other@test.com", "Phone" => "222-3333-1111"}
    ]
  end
end
