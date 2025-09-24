defmodule PdfGeneratorWeb.UserLive.Settings do
  use PdfGeneratorWeb, :live_view

  on_mount {PdfGeneratorWeb.UserAuth, :require_sudo_mode}

  alias PdfGenerator.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account settings</:subtitle>
        </.header>
      </div>

      <div class="mb-8">
        <div class="flex border-b border-gray-200">
          <.tab_button label="API" tab_name="api" current_tab={@current_tab} />
          <.tab_button label="Account" tab_name="account" current_tab={@current_tab} />
        </div>

        <div class="p-4">
          <%= if @current_tab == "api" do %>
            <div class="mb-8">
              <.button variant="primary" phx-click="show_api_modal">
                Generate API Token
              </.button>

              <%= if @show_api_modal do %>
                <div class="fixed inset-0 z-50 flex items-center justify-center" style="background-color: rgba(0, 0, 0, 0.5);" phx-click="close_api_modal">
                  <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4" phx-click="stop_propagation">
                    <h3 class="text-lg font-bold mb-4">API Token</h3>

                    <%= if @api_token do %>
                      <div class="mb-4">
                        <p class="text-sm text-gray-600 mb-2">Your new API token (copy it now, it won't be shown again):</p>
                        <div class="bg-gray-100 p-3 rounded border font-mono text-sm break-all select-all">
                          <%= @api_token %>
                        </div>
                      </div>
                      <div class="bg-yellow-50 border border-yellow-200 rounded p-3 mb-4">
                        <span class="text-sm text-yellow-800">⚠️ Make sure to copy this token now. You won't be able to see it again!</span>
                      </div>
                    <% else %>
                      <div class="mb-4">
                        <p class="text-sm text-gray-700 mb-3">Generate a new API token for accessing the PdfGenerator API programmatically.</p>

                        <div class="bg-blue-50 border border-blue-200 rounded p-4 mb-4">
                          <h4 class="text-sm font-semibold text-blue-900 mb-2">📋 Important Information</h4>
                          <ul class="text-sm text-blue-800 space-y-1">
                            <li>• <strong>Expires after:</strong> 1 year from creation</li>
                            <li>• <strong>Keep it secure:</strong> Treat this like a password</li>
                            <li>• <strong>One-time display:</strong> You won't be able to see it again</li>
                          </ul>
                        </div>

                        <div class="bg-red-50 border border-red-200 rounded p-4">
                          <h4 class="text-sm font-semibold text-red-900 mb-2">🚨 Your API token will be invalidated when you:</h4>
                          <ul class="text-sm text-red-800 space-y-1">
                            <li>• Change your account password</li>
                            <li>• Change your email address</li>
                            <li>• Delete your account</li>
                          </ul>
                          <p class="text-xs text-red-700 mt-2 italic">
                            Make sure to update any applications or scripts using this token when making account changes.
                          </p>
                        </div>
                      </div>
                    <% end %>

                    <div class="flex gap-2 justify-end">
                      <%= if @api_token do %>
                        <button
                          class="btn btn-primary"
                          id="copy-token-btn"
                          phx-hook="CopyToken"
                          data-token={@api_token}
                        >
                          Copy Token
                        </button>
                      <% else %>
                        <.button variant="primary" phx-click="generate_api_token">
                          Generate New Token
                        </.button>
                      <% end %>

                      <button class="btn btn-ghost" phx-click="close_api_modal">
                        Close
                      </button>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>

          <%= if @current_tab == "account" do %>
            <h3 class="text-xl font-semibold mb-4">Email Settings</h3>
            <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
              <.input
                field={@email_form[:email]}
                type="email"
                label="Email"
                autocomplete="username"
                required
              />
              <.button variant="primary" phx-disable-with="Changing...">Change Email</.button>
            </.form>

            <div class="divider" />

            <h3 class="text-xl font-semibold mb-4 mt-8">Password Settings</h3>
            <.form
              for={@password_form}
              id="password_form"
              action={~p"/app/users/update-password"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <input
                name={@password_form[:email].name}
                type="hidden"
                id="hidden_user_email"
                autocomplete="username"
                value={@current_email}
              />
              <.input
                field={@password_form[:password]}
                type="password"
                label="New password"
                autocomplete="new-password"
                required
              />
              <.input
                field={@password_form[:password_confirmation]}
                type="password"
                label="Confirm new password"
                autocomplete="new-password"
              />
              <.button variant="primary" phx-disable-with="Saving...">
                Save Password
              </.button>
            </.form>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/app/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:api_token, nil)
      |> assign(:show_api_modal, false)
      |> assign(:current_tab, "account") # Defaulting to "account" tab

    {:ok, socket}
  end

  @impl true
  def handle_event("show_api_modal", _params, socket) do
    {:noreply, assign(socket, :show_api_modal, true)}
  end

  def handle_event("generate_api_token", _params, socket) do
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    api_token = Accounts.create_user_api_token(user)

    socket =
      socket
      |> assign(:api_token, api_token)
      |> put_flash(:info, "API token generated successfully!")

    {:noreply, socket}
  end

  def handle_event("close_api_modal", _params, socket) do
    socket =
      socket
      |> assign(:api_token, nil)
      |> assign(:show_api_modal, false)

    {:noreply, socket}
  end

  def handle_event("stop_propagation", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("select_tab", %{"tab" => tab_name}, socket) do
    {:noreply, assign(socket, :current_tab, tab_name)}
  end

  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/app/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end

  # Private helper function for tab buttons
  defp tab_button(assigns) do
    ~H"""
    <button
      class={
        if @current_tab == @tab_name do
          "py-2 px-4 text-sm font-medium border-b-2 border-blue-500 text-blue-600"
        else
          "py-2 px-4 text-sm font-medium text-gray-500 hover:text-gray-700 hover:border-gray-300"
        end
      }
      phx-click="select_tab"
      phx-value-tab={@tab_name}
    >
      <%= @label %>
    </button>
    """
  end
end
