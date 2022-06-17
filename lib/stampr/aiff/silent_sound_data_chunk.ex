defmodule Stampr.Aiff.SilentSoundDataChunk do
  defstruct sample_size: 16, num_channels: 1, num_sample_frames: 0

  defimpl Stampr.Aiff.Chunk do
    def id(_), do: "SSND"

    def data(chunk) do
      num_bits = chunk.num_channels * chunk.sample_size * chunk.num_sample_frames

      <<
        0::32,
        0::32,
        0::size(num_bits)
      >>
    end
  end
end
