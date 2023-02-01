defmodule FakeProcessor do
  @moduledoc """
  Used for testing the results of preprocessor,
  as opposed to mocking, this will still allow aync: true
  for tests.

  Delegates other functions to real processor, but handles the
  write_to_csv/2 function to return the data.

  Configure in config/<env>.exs
  """
  alias App.Importing.Users.PreprocessCSV, as: Processor

  defdelegate stream_file(path), to: Processor
  defdelegate preprocess_row_fun(stream_row, strategy), to: Processor
  defdelegate filter_errors_fun(stream_row), to: Processor
  defdelegate dedup_by(stream_data, strategy), to: Processor

  def write_to_csv(rows_stream, _path) do
    rows_stream
    |> CSV.encode(headers: ["FirstName", "LastName", "Email", "Phone"])
    |> CSV.decode()
    |> Enum.to_list()
    |> Enum.map(fn {:ok, row} -> row end)
  end
end
