require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test 'expect home page' do
    get :home
    assert_response :success
  end

end
