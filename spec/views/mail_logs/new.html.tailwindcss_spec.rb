require 'rails_helper'

RSpec.describe "mail_logs/new", type: :view do
  before(:each) do
    assign(:mail_log, MailLog.new())
  end

  it "renders new mail_log form" do
    render

    assert_select "form[action=?][method=?]", mail_logs_path, "post" do
    end
  end
end
