defmodule Delta.Parser do
  @type parser :: [{
    {{:normalised, String.t()} | String.t()},
    pos_integer(),
    term()
  }]

  @normalised :normalised

  @spec parse(:jiffy.json_value()) :: parser()
  def parse(obj) do
    parse(obj, _counter = 1)
  end

  defp parse([h | t], counter), do: [parse(h, counter)] ++ parse(t, counter + 1)

  defp parse({obj}, counter) when is_list(obj), do: parse(normalise(obj), counter)

  defp parse(obj = {_key, _value}, counter) do
    {key, value} = normalise(obj)
    {key, counter, parse(value, 1)}
  end

  defp parse(value, _counter), do: value

  defp normalise({"headers", headers}) when is_list(headers) do
    {{@normalised, "headers"}, normalise_headers(headers)}
  end

  defp normalise(obj) when is_list(obj) do
    case :proplists.get_value("request", obj) do
      {request} when is_list(request) -> normalise_request(request, obj)
      _ -> obj
    end
  end

  defp normalise(other), do: other

  defp normalise_headers([]), do: []
  defp normalise_headers([h | t]), do: [normalise_headers(h) | normalise_headers(t)]
  defp normalise_headers({[{"name", name}, {"value", value}]}), do: {name, value}

  defp normalise_request(request, obj) do
    case :proplists.get_value("url", request) do
      nil -> obj
      url -> {{@normalised, trim_qs(url)}, obj}
    end
  end

  defp trim_qs(url) do
    %URI{scheme: scheme, host: host, path: path} = URI.parse(url)
    scheme <> "://" <> host <> path
  end
end
