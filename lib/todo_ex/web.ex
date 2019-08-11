defmodule TodoEx.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_args) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end

  post "/todo/:list_name/entries" do
    conn = fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list_name")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> TodoEx.Cache.server_process()
    |> TodoEx.Server.add_entry(%{title: title, date: date})

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end

  get "/todo/:list_name/entries" do
    conn = fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list_name")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> TodoEx.Cache.server_process()
      |> TodoEx.Server.entries(date)

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, formatted_entries)
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
