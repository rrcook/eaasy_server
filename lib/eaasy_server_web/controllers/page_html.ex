defmodule EaasyServerWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.
  """
  use EaasyServerWeb, :html

  embed_templates "page_html/*"
end
