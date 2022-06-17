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
    changes = Map.take(changes, [:name])
    Map.merge(episode, changes)
  end

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
    new_marker = %Marker{at: now_ms() - episode.started_at} |> Map.merge(attrs)

    %{episode | markers: [new_marker | episode.markers]}
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
    duration_ms = episode.stopped_at - episode.started_at
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
