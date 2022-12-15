require 'rails_helper'

RSpec.describe "mail_logs/index", type: :view do
  before(:each) do
    assign(:mail_logs, [
      MailLog.create!(),
      MailLog.create!()
    ])
  end

  it "renders a list of mail_logs" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
  end
end
