require "rails_helper"

describe "GET /zones", type: :feature do
  before do
    login_as User.create
  end

  it "lists zones" do
    zone = create :zone
    zone2 = create :zone, name: "test.example.com"

    visit "/zones"
    expect(page).to have_content zone.name
    expect(page).to have_content zone.forwarders.join(",")
    expect(page).to have_content zone.purpose

    expect(page).to have_content zone2.name
  end

  context "User with viewer permissions" do
    before do
      login_as User.create!(editor: false)
      create :zone
    end

    it "can see the zone management links" do
      visit "/zones"

      expect(page).to_not have_content "Create a new zone"
      expect(page).to_not have_content "Edit"
      expect(page).to_not have_content "Delete"
    end
  end

  context "User with editor permissions" do
    before do
      login_as User.create!(editor: true)
      create :zone
    end

    it "can see the zone management links" do
      visit "/zones"

      expect(page).to have_content "Create a new zone"
      expect(page).to have_content "Edit"
      expect(page).to have_content "Delete"
    end
  end
end
