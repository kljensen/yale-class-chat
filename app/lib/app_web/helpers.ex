defmodule AppWeb.Helpers do
  require Decimal
  use Phoenix.HTML

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

  def stars(nil), do: ""
  def stars(0), do: ""
  def stars(num) do
    whole_stars = Decimal.to_float(num) |> trunc
    fractional_stars = Decimal.to_float(num) - whole_stars
    fraction_string = cond do
        fractional_stars >= 0.75 ->
            "¾"
        fractional_stars >= 0.50 ->
            "½"
        fractional_stars >= 0.25 ->
            "¼"
        true ->
            ""
    end
    String.duplicate("★", whole_stars) <> fraction_string
  end

  def xform_for(form_data, action, options \\ [], fun) do
    options = Keyword.merge(options, [class: "uk-form-stacked"])
    form_for(form_data, action, options, fun)
  end

  def split_newlines(text) do
     Regex.split(~r{\n\s*\n}, text, trim: true)
  end

end
