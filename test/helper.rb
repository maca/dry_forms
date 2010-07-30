require 'rubygems'
require 'test/unit'
require 'shoulda'

require 'active_support'
require 'action_pack'
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'
require 'action_controller/test_process'

$LOAD_PATH.unshift "#{File.dirname __FILE__}/../lib"
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'dry_forms'
require 'support/models'

ActionController::Base.view_paths << FIXTURES = "#{ File.dirname __FILE__ }/fixtures'"

class ActionView::TestCase::TestController
  attr_reader :url_for_options
  def url_for(options)
    @url_for_options = options
    "/do"
  end
end

class ActionView::Base
  def protect_against_forgery?; end
end

