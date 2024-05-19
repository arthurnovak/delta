defmodule Delta.Printer do
  alias Delta.Diff

  @init_indent ""
  @default_indent "  "

  @fmt_default :white
  @fmt_added :green
  @fmt_removed :red
  @fmt_reordered :blue
  @fmt_value_changed :italic

  @spec pretty_print(Diff.t()) :: :ok
  def pretty_print(diff) do
    write([@fmt_default, "#{@init_indent}", "[\n"])
    pp(diff, inc_indent(@init_indent), @fmt_default)
    write([@fmt_default, "\n", "#{@init_indent}", "]\n"])
  end

  defp pp(diff = [_ | _], indent, fmt) do
    {last, head_list} = pop_last(diff)

    for obj <- head_list do
      fmt = pp(obj, indent, fmt)
      write([fmt, ",\n"])
    end

    pp(last, indent, fmt)
    fmt
  end

  defp pp({key, order, value}, indent, _fmt) do
    {key_fmt, {value, value_fmt}} = get_key_val_fmt(order, value)

    case value do
      [_ | _] ->
        pp_value_list(key, value, indent, key_fmt)
        key_fmt

      _ ->
        write([key_fmt, "#{indent}", "\"#{key}\": ", value_fmt, "#{jsonify(value)}"])
        key_fmt
    end
  end

  defp pp_value_list({:normalised, key = "headers"}, value, indent, fmt) do
    write([fmt, "#{indent}", "\"#{key}\": [\n"])
    pp(normalise_headers(value), inc_indent(indent), fmt)
    write([fmt, "\n", "#{indent}", "]"])
  end

  defp pp_value_list({:normalised, _other}, value, indent, fmt) do
    write([fmt, "#{indent}", "{\n"])
    pp(value, inc_indent(indent), fmt)
    write([fmt, "\n", "#{indent}", "}"])
  end

  defp pp_value_list(key, value, indent, fmt) do
    write([fmt, "#{indent}", "\"#{key}\": {\n"])
    pp(value, inc_indent(indent), fmt)
    write([fmt, "\n", "#{indent}", "}"])
  end

  defp normalise_headers(headers) do
    for {key, order, value} <- headers do
      {
        {:normalised, nil},
        order,
        [{"name", order, key}, {"value", order, value}]
      }
    end
  end

  defp pop_last(list) do
    [h | t] = Enum.reverse(list)
    {h, Enum.reverse(t)}
  end

  defp get_key_val_fmt({_order, nil}, val), do: {@fmt_added, {val, @fmt_added}}
  defp get_key_val_fmt({nil, _order}, val), do: {@fmt_removed, {val, @fmt_removed}}
  defp get_key_val_fmt({order, order}, val), do: {@fmt_default, get_val_fmt(val, @fmt_default)}
  defp get_key_val_fmt({_new, _curr}, val), do: {@fmt_reordered, get_val_fmt(val, @fmt_reordered)}

  defp get_val_fmt({val, val}, fmt), do: {val, fmt}
  defp get_val_fmt({new_val, _curr_val}, _fmt), do: {new_val, @fmt_value_changed}
  defp get_val_fmt(val, fmt), do: {val, fmt}

  defp inc_indent(indent), do: indent <> @default_indent

  defp jsonify(atom) when is_atom(atom), do: Atom.to_string(atom)
  defp jsonify(int) when is_integer(int), do: int
  defp jsonify(str) when is_binary(str), do: "\"#{replace_quotes(str)}\""

  defp replace_quotes(str) do
    replace_opts = [
      {"\"", "\\\""},
      {"\r", "\\r"},
      {"\n", "\\n"}
    ]

    Enum.reduce(replace_opts, str, fn {pattern, replacement}, str ->
      String.replace(str, pattern, replacement)
    end)
  end

  defp write(what), do: IO.write(IO.ANSI.format(what))
end
