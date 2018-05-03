defmodule FeedReader do
  @moduledoc """
  Doc for FeedReader
  """

  @aristegui_feed "https://aristeguinoticias.com/feed/"
  @item_xpath "//item"


  def consume do
    with {:ok, raw_body} <- download(@aristegui_feed),
      {:ok, xml_doc} <- FeedParser.read_xml(raw_body) do
        items = FeedParser.query_items(@item_xpath, xml_doc)
        Item.create(items)
    else
      error ->
        error
    end
  end

  @spec download(String.t) :: {:ok, String.t}
  def download(feed) do
    response = HTTPotion.get feed
   {:ok, response.body}
  end

end
