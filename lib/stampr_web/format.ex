defmodule StamprWeb.Format do
  def ms_to_hms(ms) do
    s = trunc(ms / 1000)

    h = trunc(s / 60 / 60)
    s = s - h * 60 * 60

    m = trunc(s / 60)
    s = s - m * 60

    [h, m, s]
    |> Enum.map(&String.pad_leading(to_string(&1), 2, "0"))
    |> Enum.join(":")
  end

  def date(datetime) do
    Timex.format!(datetime, "{WDfull}, {Mfull} {D}, {YYYY}")
  end

  def pluralize(count, single), do: pluralize(count, single, single <> "s")
  def pluralize(1, single, _plural), do: single
  def pluralize(_, _single, plural), do: plural
end
