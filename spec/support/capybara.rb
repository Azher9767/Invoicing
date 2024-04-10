require 'capybara/rspec'

Capybara.default_driver = :selenium
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1280,800')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5 # Set max wait time for asynchronous processes to finish
