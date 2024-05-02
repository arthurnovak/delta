defmodule Delta.PrintTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Delta.Print

  @fmt_ok "\e[37m"
  @fmt_added "\e[32m"
  @fmt_removed "\e[31m"
  @fmt_reordered "\e[34m"
  @fmt_value_changed "\e[3m"
  @fmt_end "\e[0m"

  test "pretty print unchanged key" do
    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_ok}  \"key\": #{@fmt_ok}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print([{:ok, {"key", "value"}}], expected)
  end

  test "pretty print unchanged key and changed value" do
    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_ok}  \"key\": #{@fmt_value_changed}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print([{{:ok, :value_changed}, {"key", "value"}}], expected)
  end

  test "pretty print added key" do
    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_added}  \"key\": #{@fmt_added}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print([{:added, {"key", "value"}}], expected)
  end

  test "pretty print reordered key" do
    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_removed}  \"key\": #{@fmt_removed}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print([{:removed, {"key", "value"}}], expected)
  end

  test "pretty print removed key" do
    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_reordered}  \"key\": #{@fmt_reordered}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print([{:reordered, {"key", "value"}}], expected)
  end

  test "pretty print headers" do
    headers_diff = [
      {:ok,
       {"headers",
        [
          {:reordered, {"key1", "value1"}},
          {:ok, {"key2", "value2"}}
        ]}}
    ]

    expected = [
      "#{@fmt_ok}{\n",
      "#{@fmt_end}#{@fmt_ok}  \"headers\":\n",
      "#{@fmt_end}#{@fmt_ok}    [\n",
      "#{@fmt_end}#{@fmt_ok}      {\n",
      "#{@fmt_end}#{@fmt_ok}        \"name\": #{@fmt_ok}\"key2\"#{@fmt_end}#{@fmt_ok},\n",
      "#{@fmt_end}#{@fmt_ok}        \"value\": #{@fmt_ok}\"value2\"#{@fmt_end}#{@fmt_ok}\n",
      "      }#{@fmt_end}#{@fmt_ok},\n",
      "#{@fmt_end}#{@fmt_ok}      {\n",
      "#{@fmt_end}#{@fmt_reordered}        \"name\": #{@fmt_reordered}\"key1\"#{@fmt_end}#{@fmt_reordered},\n",
      "#{@fmt_end}#{@fmt_reordered}        \"value\": #{@fmt_reordered}\"value1\"#{@fmt_end}#{@fmt_ok}\n",
      "      }#{@fmt_end}#{@fmt_ok}\n",
      "    ]#{@fmt_end}#{@fmt_ok}\n",
      "}#{@fmt_end}"
    ]

    assert_pretty_print(headers_diff, expected)
  end

  defp assert_pretty_print(diff, expected_print) do
    assert capture_io(fn -> Print.pretty_print(diff) end) == Enum.join(expected_print)
  end
end
