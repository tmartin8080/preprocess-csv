defmodule App do
  @moduledoc """
  Documentation for `App`.
  """
  alias App.Importing.Users.PreprocessCSV, as: Processor

  @data [
    %{"Name" => "First", "Email" => "aaa", "Phone" => "111"},
    %{"Name" => "Second", "Email" => "bbb", "Phone" => "222"},
    %{"Name" => "Third", "Email" => "aaa", "Phone" => "333"},
    %{"Name" => "Fourth", "Email" => "ddd", "Phone" => "444"}
  ]

  def bench_dedup_by do
    data =
      Enum.reduce(1..10000, [], fn i, acc ->
        acc ++ @data
      end)

    Benchee.run(
      %{
        "orig" => fn -> Processor.dedup_by(data, "email") end,
        "uniq_by" => fn -> Processor.dedup_by(data, "email_unique") end
      },
      time: 10,
      memory_time: 2
    )

    :ok
  end
end
