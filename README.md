# delta
Quick JSON diff checker

### Usage
```shell
mix delta test/support/new.json test/support/current.json
```
![Diff](./docs/img/diff_example.png)

where the objects that formatted in
- red are removed keys
- green are added keys
- blue are reordered keys
- italics are changed values only

### Implementation
Delta implementation comprises three main components:

#### 1. Parser
This component receives a decoded `:jiffy` JSON object and parses it, converting the object into a list of tuples with three elements, formatted as follows:
```elixir
{
  "key" | {:normalised, "key"}, # The first element is either an unchanged JSON key or a normalised key. For example, headers may require normalisation
  pos_integer(), # This element indicates the position of the key-value pair. Counting starts from 1
  "value" # This can be an object, string, integer, etc.
}
```

Possible options for normalised keys:
1. `headers`: Parser converts a list of `name:key, value:value` header objects to simple `key:value` pairs.
2. `url`s: Each request/response object is identified by a request URL, which acts as the key for the object. The parser retrieves the request URL without query string parameters and uses it as the key for the entire request/response object. It assumes that if the URLs with trimmed query string parameters are different, then the request/response objects are considered different too.

The parsing result may look like the one below. The ParserTest should also provide some hints on how Parser works.
```elixir
  [
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

```

#### 2. Diff
The function `Diff.get/2` compares two parsed objects and outputs their differences as a list of tuples.
Each tuple contains three elements and follows this format:
```elixir
{
  "key" | {:normalised, "key"}, # The key of the object
  {pos_integer() | nil, pos_integer() | nil}, # The position of the object: the first element shows the new position (or nil if the object was removed), and the second element shows the old position (or nil if the object was added). Counting starts from 1
  "new_or_old_value" | {"new_value", "old_value"} # The new or old value of the object. If the object's value was changed, both new and old values are included. If the object was added or removed, only one value is present
}
```

An example of a diff might appear as follows:
```elixir
  [
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

```

#### 3. Printer
The final stage involves printing the result.
The `Printer.pretty_print/1` function accepts the diff as its argument and outputs the result in a format that considers:
- Whether the key is normalised or not (such as `headers` and `url`s)
- If the order of the object has changed
- Whether the value was altered

### Tests
Please refer to `new` and `current` json files in `test/support` folder.

To run tests
```shell
mix test
```
