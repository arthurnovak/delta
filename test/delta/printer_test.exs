defmodule Delta.PrinterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Delta.Printer

  @fmt_ok "\e[37m"
  @fmt_added "\e[32m"
  @fmt_removed "\e[31m"
  @fmt_reordered "\e[34m"
  @fmt_value_changed "\e[3m"
  @fmt_end "\e[0m"

  test "print unchanged key" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_ok}  \"key\": #{@fmt_ok}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {1, 1}, {"value", "value"}}], expected)
  end

  test "print unchanged key and changed value" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_ok}  \"key\": #{@fmt_value_changed}\"new_value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {1, 1}, {"new_value", "old_value"}}], expected)
  end

  test "print added key" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_added}  \"key\": #{@fmt_added}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {1, nil}, "value"}], expected)
  end

  test "print removed key" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_removed}  \"key\": #{@fmt_removed}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {nil, 1}, "value"}], expected)
  end

  test "print reordered key" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_reordered}  \"key\": #{@fmt_reordered}\"value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {1, 2}, {"value", "value"}}], expected)
  end

  test "print reordered key with changed value" do
    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_reordered}  \"key\": #{@fmt_value_changed}\"new_value\"#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print([{"key", {1, 2}, {"new_value", "old_value"}}], expected)
  end

  test "print headers" do
    headers_diff = {
      {:normalised, "headers"},
      {1, 1},
      [
        {"key1", {1, 3}, {"value1", "value2"}},
        {"key2", {2, 2}, {"value2", "value2"}}
      ]
    }

    expected = [
      "#{@fmt_ok}[\n",
      "#{@fmt_end}#{@fmt_ok}  \"headers\": [\n",
      "#{@fmt_end}#{@fmt_reordered}    {\n",
      "#{@fmt_end}#{@fmt_reordered}      \"name\": #{@fmt_reordered}\"key1\"#{@fmt_end}#{@fmt_reordered},\n",
      "#{@fmt_end}#{@fmt_reordered}      \"value\": #{@fmt_value_changed}\"value1\"#{@fmt_end}#{@fmt_reordered}\n",
      "    }#{@fmt_end}#{@fmt_reordered},\n",
      "#{@fmt_end}#{@fmt_ok}    {\n",
      "#{@fmt_end}#{@fmt_ok}      \"name\": #{@fmt_ok}\"key2\"#{@fmt_end}#{@fmt_ok},\n",
      "#{@fmt_end}#{@fmt_ok}      \"value\": #{@fmt_ok}\"value2\"#{@fmt_end}#{@fmt_ok}\n",
      "    }#{@fmt_end}#{@fmt_ok}\n",
      "  ]#{@fmt_end}#{@fmt_ok}\n",
      "]\n#{@fmt_end}"
    ]

    assert_pretty_print(headers_diff, expected)
  end

  defp assert_pretty_print(diff, expected_print) do
    assert capture_io(fn -> Printer.pretty_print(diff) end) == Enum.join(expected_print)
  end
end
