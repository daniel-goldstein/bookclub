defmodule BookclubWeb.MeetingLive.NoteComponent do
  use BookclubWeb, :live_component

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :blur_style, if(assigns.spoilers, do: "", else: "blur-lg"))

    ~H"""
    <div id={"note-#{@note.id}"} class="shadow flex-col my-1 rounded-md p-2">
      <div class="px-2 mb-2 font-bold"><%= @note.user %></div>
      <p
        class={"px-2 text-wrap whitespace-pre-wrap #{@blur_style}"}
        style="will-change: filter"
        phx-no-format
      ><%= @note.content %></p>
      <div class="mt-5 flex justify-around">
        <%= live_patch to: Routes.meeting_show_path(@socket, :edit, @meeting, @note) do %>
          <span><%= Heroicons.icon("pencil", type: "outline", class: "h-5 w-5 stroke-1") %></span>
        <% end %>
        <%= link to: "#", phx_click: "delete", phx_value_id: @note.id, data: [confirm: "Are you sure?"] do %>
          <span><%= Heroicons.icon("trash", type: "outline", class: "h-5 w-5 stroke-1") %></span>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("delete", _, socket), do: {:noreply, socket}
end
