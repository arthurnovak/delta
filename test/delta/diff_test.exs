defmodule Delta.DiffTest do
  use ExUnit.Case

  alias Delta.{Diff, Parser}

  @new_file_path "test/support/new.json"
  @current_file_path "test/support/current.json"

  @expected_result [
    {{:normalised, "http://host.com/url"}, {1, 1},
     [
       {"http_version", {1, 1}, {"HTTP/1.1", "HTTP/1.1"}},
       {"request", {2, 2},
        [
          {"body", {1, 1}, {:null, :null}},
          {{:normalised, "headers"}, {2, 2},
           [
             {"Cache-Control", {1, 6}, {"no-cache", "no-cache"}},
             {"Content-Type", {2, 1}, {"application/json", "application/json"}},
             {"Cookie", {3, 3},
              {"AppVersion=13.4.0;AppType=iPhone", "AppVersion=13.3.7;AppType=iPhone"}},
             {"User-Agent", {4, 4},
              {"Mobile/13.4.0 (iPhone; iOS 16.5)", "Mobile/13.3.7 (iPhone; iOS 16.5)"}},
             {"x-sectrace", {5, nil}, "uuid"},
             {"Accept-Language", {6, 5}, {"en-US;q=1", "en-US;q=1"}},
             {"Accept-Encoding", {7, 7}, {"gzip, deflate, br", "gzip, deflate, br"}},
             {"Connection", {8, 2}, {"keep-alive", "keep-alive"}}
           ]},
          {"method", {3, 3}, {"GET", "GET"}},
          {"url", {4, 4},
           {"http://host.com/url?appType=iPhone&appVersion=13.4.0",
            "http://host.com/url?appType=iPhone&appVersion=13.3.7"}}
        ]},
       {"added", {3, nil}, [{"key_1", {1, nil}, [{"key_2", {1, nil}, 1}]}]},
       {"response", {4, 4},
        [
          {"body", {1, 1}, {"{\"appName\":\"App\"}", "{\"appName\":\"App\"}"}},
          {{:normalised, "headers"}, {2, 2},
           [{"Cache-Control", {1, 1}, {"max-age=0", "max-age=0"}}]},
          {"status_code", {3, 3}, {200, 200}},
          {"status_text", {4, 4}, {"OK", "OK"}}
        ]},
       {"removed", {nil, 3},
        [
          {{:normalised, "headers"}, {nil, 1}, [{"Cache-Control", {nil, 1}, "no-cache"}]}
        ]}
     ]}
  ]

  test "get diff" do
    new = read_decode_parse_file(@new_file_path)
    current = read_decode_parse_file(@current_file_path)
    assert Diff.get(new, current) == @expected_result
  end

  defp read_decode_parse_file(path) do
    {:ok, file} = File.read(path)
    file |> :jiffy.decode() |> Parser.parse()
  end
end
