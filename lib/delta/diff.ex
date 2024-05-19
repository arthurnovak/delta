defmodule Delta.Diff do
  alias Delta.Parser

  @type diff :: [{
    {{:normalised, String.t()} | String.t()},
    {pos_integer() | nil, pos_integer() | nil},
    {term(), term()} | term()
  }]

  @spec get(Parser.t(), Parser.t()) :: diff()
  def get([{key, new_order, new_value} | tail], current) do
    case List.keytake(current, key, 0) do
      nil ->
        [{key, {new_order, nil}, get_added(new_value)}] ++ get(tail, current)

      {{key, curr_order, curr_value}, current} ->
        [{key, {new_order, curr_order}, get(new_value, curr_value)}] ++ get(tail, current)
    end
  end

  def get([], current) when is_list(current) do
    for {key, order, curr_value} <- current,
        do: {key, {nil, order}, get_removed(curr_value)}
  end

  def get(new, current) do
    {new, current}
  end

  defp get_added(added) when is_list(added), do: get(added, [])
  defp get_added(added), do: added

  defp get_removed(removed) when is_list(removed), do: get([], removed)
  defp get_removed(removed), do: removed
end
