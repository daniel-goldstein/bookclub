defmodule Bookclub.OpenLibrary do
  defp strip_prefix(s, prefix) do
    base = String.length(prefix)
    String.slice(s, base..-1)
  end

  def search_open_library(search_terms) do
    fields = ["title", "author_name", "key", "cover_i"]

    query_string =
      %{
        q: search_terms |> String.replace(" ", "+"),
        _spellcheck_count: "0",
        mode: "everything",
        fields: Enum.join(fields, ","),
        limit: "10"
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

  def get_open_library_work_data(%{olid: olid}) do
    url = "https://openlibrary.org/works/#{olid}/editions.json"

    with {:ok, res} <- HTTPoison.get(url),
         {:ok, json} <- Jason.decode(res.body) do
      %{
        description:
          find_work_data(
            json,
            "description",
            &extract_description/1
          ),
        goodreads_id:
          find_work_data(
            json,
            "identifiers",
            &extract_goodreads_id/1
          )
      }
    end
  end
end
