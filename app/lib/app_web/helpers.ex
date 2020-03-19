defmodule AppWeb.Helpers do

  def truncate_text(string, num) do
    if String.length(string) > num + 3 do
      String.slice(string, 0..num-1) <> "..."
    else
      string
    end
  end

  def current_time(_) do
    {:ok, curtime} = DateTime.now("Etc/UTC")
    curtime
  end
end
