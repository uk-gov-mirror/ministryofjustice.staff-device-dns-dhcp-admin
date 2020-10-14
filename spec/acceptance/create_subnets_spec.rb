require "rails_helper"

describe "create subnets", type: :feature do
  let(:editor) { User.create!(editor: true) }

  before do
    login_as editor
  end


  it "creates a new subnet" do
    site = create :site
    visit "/sites/#{site.to_param}"

    click_on "Create a new subnet"

    expect(current_path).to eql("/sites/#{site.to_param}/subnets/new")

    fill_in "CIDR block", with: "10.0.1.0/24"
    fill_in "Start address", with: "10.0.1.1"
    fill_in "End address", with: "10.0.1.255"

    click_button "Create"

    expect(current_path).to eq("/sites/#{site.to_param}")

    expect(page).to have_content("10.0.1.0/24")
    expect(page).to have_content("10.0.1.1")
    expect(page).to have_content("10.0.1.255")

    click_on "Audit log"

    expect(page).to have_content("#{editor.id}")
    expect(page).to have_content("create")
    expect(page).to have_content("Subnet")
  end

  it "displays error if form cannot be submitted" do
    site = create :site
    visit "/sites/#{site.to_param}"

    click_on "Create a new subnet"

    fill_in "CIDR block", with: "a"
    fill_in "Start address", with: "b"
    fill_in "End address", with: "c"

    click_button "Create"

    expect(page).to have_content "There is a problem"
  end
end
