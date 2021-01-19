defmodule Mix.Tasks.App.PreprocessUsers do
  @moduledoc """
  Deduplicate rows from given CSV file using different strategies:

  - `email`
  - `phone`
  - `email_or_phone`

  Usage:
    mix app.preprocess_users data.csv email
  """
  @shortdoc "Deduplicate rows from given CSV file"

  use Mix.Task
  alias App.Importing.Users.PreprocessCSV, as: Processor
  require Logger

  @valid_strategies ["email", "phone", "email_or_phone"]
  defguard is_valid_strategy(strategy) when is_binary(strategy) and strategy in @valid_strategies

  @impl Mix.Task
  def run([path, strategy]) when is_valid_strategy(strategy) do
    Processor.stream_file(path)
    |> CSV.decode(headers: true)
    |> Stream.map(&Processor.preprocess_fun/1)
    |> Stream.filter(&Processor.filter_errors_fun/1)
    |> Stream.dedup_by(&Processor.dedup_fun(&1, strategy))
    |> Processor.write_to_csv(path)
    |> Stream.run()

    Logger.info("Finished processing #{path}.")
    :ok
  end

  @impl Mix.Task
  def run(_) do
    raise("Invalid args. \nUsage: mix app.dedupe data.csv (email | phone | email_or_phone)")
  end
end
