defmodule Stampr.Aiff.FormChunk do
  alias Stampr.Aiff

  defstruct form_type: "AIFF", local_chunks: []

  defimpl Stampr.Aiff.Chunk do
    def id(_), do: "FORM"

    def data(chunk) do
      chunk.form_type <> Aiff.chunk_to_binary(chunk.local_chunks)
    end
  end
end
