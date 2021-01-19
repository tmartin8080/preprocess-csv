defmodule Mix.Tasks.App.PreprocessUsersTest do
  @moduledoc """
  Using FakeProcessor to return results because
  the mix task runs the stream as a side effect.

  Configured in config.exs
  """
  use ExUnit.Case
  @moduletag capture_log: true
  import ExUnit.CaptureLog

  alias Mix.Tasks.App.PreprocessUsers, as: MixTask

  @data_file "test/fixtures/users.csv"
  @email_column_index 2
  @phone_column_index 3

  describe "run/1" do
    test "invalid args raise error" do
      assert_raise RuntimeError, ~r/Invalid args/, fn ->
        MixTask.run(@data_file)
      end
    end

    test "logs an error for row with extra column" do
      fun = fn ->
        run_task("email")
      end

      assert capture_log(fun) =~ "Row has length 5 - expected length 4 on line 8"
    end

    test "dedups by email" do
      results = run_task("email")
      emails_in_result = field_in_results(results, @email_column_index)

      assert emails_in_result == Enum.uniq(emails_in_result)
    end

    test "dedups by phone" do
      results = run_task("phone")

      phones_in_result = field_in_results(results, @phone_column_index)
      assert phones_in_result == Enum.uniq(phones_in_result)
    end

    test "dedups by email or phone" do
      results = run_task("email_or_phone")

      emails_in_result = field_in_results(results, @email_column_index)
      phones_in_result = field_in_results(results, @phone_column_index)

      assert emails_in_result == Enum.uniq(emails_in_result)
      assert phones_in_result == Enum.uniq(phones_in_result)
    end
  end

  defp run_task(strategy) do
    MixTask.run([@data_file, strategy])
  end

  defp field_in_results(results, column_index) do
    Enum.map(results, fn row -> Enum.at(row, column_index) end)
  end
end
