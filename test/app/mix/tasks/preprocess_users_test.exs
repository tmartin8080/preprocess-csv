defmodule Mix.Tasks.App.PreprocessUsersTest do
  use ExUnit.Case

  alias Mix.Tasks.App.PreprocessUsers, as: Task

  @data_file "test/fixtures/users.csv"

  describe "run/1" do
    test "invalid args raise error" do
      assert_raise RuntimeError, ~r/Invalid args/, fn ->
        Task.run(@data_file)
      end
    end

    test "returns {:ok, output}" do
      assert :ok == Task.run([@data_file, "email"])
    end
  end
end
