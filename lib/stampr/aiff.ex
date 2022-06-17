defmodule Stampr.Aiff do
  use Bitwise

  alias __MODULE__
  alias Stampr.Aiff.Chunk

  def write!(%Aiff.FormChunk{} = form_chunk, path) do
    File.write!(path, chunk_to_binary(form_chunk))
  end

  def chunk_to_binary(chunks) when is_list(chunks) do
    chunks
    |> Enum.map(&chunk_to_binary/1)
    |> Enum.join()
  end

  def chunk_to_binary(%_{} = chunk) do
    <<id::binary-4>> = Chunk.id(chunk)
    data = Chunk.data(chunk)

    size = byte_size(data)

    <<id::binary-4, size::32, data::binary>>
  end

  def pstring(string) do
    size = byte_size(string)

    if size > 255 do
      raise ArgumentError, "string must be shorter than 255 bytes"
    end

    # Ensure the result is an EVEN number of bytes (including the size)
    if rem(size, 2) == 0 do
      <<size::8, string::binary, 0::8>>
    else
      <<size::8, string::binary>>
    end
  end

  # def aiff_sample_rate(sample_rate) when is_integer(sample_rate) do
  #   # sample_rate = av_double2int(par->sample_rate);
  #   # avio_wb16(pb, (sample_rate >> 52) + (16383 - 1023));
  #   # avio_wb64(pb, UINT64_C(1) << 63 | sample_rate << 11);

  #   high_bits = (sample_rate >>> 52) + (16383 - 1023)

  #   low_bits = <<1::1, sample_rate <<< 11::63>>

  #   <<high_bits::16, low_bits::binary-8>>
  # end
end
