defmodule StamprWeb.EpisodeNameComponent do
  use StamprWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, :editing?, false)}
  end

  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :editing?, true)}
  end

  def handle_event("save", %{"name" => name}, socket) do
    episode = Stampr.update_episode(socket.assigns.episode, %{name: name})

    send(self(), {__MODULE__, :episode_updated})

    {:noreply, socket |> assign(:editing?, false) |> assign(:episode, episode)}
  end
end
