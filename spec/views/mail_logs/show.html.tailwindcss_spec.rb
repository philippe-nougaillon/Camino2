require 'rails_helper'

RSpec.describe "mail_logs/show", type: :view do
  before(:each) do
    assign(:mail_log, MailLog.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
