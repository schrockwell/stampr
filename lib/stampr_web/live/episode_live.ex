defmodule StamprWeb.EpisodeLive do
  use StamprWeb, :live_view

  alias StamprWeb.EpisodeNameComponent
  alias StamprWeb.EpisodeMarkerComponent

  def mount(%{"id" => id}, _, socket) do
    socket =
      socket
      |> assign(:episode_id, id)
      |> assign(:selected_index, 0)
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
    {:noreply, socket |> assign_episode(episode: episode) |> assign(:selected_index, 0)}
  end

  def handle_event("keydown", %{"key" => "m"}, socket) do
    episode = Stampr.add_episode_marker(socket.assigns.episode, %{name: "Marker"})
    {:noreply, socket |> assign_episode(episode: episode) |> assign(:selected_index, 0)}
  end

  def handle_event("keydown", %{"key" => "t"}, socket) do
    episode = Stampr.add_episode_marker(socket.assigns.episode, %{name: "Transition"})
    {:noreply, socket |> assign_episode(episode: episode) |> assign(:selected_index, 0)}
  end

  def handle_event("keydown", %{"key" => key}, socket) when key in ["j", "ArrowDown"] do
    {:noreply, change_selected_index(socket, 1)}
  end

  def handle_event("keydown", %{"key" => key}, socket) when key in ["k", "ArrowUp"] do
    {:noreply, change_selected_index(socket, -1)}
  end

  def handle_event("keydown", %{"key" => _key}, socket) do
    {:noreply, socket}
  end

  def handle_info({_, :episode_updated}, socket) do
    {:noreply, socket |> assign_episode() |> change_selected_index()}
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
    |> assign(:markers, Enum.sort_by(episode.markers, &(-&1.at)))
    |> assign(:started?, !!episode.started_at)
  end

  defp assign_now(socket) do
    assign(socket, :now, System.monotonic_time(:millisecond))
  end

  defp elapsed(%{started_at: nil}, _now), do: ms_to_hms(0)
  defp elapsed(episode, now), do: ms_to_hms(now - episode.started_at)

  defp change_selected_index(socket, delta \\ 0) do
    next_index =
      max(
        min(socket.assigns.selected_index + delta, length(socket.assigns.episode.markers) - 1),
        0
      )

    assign(socket, :selected_index, next_index)
  end
end
