defmodule Stampr.Aiff.CommonChunk do
  defstruct num_channels: 1, num_sample_frames: 0, sample_size: 16, sample_rate: 48_000

  defimpl Stampr.Aiff.Chunk do
    # @sample_rates %{
    #   1 => Base.decode16!("400E0001000000000000"),
    #   48_000 => Base.decode16!("400EBB80000000000000")
    # }

    def id(_), do: "COMM"

    def data(chunk) do
      sample_rate = <<64, 14, chunk.sample_rate::16, 0, 0, 0, 0, 0, 0>>

      <<
        chunk.num_channels::16,
        chunk.num_sample_frames::32,
        chunk.sample_size::16,
        sample_rate::binary
      >>
    end
  end
end
