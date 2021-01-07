require "rails_helper"

describe "delete subnets", type: :feature do
  let(:subnet) do
    Audited.audit_class.as_user(editor) do
      create(:subnet, :with_reservation, :with_option)
    end
  end

  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete a subnet" do
    visit "/sites/#{subnet.site.to_param}"

    within_table "List of subnets" do
      byebug
      click_on "Delete"
    end

    expect(page).to have_content("Are you sure you want to delete this subnet?")

    expect_config_to_be_verified
    expect_config_to_be_published
    expect_service_to_be_rebooted

    click_on "Delete subnet"

    expect(page).to have_content("Successfully deleted subnet")
    expect(page).not_to have_content(subnet.cidr_block)

    expect_audit_log_entry_for(editor.email, "destroy", "Subnet")
  end
end
