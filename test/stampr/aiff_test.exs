defmodule Stampr.AiffTest do
  use ExUnit.Case, async: true

  alias Stampr.Aiff
  alias Stampr.Aiff.FormChunk

  describe "the form chunk" do
    test "to_binary/1" do
      assert "FORM\0\0\0\x04AIFF" == Aiff.chunk_to_binary(%FormChunk{})
    end
  end

  # @tag :skip
  # describe "aiff_sample_rate" do
  #   test "works" do
  #     assert "400EBB80000000000000" ==
  #              Aiff.aiff_sample_rate(48_000)
  #              |> Base.encode16()
  #   end
  # end

  describe "write!" do
    test "works" do
      %Aiff.FormChunk{
        local_chunks: %Aiff.CommonChunk{}
      }
      |> Aiff.write!("test.aiff")
    end
  end

  describe "SilentSoundDataChunk" do
    test "generates the correct number of buts for 1 channel, 8 bps, 48khz" do
      chunk = %Aiff.SilentSoundDataChunk{sample_size: 8, num_channels: 1, num_sample_frames: 2}

      assert Aiff.chunk_to_binary(chunk) ==
               <<"SSND", 10::32, 0::32, 0::32, 0, 0>>
    end
  end
end
