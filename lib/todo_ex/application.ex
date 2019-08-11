defmodule TodoEx.Application do
  use Application

  def start(_type, _args) do
    TodoEx.System.start_link()
  end
end
