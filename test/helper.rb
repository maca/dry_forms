require 'rubygems'
require 'test/unit'
require 'shoulda'

require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'

$LOAD_PATH.unshift "#{File.dirname __FILE__}/../lib"
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'dry_forms'
require 'support/models'

class ActionView::Base
  def protect_against_forgery?; end
end

require 'ostruct'

module ActionController::UrlFor
  def _routes
    helpers = OpenStruct.new
    helpers.url_helpers = Module.new
    helpers
  end
end
