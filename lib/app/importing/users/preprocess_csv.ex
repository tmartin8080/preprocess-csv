defmodule App.Importing.Users.PreprocessCSV do
  @moduledoc """
  Convenience functions for processing files.
  """
  @path_type_message "File path must be a string."
  @default_root_dir "priv/preprocessed"
  @default_filename "processed"
  @default_file_modes [:write, :utf8]

  require Logger

  def stream_file(path) when is_binary(path) do
    case File.exists?(path) do
      true -> File.stream!(path)
      false -> raise "#{path} was not found."
    end
  end

  def stream_file(_), do: raise(@path_type_message)

  @doc """
  Preprocess csv row data before import.
  Currently only trims fields and values, but also splits decode
  errors rather than just swalling them.

  Rows with {:ok, data} were decoded successfully
  Rows with {:error, data} had errors and are just logged to the console.
  """
  @spec preprocess_row_fun({:ok | :error, map()}) :: map()
  def preprocess_row_fun({:ok, row_values}) when is_map(row_values) do
    Enum.into(row_values, %{}, fn {k, v} ->
      {String.trim(k), String.trim(v)}
    end)
  end

  def preprocess_row_fun({:error, message}) do
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

  @doc """
  Deduplicate by strategy: email, phone, email_or_phone
  Using muli-clause functions so they can be improved on
  separately.

  For instance when the same numbers are formatted
  differently: 111.111.1111 vs 111-111-1111
  """
  def dedup_by(stream_data, "email") do
    stream_data
    |> Enum.reduce([], fn stream_row, acc ->
      emails = Enum.map(acc, & &1["Email"])

      case Enum.member?(emails, stream_row["Email"]) do
        true -> acc
        false -> [stream_row | acc]
      end
    end)
  end

  def dedup_by(stream_data, "phone") do
    stream_data
    |> Enum.reduce([], fn stream_row, acc ->
      phones = Enum.map(acc, & &1["Phone"])

      case Enum.member?(phones, stream_row["Phone"]) do
        true -> acc
        false -> [stream_row | acc]
      end
    end)
  end

  def dedup_by(stream_data, "email_or_phone") do
    stream_data
    |> dedup_by("email")
    |> dedup_by("phone")
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
