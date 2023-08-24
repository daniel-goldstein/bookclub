defmodule BookclubWeb.LiveHelpers do
  import Phoenix.Component
  import Phoenix.HTML.Form

  alias Phoenix.LiveView.JS

  alias BookclubWeb.Router.Helpers, as: Routes

  alias Bookclub.OpenLibrary

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.election_index_path(@socket, :index)}>
        <.live_component
          module={BookclubWeb.ElectionLive.FormComponent}
          id={@election.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.election_index_path(@socket, :index)}
          election: @election
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in rounded-sm" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <.link id="close" patch={@return_to} class="phx-modal-close" phx-click="hide_modal()">
            ✖
          </.link>
        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  def my_label(assigns) do
    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    """
  end

  def input(%{type: "text"} = assigns) do
    assigns =
      assigns
      |> assign_new(:debounce, fn -> "" end)
      |> assign_new(:placeholder, fn -> "" end)

    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    <div class="mt-1 sm:mt-0 sm:col-span-2 relative rounded-md shadow-sm">
      <%= text_input(@f, @field,
        required: @required,
        autocomplete: true,
        "phx-debounce": @debounce,
        class: ["mt-1 block w-full shadow-sm sm:text-sm rounded-md"],
        placeholder: @placeholder
      ) %>
      <%= if @f.errors[@field] && @f.params[@field] do %>
        <.error_bang />
      <% end %>
    </div>
    """
  end

  def input(%{type: "number"} = assigns) do
    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    <div class="mt-1 sm:mt-0 sm:col-span-2 relative rounded-md shadow-sm">
      <%= number_input(@f, @field,
        required: @required,
        class: ["mt-1 block w-full shadow-sm sm:text-sm rounded-md"]
      ) %>
      <%= if @f.errors[@field] && @f.params[@field] do %>
        <.error_bang />
      <% end %>
    </div>
    """
  end

  def select(assigns) do
    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    <div class="mt-1 sm:mt-0 sm:col-span-2 relative rounded-md shadow-sm">
      <%= select(@f, @field, @choices,
        required: @required,
        class: ["mt-1 block w-full shadow-sm sm:text-sm rounded-md"]
      ) %>
    </div>
    """
  end

  def textarea(assigns) do
    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    <div class="mt-1 sm:mt-0 sm:col-span-2 relative rounded-md shadow-sm">
      <%= textarea(@f, @field,
        required: @required,
        class: ["mt-1 block w-full shadow-sm sm:text-sm rounded-md"]
      ) %>
      <%= if @f.errors[@field] && @f.params[@field] do %>
        <.error_bang />
      <% end %>
    </div>
    """
  end

  def date(assigns) do
    ~H"""
    <%= label(@f, @field, class: ["block text-sm font-medium text-gray-700"]) %>
    <div class="mt-1 sm:mt-0 sm:col-span-2 relative rounded-md shadow-sm">
      <%= date_input(@f, @field,
        required: @required,
        class: ["mt-1 block w-full shadow-sm sm:text-sm rounded-md"]
      ) %>
      <%= if @f.errors[@field] && @f.params[@field] do %>
        <.error_bang />
      <% end %>
    </div>
    """
  end

  def save(assigns) do
    assigns = assign_new(assigns, :text, fn -> "Save" end)

    ~H"""
    <button class="bg-blue-500 text-white rounded-md px-6 py-2">
      <%= @text %>
    </button>
    """
  end

  def error_bang(assigns) do
    ~H"""
    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
      <svg
        class="h-5 w-5 text-red-500"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        aria-hidden="true"
      >
        <path
          fill-rule="evenodd"
          d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
          clip-rule="evenodd"
        />
      </svg>
    </div>
    """
  end

  def book_search_results(assigns) do
    ~H"""
    <div id="search-results" class="relative max-h-96 mt-5 overflow-auto" phx-update="replace">
      <div class="grid divide-y">
        <%= if @bookshelf_results != [] do %>
          <div class="pt-6 pb-3">
            <span class="bold pl-1">From the Bookshelf</span>
          </div>
          <%= for {book, i} <- Enum.with_index(@bookshelf_results) do %>
            <div phx-click="pick" phx-value-book-idx={i} phx-target={@target}>
              <.book_search_result search_result={book} />
            </div>
          <% end %>
          <div class="pt-6 pb-3">
            <span class="bold pl-1">From OpenLibrary</span>
          </div>
        <% end %>
        <%= for {search_result, i} <- Enum.with_index(@search_results) do %>
          <div phx-click="pick" phx-value-search-idx={i} phx-target={@target}>
            <.book_search_result search_result={search_result} />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def book_search_result(assigns) do
    ~H"""
    <div class="cursor-pointer flex h-20 items-center">
      <div class="basis-1/6 w-full items-center">
        <%= if @search_result.cover_id do %>
          <img src={"https://covers.openlibrary.org/b/id/#{@search_result.cover_id}-S.jpg"} />
        <% end %>
      </div>
      <div class="basis-5/6 align-left flex-col items-center">
        <span>
          <%= @search_result.title %> | <i class="pl-1"><%= @search_result.author %></i>
        </span>
      </div>
    </div>
    """
  end

  def goodreads_link(assigns) do
    assigns = assign(assigns, :gr_link, OpenLibrary.goodreads_url(assigns.book))

    ~H"""
    <%= if @gr_link do %>
      <a id={"gr-link-#{@book.id}"} class="p-2" phx-hook="NestedClickable" href={@gr_link}>
        <img class="w-6 h-6" src={Routes.static_path(@socket, "/images/goodreads.png")} />
      </a>
    <% end %>
    """
  end

  def book_description_panel(assigns) do
    ~H"""
    <div
      class="panel"
      x-ref={"panel_#{@book.id}"}
      x-bind:style={"open ? 'max-height: ' + $refs.panel_#{@book.id}.scrollHeight + 10 + 'px; padding-top: 10px;' : ''"}
    >
      <div class="flex items-center mb-1">
        <h2 class="x-2/3 bold text-xl pr-2"><%= @book.title %></h2>
        <.goodreads_link book={@book} socket={@socket} />
      </div>
      <p class="mb-2"><%= @book.description %></p>
    </div>
    """
  end
end
