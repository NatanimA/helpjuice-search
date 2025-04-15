class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to articles_path, alert: "Article not found"
  end
end
