defmodule App.Importing.Users.PreprocessCSV do
  @moduledoc """
  Convenience functions for processing files.
  """
  @path_type_message "File path must be a string."
  @default_root_dir "priv/preprocessed"
  @default_filename "processed"
  @default_file_modes [:write, :utf8]
  @strategy_to_field_map %{
    "email" => "Email",
    "phone" => "Phone"
  }

  require Logger

  def process(stream) do
    raise "are we here yet?"
    IO.inspect(stream)
    stream
  end

  def stream_file(path) when is_binary(path) do
    case File.exists?(path) do
      true -> File.stream!(path)
      false -> raise "#{path} was not found."
    end
  end

  def stream_file(_), do: raise(@path_type_message)

  @doc """
  Preprocess csv row data before import.
  Currently only trims fields and values.
  Rows with {:ok, data} were decoded successfully
  Rows with {:error, data} had errors and are just logged to the console.
  """
  @spec preprocess_fun({:ok | :error, map()}) :: map()
  def preprocess_fun({:ok, row_values}) when is_map(row_values) do
    Enum.into(row_values, %{}, fn {k, v} ->
      {String.trim(k), String.trim(v)}
    end)
  end

  def preprocess_fun({:error, message}) do
    Logger.error(message)
    {:error, message}
  end

  @doc """
  Select only maps as errors are tuples
  Used as boolean result from Stream.filter/2
  """
  def filter_errors_fun(stream_row) do
    is_map(stream_row)
  end

  def dedup_fun(stream_data, strategy) do
    field = @strategy_to_field_map[strategy]
    Map.get(stream_data, field)
  end

  @doc """
  Process stream row which will be a map of Header/Value from the input csv.
  nils are excluded, because it means there was an error decoding the row.
  """
  def write_to_csv(rows_stream, path) when is_map(rows_stream) do
    filename = build_filename(path)
    local_path = Application.app_dir(:app, "#{@default_root_dir}/#{filename}")
    output = File.stream!(local_path, @default_file_modes)

    rows_stream
    |> CSV.encode(headers: ["FirstName", "LastName", "Email", "Phone"])
    |> Stream.into(output)
    |> Stream.run()
  end

  def write_to_csv(_, _), do: nil

  defp build_filename(path) do
    filename = Path.basename(path) |> Path.rootname()
    "#{@default_filename}-#{filename}.csv"
  end
end
