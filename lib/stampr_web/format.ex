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
end
