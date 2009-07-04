require 'test/test_helper'

class DeadCode < OldYeller::Test

  # Define the parameters for your actions or controllers
  #
  # action :blogs, :index, :date => "2009-02"
  # controller :comments, :blog_id => 42

  # Determine which actions or controllers should be excluded from testing.
  # Remember that code that shows up as dead might actually be live if it
  # is used in an excluded action
  #
  # exclude_controller "quotes"
  # exclude_action :users, :legacy

  # generates the tests from the routes
  detect_dead_code

end
