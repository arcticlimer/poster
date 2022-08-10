defmodule PosterWeb.CommentController do
  use PosterWeb, :controller

  alias Poster.Blog
  alias Poster.Blog.Comment

  action_fallback PosterWeb.FallbackController

  def index(conn, _params) do
    comments = Blog.list_comments()
    render(conn, "index.json", comments: comments)
  end

  def create(conn, %{"comment" => comment_params}) do
    with {:ok, post_id} <- Map.fetch(comment_params, "post_id"),
         post <- Blog.get_post!(post_id),
         {:ok, %Comment{} = comment} <- Blog.create_comment(comment_params, post) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.comment_path(conn, :show, comment))
      |> render("show.json", comment: comment)
    else
      :error ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: "post_id field not found"})
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Blog.get_comment!(id, [:post])
    render(conn, "show.json", comment: comment)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Blog.get_comment!(id, [:post])

    with {:ok, %Comment{} = comment} <- Blog.update_comment(comment, comment_params) do
      render(conn, "show.json", comment: comment)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Blog.get_comment!(id)

    with {:ok, %Comment{}} <- Blog.delete_comment(comment) do
      send_resp(conn, :no_content, "")
    end
  end
end