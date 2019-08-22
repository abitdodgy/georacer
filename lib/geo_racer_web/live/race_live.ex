defmodule GeoRacerWeb.RaceLive do
  @moduledoc false
  use Phoenix.LiveView

  @topic "position_updates"

  def render(assigns) do
    Phoenix.View.render(GeoRacerWeb.RaceView, assigns.view, assigns)
  end

  def mount(session, socket) do
    GeoRacerWeb.Endpoint.subscribe(@topic)

    {:ok, assign(socket, position: nil, waypoints: [], view: session.view)}
  end

  def handle_info(%{event: "update", payload: position}, socket) do
    {:noreply, put_position(socket, position)}
  end

  def handle_event("set_waypoint", _value, %{assigns: %{waypoints: waypoints}} = socket) do
    case socket.assigns.position do
      nil -> {:noreply, socket}
      position -> {:noreply, assign(socket, waypoints: [position | waypoints])}
    end
  end

  def handle_event("delete_waypoint", value, socket) do
    with {index, _} <- Integer.parse(value) do
      {:noreply, delete_waypoint(socket, index)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp put_position(socket, position) do
    assign(socket, position: position)
  end

  defp delete_waypoint(socket, index) do
    assign(socket, waypoints: List.delete_at(socket.assigns.waypoints, index))
  end
end
