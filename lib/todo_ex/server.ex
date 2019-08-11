defmodule TodoEx.Server do
  require Logger
  use GenServer, restart: :temporary
  alias TodoEx.{Database, ProcessRegistry}

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(%{name: name}) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    ProcessRegistry.via_tuple({__MODULE__, name})
  end

  @impl GenServer
  def init(name) do
    Logger.info("Starting to-do server.")
    {:ok, {name, nil}, {:continue, :init_by_name}}
  end

  @impl GenServer
  def handle_continue(:init_by_name, {name, _list}) do
    todo_list = Database.get(name) || TodoEx.List.new()

    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast(request, {name, todo_list}) do
    new_state = process_message(todo_list, request)
    Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    entries = TodoEx.List.entries(todo_list, date)
    {:reply, entries, {name, todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call(request, _from, {name, todo_list}) do
    new_state = process_message(todo_list, request)
    Database.store(name, new_state)
    {:reply, new_state, {name, new_state}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, state = {name, _}) do
    Logger.info("Stopping to-do server for #{name}")
    {:stop, :normal, state}
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoEx.List.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoEx.List.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, id}) do
    TodoEx.List.delete_entry(todo_list, id)
  end

  defp process_message(todo_list, {:clear_entries}) do
    TodoEx.List.clear_entries(todo_list)
  end

  defp process_message(todo_list, unknown_message) do
    Logger.warn("There is no handler for message: #{unknown_message}!")
    todo_list
  end

  # Client API
  def add_entry(server, new_entry = %{}) do
    GenServer.call(server, {:add_entry, new_entry})
  end

  def update_entry(server, entry = %{}) do
    GenServer.call(server, {:update_entry, entry})
  end

  def delete_entry(server, id) do
    GenServer.cast(server, {:delete_entry, id})
  end

  def entries(server, date) do
    GenServer.call(server, {:entries, date})
  end

  def clear_entries(server) do
    GenServer.call(server, {:clear_entries})
  end
end
