class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:welcome]
  def welcome
  end
end
