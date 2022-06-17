defmodule Stampr.Episode do
  defstruct id: nil,
            name: "Untitled",
            markers: [],
            created_at: nil,
            started_at: nil,
            stopped_at: nil

  defmodule Marker do
    defstruct id: nil, name: "Marker", at: nil

    def new(fields \\ []) do
      __MODULE__
      |> struct!(fields)
      |> Map.put(:id, UUID.uuid4())
    end
  end

  alias Stampr.Aiff

  def new(fields \\ []) do
    __MODULE__
    |> struct!(fields)
    |> Map.put(:id, UUID.uuid4())
    |> Map.put(:created_at, DateTime.utc_now())
  end

  def update(episode, changes) do
    changes = clean_changes(changes)

    Map.merge(episode, changes)
  end

  defp clean_changes(changes) do
    changes = Map.take(changes, [:name])

    changes
    |> Enum.map(fn {k, v} -> {k, clean_change(k, v)} end)
    |> Map.new()
  end

  defp clean_change(:name, name) do
    case String.trim(name) do
      "" -> "Untitled"
      name -> name
    end
  end

  defp clean_change(_, value), do: value

  def start(%__MODULE__{started_at: nil} = episode) do
    %{episode | started_at: now_ms()}
  end

  def start(episode), do: episode

  def stop(%__MODULE__{started_at: nil} = episode), do: episode

  def stop(episode) do
    %{episode | stopped_at: now_ms()}
  end

  def add_marker_now(episode, attrs \\ %{})

  def add_marker_now(%__MODULE__{started_at: nil} = episode, _attrs), do: episode

  def add_marker_now(episode, attrs) do
    new_marker = attrs |> Map.merge(%{at: now_ms() - episode.started_at}) |> Marker.new()

    %{episode | markers: episode.markers ++ [new_marker]}
  end

  def update_marker(episode, marker, changes) do
    changes = Map.take(changes, [:name])

    new_markers =
      for m <- episode.markers do
        if m.id == marker.id do
          Map.merge(m, changes)
        else
          m
        end
      end

    %{episode | markers: new_markers}
  end

  def remove_marker(episode, marker) do
    new_markers = Enum.reject(episode.markers, &(&1.id == marker.id))

    %{episode | markers: new_markers}
  end

  def to_aiff(episode) do
    sample_rate = 1
    sample_size = 16
    stopped_at = episode.stopped_at || now_ms()
    duration_ms = stopped_at - episode.started_at
    num_sample_frames = ms_to_frames(duration_ms, sample_rate)

    aiff_markers =
      for marker <- episode.markers do
        %Aiff.MarkerChunk.Marker{
          position: ms_to_frames(marker.at, sample_rate),
          name: marker.name
        }
      end

    %Aiff.FormChunk{
      local_chunks: [
        %Aiff.CommonChunk{
          sample_rate: sample_rate,
          sample_size: sample_size,
          num_sample_frames: num_sample_frames
        },
        %Aiff.SilentSoundDataChunk{
          sample_size: sample_size,
          num_sample_frames: num_sample_frames
        },
        %Aiff.MarkerChunk{markers: aiff_markers}
      ]
    }
  end

  defp now_ms, do: System.monotonic_time(:millisecond)

  defp ms_to_frames(ms, sample_rate) do
    trunc(sample_rate * ms / 1_000)
  end
end
