defmodule StamprWeb.EpisodeLive do
  use StamprWeb, :live_view

  alias StamprWeb.EpisodeNameComponent
  alias StamprWeb.EpisodeMarkerComponent

  def mount(%{"id" => id}, _, socket) do
    socket =
      socket
      |> assign(:episode_id, id)
      |> assign_episode()
      |> assign_now()

    Process.send_after(self(), :tick, 1_000)

    {:ok, socket}
  end

  def handle_event("start", _, socket) do
    episode = Stampr.start_episode(socket.assigns.episode)

    {:noreply, assign_episode(socket, episode: episode)}
  end

  def handle_event("add-marker", params, socket) do
    name = params["name"] || "Marker"
    episode = Stampr.add_episode_marker(socket.assigns.episode, %{name: name})

    {:noreply, assign_episode(socket, episode: episode)}
  end

  def handle_info({_, :episode_updated}, socket) do
    {:noreply, assign_episode(socket)}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 1_000)

    {:noreply, assign_now(socket)}
  end

  defp assign_episode(socket, opts \\ []) do
    episode =
      Keyword.get_lazy(opts, :episode, fn -> Stampr.get_episode(socket.assigns.episode_id) end)

    socket
    |> assign(:episode, episode)
    |> assign(:markers, Enum.sort_by(episode.markers, & &1.at))
    |> assign(:started?, !!episode.started_at)
  end

  defp assign_now(socket) do
    assign(socket, :now, System.monotonic_time(:millisecond))
  end


  defp elapsed(%{started_at: nil} = episode, _now) do
    ms_to_hms(0)
  end

  defp elapsed(episode, now) do
    ms_to_hms(now - episode.started_at)
  end
end
