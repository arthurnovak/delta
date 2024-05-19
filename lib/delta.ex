defmodule Delta do
  alias Delta.{Diff, Parser, Printer}

  @spec get_diff(
          String.t() | :jiffy.json_value(),
          String.t() | :jiffy.json_value()
        ) :: :ok
  def get_diff(new, current) when is_binary(new) and is_binary(current) do
    get_diff(:jiffy.decode(new), :jiffy.decode(current))
  end

  def get_diff(new, current) do
    Diff.get(Parser.parse(new), Parser.parse(current)) |> Printer.pretty_print()
  end
end
