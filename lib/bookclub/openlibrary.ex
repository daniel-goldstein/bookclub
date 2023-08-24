defmodule Bookclub.OpenLibrary do
  def search_open_library(search_terms) do
    fields = ["title", "author_name", "key", "cover_i"]

    query_string =
      %{
        q: search_terms |> String.replace(" ", "+"),
        _spellcheck_count: "0",
        mode: "everything",
        fields: Enum.join(fields, ","),
        limit: "20"
      }
      |> Enum.map(fn {k, v} -> to_string(k) <> "=" <> v end)
      |> Enum.join("&")

    url = "https://openlibrary.org/search.json?#{query_string}"

    with {:ok, res} <- HTTPoison.get(url),
         {:ok, json} <- Jason.decode(res.body) do
      suggestions =
        json["docs"]
        |> Enum.map(fn book ->
          %{
            title: book["title"],
            author: Map.get(book, "author_name", []) |> Enum.join(","),
            cover_id: Map.get(book, "cover_i", nil),
            olid: book["key"] |> strip_prefix("/works/")
          }
        end)

      {:ok, suggestions}
    end
  end

  def get_open_library_work_data(%{olid: olid}) do
    url = "https://openlibrary.org/works/#{olid}/editions.json"

    with {:ok, res} <- HTTPoison.get(url),
         {:ok, json} <- Jason.decode(res.body) do
      isbn = find_lowest_isbn_13(json)

      %{
        description:
          find_work_data(
            json,
            "description",
            &extract_description/1
          ),
        goodreads_id: find_goodreads_id(json, isbn),
        isbn: isbn
      }
    end
  end

  def goodreads_url(%{goodreads_id: goodreads_id, isbn: isbn}) do
    cond do
      goodreads_id -> "https://www.goodreads.com/book/show/#{goodreads_id}"
      isbn -> "https://www.goodreads.com/search?q=#{isbn}"
      true -> nil
    end
  end

  defp strip_prefix(s, prefix) do
    base = String.length(prefix)
    String.slice(s, base..-1)
  end

  defp find_work_data(editions_json, key, extractor) do
    maybe_res =
      editions_json["entries"]
      |> Enum.find(nil, &Map.get(&1, key))

    case maybe_res do
      nil -> nil
      res -> extractor.(res[key])
    end
  end

  defp extract_description(desc) do
    cond do
      is_map(desc) -> desc["value"]
      true -> desc
    end
  end

  defp extract_goodreads_id(ids) do
    ids
    |> Map.get("goodreads", [nil])
    |> List.first()
  end

  defp find_goodreads_id(entries_json, isbn) do
    case find_work_data(entries_json, "identifiers", &extract_goodreads_id/1) do
      nil -> find_goodreads_id_through_isbn_search_redirect(isbn)
      gr_id -> gr_id
    end
  end

  def find_goodreads_id_through_isbn_search_redirect(isbn) do
    case HTTPoison.get("https://www.goodreads.com/search?q=#{isbn}") do
      {:ok, resp} ->
        resp.headers
        |> Enum.find_value(fn header ->
          case header do
            {"Location", url} -> url
            _ -> nil
          end
        end)
        |> String.split("/")
        |> List.last()

      _ ->
        nil
    end
  end

  defp find_lowest_isbn_13(entries_json) do
    entries_json["entries"]
    |> Enum.flat_map(&Map.get(&1, "isbn_13", []))
    |> Enum.flat_map(fn isbn_str ->
      case Integer.parse(isbn_str) do
        {n, _} ->
          digits = Integer.digits(n)
          if List.first(digits) == 9 and length(digits) == 13, do: [n], else: []

        :error ->
          []
      end
    end)
    |> Enum.min(fn -> nil end)
  end
end
