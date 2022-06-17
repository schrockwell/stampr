defmodule StamprWeb.EpisodeMarkerComponent do
  use StamprWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, :editing?, false)}
  end

  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :editing?, true)}
  end

  def handle_event("save", %{"name" => name}, socket) do
    Stampr.update_episode_marker(socket.assigns.episode, socket.assigns.marker, %{name: name})

    send(self(), {__MODULE__, :episode_updated})

    {:noreply, socket |> assign(:editing?, false)}
  end

  def handle_event("delete", _, socket) do
    Stampr.remove_episode_marker(socket.assigns.episode, socket.assigns.marker)

    send(self(), {__MODULE__, :episode_updated})

    {:noreply, socket |> assign(:editing?, false)}
  end
end
