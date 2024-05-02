defmodule Delta.Print do
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
    pp(diff, @init_indent, @fmt_default)
    :ok
  end

  defp pp(diff = [head | _], indent, fmt) when is_list(head) do
    write([fmt, "#{indent}", "[\n"])
    pp_list(diff, inc_indent(indent), fmt)
    write([fmt, "\n", "#{indent}", "]"])
    fmt
  end

  defp pp(diff = [head | _], indent, fmt) when is_tuple(head) do
    write([fmt, "#{indent}", "{\n"])
    pp_list(diff, inc_indent(indent), fmt)
    write([fmt, "\n", "#{indent}", "}"])
    fmt
  end

  defp pp({tag, {key, value = [_ | _]}}, indent, _fmt) do
    {key_fmt, _} = tag_to_text_format(tag)
    write([key_fmt, "#{indent}", "\"#{key}\":\n"])
    pp(normalise(key, value), inc_indent(indent), key_fmt)
    key_fmt
  end

  defp pp({tag, {key, value}}, indent, _fmt) do
    {key_fmt, value_fmt} = tag_to_text_format(tag)
    write([key_fmt, "#{indent}", "\"#{key}\": ", value_fmt, "#{jsonify(value)}"])
    key_fmt
  end

  defp pp_list(list, indent, fmt) do
    {last, head_list} = pop_last(list)

    for obj <- head_list do
      fmt = pp(obj, indent, fmt)
      write([fmt, ",\n"])
    end

    pp(last, indent, fmt)
  end

  defp pop_last(list) do
    [h | t] = Enum.reverse(list)
    {h, Enum.reverse(t)}
  end

  defp normalise("headers", headers), do: Enum.reverse(normalise_headers(headers))
  defp normalise(_key, value), do: value

  defp normalise_headers([]), do: []
  defp normalise_headers([h | t]), do: [normalise_headers(h) | normalise_headers(t)]
  defp normalise_headers({tag, {key, value}}), do: [{remove_value_changed(tag), {"name", key}}, {tag, {"value", value}}]

  defp remove_value_changed({tag, _}), do: tag
  defp remove_value_changed(tag), do: tag

  defp tag_to_text_format(:ok), do: {@fmt_default, @fmt_default}
  defp tag_to_text_format({:ok, :value_changed}), do: {@fmt_default, @fmt_value_changed}
  defp tag_to_text_format(:reordered), do: {@fmt_reordered, @fmt_reordered}
  defp tag_to_text_format({:reordered, :value_changed}), do: {@fmt_reordered, @fmt_value_changed}
  defp tag_to_text_format(:added), do: {@fmt_added, @fmt_added}
  defp tag_to_text_format(:removed), do: {@fmt_removed, @fmt_removed}

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
