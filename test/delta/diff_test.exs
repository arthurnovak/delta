defmodule Delta.DiffTest do
  use ExUnit.Case, async: true

  alias Delta.Diff

  @new_file_path "test/support/new.json"
  @current_file_path "test/support/current.json"

  @expected_diff_result [
    [
      {:ok, {"http_version", "HTTP/1.1"}},
      {
        {:ok, :value_changed},
        {
          "request",
          [
            {:ok, {"body", :null}},
            {
              {:ok, :value_changed},
              {
                "headers",
                [
                  {:reordered, {"Connection", "keep-alive"}},
                  {:reordered, {"Accept-Encoding", "gzip, deflate, br"}},
                  {:ok, {"Accept-Language", "en-US;q=1"}},
                  {:added, {"x-sectrace", "uuid"}},
                  {{:reordered, :value_changed}, {"User-Agent", "Mobile/13.4.0 (iPhone; iOS 16.5)"}},
                  {{:reordered, :value_changed}, {"Cookie", "AppVersion=13.4.0;AppType=iPhone"}},
                  {:ok, {"Content-Type", "application/json"}},
                  {:reordered, {"Cache-Control", "no-cache"}}
                ]
              }
            },
            {:ok, {"method", "GET"}},
            {{:ok, :value_changed}, {"url", "url?appType=iPhone&appVersion=13.4.0"}}
          ]
        }
      },
      {:added, {"added", [added: {"key_1", [added: {"key_2", 1}]}]}},
      {:ok, {"response", [ok: {"body", "{\"appName\":\"App\"}"}, ok: {"headers", [ok: {"Cache-Control", "max-age=0"}]}, ok: {"status_code", 200}, ok: {"status_text", "OK"}]}},
      {:removed, {"removed", [removed: {"headers", [removed: {"Cache-Control", "no-cache"}]}]}}
    ]
  ]

  test "get diff" do
    new = read_decode_file(@new_file_path)
    current = read_decode_file(@current_file_path)
    assert Diff.get(new, current) == @expected_diff_result
  end

  defp read_decode_file(path) do
    {:ok, file} = File.read(path)
    :jiffy.decode(file)
  end
end
