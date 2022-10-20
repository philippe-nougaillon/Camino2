# app/controllers/sitemap_controller.rb

class SitemapController < ApplicationController

  skip_before_action :authorize, only: [:show]

  def show
    # e.g. @articles = Blog::Article.all
  end
end