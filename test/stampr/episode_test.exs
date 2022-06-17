defmodule Stampr.EpisodeTest do
  use ExUnit.Case, async: true

  alias Stampr.Episode

  test "an episode can be converted to an AIFF struct" do
    episode =
      Episode.new()
      |> Episode.start()
      |> Episode.add_marker_now(%{name: "marker 1"})

    Process.sleep(1_000)

    episode =
      episode
      |> Episode.add_marker_now(%{name: "marker 2"})

    Process.sleep(1_000)

    episode =
      episode
      |> Episode.add_marker_now(%{name: "marker 3"})
      |> Episode.stop()

    episode |> Episode.to_aiff() |> Stampr.Aiff.write!("test2.aiff")

    assert %Stampr.Aiff.FormChunk{
             form_type: "AIFF",
             local_chunks: [
               %Stampr.Aiff.CommonChunk{
                 num_channels: 1,
                 num_sample_frames: _,
                 sample_rate: _,
                 sample_size: 16
               },
               %Stampr.Aiff.SilentSoundDataChunk{
                 num_channels: 1,
                 num_sample_frames: _,
                 sample_size: 16
               },
               %Stampr.Aiff.MarkerChunk{
                 markers: [
                   %Stampr.Aiff.MarkerChunk.Marker{name: "marker 3", position: _},
                   %Stampr.Aiff.MarkerChunk.Marker{name: "marker 2", position: _},
                   %Stampr.Aiff.MarkerChunk.Marker{name: "marker 1", position: _}
                 ]
               }
             ]
           } = Episode.to_aiff(episode)
  end
end
