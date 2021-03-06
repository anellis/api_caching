require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should not be making api call on second profile request" do
    get :show, username: "anellis"
    profile = Profile.find_by_username("anellis")
    assert_equal "Durham, NC", profile.location
    profile.update(location: "Michigan")
    get :show, username: "anellis"
    assert_select 'p', "Michigan"
  end

  test "should not be making api call on second repository request" do
    get :show, username: "anellis"
    assert_equal "CSS", Repository.first.language
    Repository.first.update(language: "Grecian Java")
    get :show, username: "anellis"
    assert_select 'a', "Grecian Java"
  end

  test "expired repository cache should generate a new one" do
    get :show, username: "anellis"
    repository= Repository.first
    repository.update(updated_at: Time.now- 3.hours)
    Repository.first.update(language: "Grecian Java")
    get :show, username: "anellis"
    assert_select 'a', "CSS"
  end

  test "expired profile cache should generate a new one" do
    get :show, username: "anellis"
    profile = Profile.find_by_username("anellis")
    profile.update(location: "Michigan")
    profile.update(updated_at: Time.now- 2.days)
    get :show, username: "anellis"
    assert_select 'p', "Durham, NC"
  end

end
