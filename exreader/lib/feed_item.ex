defmodule Item do
  @moduledoc """
  Reader item struct
  """

  defstruct [:link, :title]
  @type t :: %Item{link: String.t(), title: String.t()}


  @link_xpath "@link"
  @title_xpath "@title"

  @spec create([tuple()]) :: [%Item{}]
  def create(items) do
    Enum.map(items, fn(item) ->
      link = FeedParser.query_content(@link_xpath, item)
      title = FeedParser.query_content(@title_xpath, item)
      new(title, link)
    end)
  end

  def new(link, title) do
    %Item{link: link, title: title}
  end
end
