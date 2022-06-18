defmodule Stampr do
  alias Stampr.Episode

  @table_name :episodes

  @doc """
  Removes all episodes. Useful for resetting the state of the system for tests.
  """
  def delete_all_episodes do
    with_table(fn ->
      :dets.delete_all_objects(@table_name)
    end)
  end

  @doc """
  Returns a list of all episodes, sorted ascending by creation time.
  """
  def list_episodes do
    with_table(fn ->
      @table_name
      |> :dets.match({:_, :"$1"})
      |> List.flatten()
      |> Enum.sort_by(& &1.created_at, {:desc, DateTime})
    end)
  end

  @doc """
  Gets an episode by ID. Returns nil if it doesn't exist.
  """
  def get_episode(id) do
    with_table(fn ->
      @table_name
      |> :dets.match({id, :"$1"})
      |> List.flatten()
      |> case do
        [] -> nil
        [ep] -> ep
      end
    end)
  end

  @doc """
  Creates a new episode.
  """
  def create_episode(attrs \\ []) do
    attrs
    |> Episode.new()
    |> put_episode()
  end

  @doc """
  Updates an existing episode.
  """
  def update_episode(episode, attrs) do
    episode
    |> Episode.update(attrs)
    |> put_episode()
  end

  @doc """
  Deletes an existing episode.
  """
  def delete_episode(episode) do
    with_table(fn ->
      :dets.delete(@table_name, episode.id)
    end)

    :ok
  end

  @doc """
  Sets the start time for the episode.
  """
  def start_episode(episode) do
    episode
    |> Episode.start()
    |> put_episode()
  end

  @doc """
  Sets the end time for the episode.
  """
  def stop_episode(episode) do
    episode
    |> Episode.stop()
    |> put_episode()
  end

  @doc """
  Sets the start time for the episode.
  """
  def add_episode_marker(episode, attrs \\ %{}) do
    episode
    |> Episode.add_marker_now(attrs)
    |> put_episode()
  end

  @doc """
  Updates marker info.
  """
  def update_episode_marker(episode, marker, changes) do
    episode
    |> Episode.update_marker(marker, changes)
    |> put_episode()
  end

  @doc """
  Deletes a marker.
  """
  def remove_episode_marker(episode, marker) do
    episode
    |> Episode.remove_marker(marker)
    |> put_episode()
  end

  @doc """
  Saves the episode AIFF to disk.
  """
  def save_episode_aiff(episode, filename) do
    episode
    |> Episode.to_aiff()
    |> Stampr.Aiff.write!(filename)
  end

  defp put_episode(episode) do
    with_table(fn ->
      :dets.insert(@table_name, {episode.id, episode})
    end)

    episode
  end

  defp with_table(fun) do
    {:ok, _} = :dets.open_file(@table_name, file: String.to_charlist(dets_file()), type: :set)
    result = fun.()
    :dets.close(@table_name)
    result
  end

  defp dets_file, do: Application.get_env(:stampr, :dets_file, "priv/episodes_prod")
end
