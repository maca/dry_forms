$LOAD_PATH.unshift File.dirname(__FILE__)

require 'dry_forms/builder_additions'
require 'dry_forms/form_helper_additions'

module DryForms
  class << self
    def field_markup label, field, errors = nil, opts = {}
      unless errors.blank?
        error_explanation  = %{ <span class="errors">#{ [*errors].to_sentence }</span>} 
        opts[:class]       = "#{ opts[:class] } with_errors".strip
      end
      attributes = opts.map{|k,v| %{#{k}="#{v}"} }.join(' ')
    
      <<-HTML
      <dl #{attributes}>
        <dt>#{label}#{error_explanation}</dt>
        <dd>#{field}</dd>
      </dl>
      HTML
    end
  
    def fields_for_markup fields, opts = {}
      attributes = opts.map{|k,v| %{#{k}="#{v}"} }.join(' ')
      <<-HTML
      <fieldset #{ attributes }>
        #{fields}
      </fieldset>
      HTML
    end
  end
end

ActionView::Helpers::FormBuilder.send :include, DryForms
ActionView::Helpers::FormBuilder.send :include, DryForms::BuilderAdditions
ActionView::Helpers::FormHelper.send  :include, DryForms::FormHelperAdditions
