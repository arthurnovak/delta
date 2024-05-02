defmodule Mix.Tasks.Delta do
  use Mix.Task

  def run([new_path, current_path]) do
    Delta.get_diff(read_file(new_path), read_file(current_path))
  end

  def run(_) do
    IO.puts("usage: mix delta <new_json_path> <current_json_path>")
  end

  defp read_file(path) do
    {:ok, file} = File.read(path)
    file
  end
end
