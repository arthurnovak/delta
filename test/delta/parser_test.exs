defmodule Delta.ParserTest do
  use ExUnit.Case

  alias Delta.Parser

  @new_file_path "test/support/new.json"

  @expected_result [
    {{:normalised, "http://host.com/url"}, 1,
     [
       {"http_version", 1, "HTTP/1.1"},
       {"request", 2,
        [
          {"body", 1, :null},
          {{:normalised, "headers"}, 2,
           [
             {"Cache-Control", 1, "no-cache"},
             {"Content-Type", 2, "application/json"},
             {"Cookie", 3, "AppVersion=13.4.0;AppType=iPhone"},
             {"User-Agent", 4, "Mobile/13.4.0 (iPhone; iOS 16.5)"},
             {"x-sectrace", 5, "uuid"},
             {"Accept-Language", 6, "en-US;q=1"},
             {"Accept-Encoding", 7, "gzip, deflate, br"},
             {"Connection", 8, "keep-alive"}
           ]},
          {"method", 3, "GET"},
          {"url", 4, "http://host.com/url?appType=iPhone&appVersion=13.4.0"}
        ]},
       {"added", 3, [{"key_1", 1, [{"key_2", 1, 1}]}]},
       {"response", 4,
        [
          {"body", 1, "{\"appName\":\"App\"}"},
          {{:normalised, "headers"}, 2, [{"Cache-Control", 1, "max-age=0"}]},
          {"status_code", 3, 200},
          {"status_text", 4, "OK"}
        ]}
     ]}
  ]

  test "parse json" do
    new = read_decode_file(@new_file_path)
    assert Parser.parse(new) == @expected_result
  end

  defp read_decode_file(path) do
    {:ok, file} = File.read(path)
    :jiffy.decode(file)
  end
end
