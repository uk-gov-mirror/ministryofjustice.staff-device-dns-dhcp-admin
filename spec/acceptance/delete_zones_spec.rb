require "rails_helper"

describe "delete zones", type: :feature do
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete a zone" do
    zone = Audited.audit_class.as_user(editor) { create(:zone) }

    visit "/dns"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this zone?")

    click_on "Delete zone"

    expect(current_path).to eq("/dns")
    expect(page).to have_content("Successfully deleted zone")
    expect(page).not_to have_content(zone.name)

    click_on "Audit log"

    expect(page).to have_content(editor.email)
    expect(page).to have_content("destroy")
    expect(page).to have_content("Zone")
  end
end
