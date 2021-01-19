defmodule Mix.Tasks.App.PreprocessUsersTest do
  @moduledoc """
  Using FakeProcessor to return results because
  the mix task runs the stream as a side effect.

  Configured in config.exs
  """
  use ExUnit.Case

  alias Mix.Tasks.App.PreprocessUsers, as: MixTask

  @data_file "test/fixtures/users.csv"

  describe "run/1" do
    test "invalid args raise error" do
      assert_raise RuntimeError, ~r/Invalid args/, fn ->
        MixTask.run(@data_file)
      end
    end

    test "dedups by email" do
      result = MixTask.run([@data_file, "email"])

      assert result == [
               ["FirstName", "LastName", "Email", "Phone"],
               ["Tom", "Jones", "tom@jones.com", "111-111-1111"],
               ["Tim", "Jones", "tim@jones.com", "333-333-3333"],
               ["Sheila", "Jones", "sheila@jones.com", "444-444-4444"],
               ["T", "Jones", "t.jones@jones.com", "111-111-1111"],
               ["DiffPhone", "Jones", "diff.phone@jones.com", "111.111.1111"]
             ]
    end

    test "dedups by phone" do
      result = MixTask.run([@data_file, "phone"])

      assert result == [
               ["FirstName", "LastName", "Email", "Phone"],
               ["Tom", "Jones", "tom@jones.com", "111-111-1111"],
               ["Tim", "Jones", "tim@jones.com", "333-333-3333"],
               ["Sheila", "Jones", "sheila@jones.com", "444-444-4444"],
               ["T", "Jones", "t.jones@jones.com", "111-111-1111"],
               ["DiffPhone", "Jones", "diff.phone@jones.com", "111.111.1111"]
             ]
    end
  end
end
