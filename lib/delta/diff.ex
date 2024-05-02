defmodule Delta.Diff do
  @type diff :: Keyword.t() | [Keyword.t()]

  @spec get(
          :jiffy.json_value() | [:jiffy.json_value()],
          :jiffy.json_value() | [:jiffy.json_value()]
        ) :: diff()
  def get(new, current), do: get(new, current, nil)

  defp get([h1 | t1], [h2 | t2], tag), do: [get(h1, h2, tag)] ++ get(t1, t2, tag)
  defp get({new}, {current}, _tag), do: do_get(new, current, 0, get_keys(current))
  defp get(_new_val, current_val, :removed), do: current_val
  defp get(new_val, _current_val, _tag), do: new_val

  defp do_get([], current, _, _) do
    Enum.map(current, fn {key, val} -> tag_get_value(:removed, key, {[]}, key, val) end)
  end

  defp do_get([{key1, val1} | tail1], current, new_index, current_keys) do
    case :proplists.get_value(key1, current, nil) do
      nil ->
        [
          tag_get_value(:added, key1, val1, key1, {[]})
          | do_get(tail1, current, new_index + 1, current_keys)
        ]

      val2 ->
        tag = get_ok_reordered_tag(key1, current_keys, new_index, val1, val2)

        [
          tag_get_value(tag, key1, val1, key1, val2)
          | do_get(tail1, List.keydelete(current, key1, 0), new_index + 1, current_keys)
        ]
    end
  end

  defp tag_get_value(tag, key1, val1, key2, val2) do
    {tag, {key1, get(normalise(key1, val1), normalise(key2, val2), tag)}}
  end

  defp get_keys(keyword_list), do: for({k, _} <- keyword_list, do: k)

  defp get_ok_reordered_tag(key, keys, index, val1, val2) do
    tag =
      case Enum.at(keys, index) do
        ^key -> :ok
        _other -> :reordered
      end

    maybe_add_value_changed_tag(tag, val1, val2)
  end

  defp maybe_add_value_changed_tag(tag, val, val), do: tag
  defp maybe_add_value_changed_tag(tag, _val1, _val2), do: {tag, :value_changed}

  defp normalise(_key, value = {[]}), do: value
  defp normalise("headers", headers), do: {Enum.reverse(normalise_headers(headers))}
  defp normalise(_key, value), do: value

  defp normalise_headers([]), do: []
  defp normalise_headers([h | t]), do: [normalise_headers(h) | normalise_headers(t)]
  defp normalise_headers({[{"name", name}, {"value", value}]}), do: {name, value}
end
