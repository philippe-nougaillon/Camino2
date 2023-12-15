require 'rails_helper'

RSpec.describe "Admins", type: :request do
  describe "GET /stats" do
    it "returns http success" do
      get "/admin/stats"
      expect(response).to have_http_status(:success)
    end
  end

end
