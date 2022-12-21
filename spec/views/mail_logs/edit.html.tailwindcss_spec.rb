require 'rails_helper'

RSpec.describe "mail_logs/edit", type: :view do
  let(:mail_log) {
    MailLog.create!()
  }

  before(:each) do
    assign(:mail_log, mail_log)
  end

  it "renders the edit mail_log form" do
    render

    assert_select "form[action=?][method=?]", mail_log_path(mail_log), "post" do
    end
  end
end
