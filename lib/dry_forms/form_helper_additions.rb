module DryForms
  module FormHelperAdditions
    def custom_form_for *args, &block
      concat capture{form_for *args, &block}
    end
  end
end