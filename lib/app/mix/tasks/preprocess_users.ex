defmodule Mix.Tasks.App.PreprocessUsers do
  @moduledoc """
  Deduplicate rows from given CSV file using different strategies:

  - `email`
  - `phone`
  - `email_or_phone`

  Docs for CSV package:
  https://hexdocs.pm/csv/CSV.html#decode/2

  `:validate_row_length` can be adjusted to ignore row length.
  If there's a mismatch, this row is currently being ignored and
  Logged to the console.

  Usage:
    mix app.preprocess_users data.csv email
  """

  use Mix.Task
  require Logger

  @valid_strategies ["email", "phone", "email_or_phone"]
  defguard is_valid_strategy(strategy) when is_binary(strategy) and strategy in @valid_strategies

  @impl Mix.Task
  @shortdoc "Deduplicate rows from given CSV file"
  def run([path, strategy]) when is_valid_strategy(strategy) do
    preprocessor = preprocessor()
    Logger.info("Preprocessing #{path} using #{preprocessor}")

    preprocessor.stream_file(path)
    |> CSV.decode(headers: true, strip_fields: true)
    |> Stream.map(&preprocessor.preprocess_row_fun/1)
    |> Stream.filter(&preprocessor.filter_errors_fun/1)
    |> preprocessor.dedup_by(strategy)
    |> preprocessor.write_to_csv(path)
  end

  @impl Mix.Task
  def run(_) do
    raise("Invalid args. \nUsage: mix app.dedupe data.csv (email | phone | email_or_phone)")
  end

  def preprocessor do
    Application.get_env(:app, :user_import_preprocessor)
  end
end
