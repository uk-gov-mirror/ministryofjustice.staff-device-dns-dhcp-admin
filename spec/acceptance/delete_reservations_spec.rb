require "rails_helper"

describe "delete reservations", type: :feature do
  let(:reservation) do
    Audited.audit_class.as_user(editor) do
      create :reservation
    end
  end

  let(:subnet) { reservation.subnet }
  let(:editor) { create(:user, :editor) }

  before do
    login_as editor
  end

  it "delete an reservation" do
    visit "/subnets/#{subnet.to_param}"

    click_on "Delete"

    expect(page).to have_content("Are you sure you want to delete this reservation?")

    # expect_config_to_be_published
    # expect_service_to_be_rebooted

    click_on "Delete reservation"

    expect(page).to have_content("Successfully deleted reservation")
    expect(page).not_to have_content(reservation.hw_address)

    expect_audit_log_entry_for(editor.email, "destroy", "Reservation")
  end
end
