# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# To remove field_with_errors div which get attached to the form when validation error occurs
# https://coderwall.com/p/s-zwrg/remove-rails-field_with_errors-wrapper
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe
end
