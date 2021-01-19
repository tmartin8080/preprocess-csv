defmodule FakeStream do
  def into(_data, _output) do
    [what: "isthis"]
  end
end
