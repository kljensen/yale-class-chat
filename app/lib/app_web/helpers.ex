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

  def truncate_text(text, max_words, max_chars) do
    text_normalized = Regex.replace(~r/[ \t]+/u, text,  " ")
    # Split on whitespace but keep whitespace
    text_split = Regex.split(~r/(\s+)/u, text_normalized, include_captures: true)
    words_kept = Enum.slice(text_split, 0, max_words)
    truncated_words = length(text_split) != length(words_kept)

    words_kept_joined = Enum.join(words_kept, "")
    words_kept_joined_sliced = String.slice(words_kept_joined, 0, max_chars)
    truncated_string = String.length(words_kept_joined) != String.length(words_kept_joined_sliced)
    paragraphs = words_kept_joined_sliced |> split_newlines
    was_truncated = truncated_words ||  truncated_string
    {was_truncated, paragraphs}
  end


end
