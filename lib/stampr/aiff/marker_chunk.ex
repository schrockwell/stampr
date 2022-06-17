defmodule Stampr.Aiff.MarkerChunk do
  alias Stampr.Aiff

  defstruct markers: []

  defmodule Marker do
    defstruct name: "Marker", position: 0
  end

  defimpl Stampr.Aiff.Chunk do
    def id(_), do: "MARK"

    def data(chunk) do
      num_markers = length(chunk.markers)

      marker_data =
        chunk.markers
        |> Enum.with_index(1)
        |> Enum.map(fn {marker, id} ->
          <<id::16, marker.position::32, Aiff.pstring(marker.name)::binary>>
        end)
        |> Enum.join()

      <<num_markers::16, marker_data::binary>>
    end
  end
end
