module DryForms 
  module BuilderAdditions
    helpers  = ActionView::Helpers::FormBuilder.field_helpers.dup
    helpers -= ['hidden_field', 'apply_form_for_options!', 'label', 'fields_for']
    helpers += %w(date_select datetime_select time_select collection_select select country_select time_zone_select)

    helpers.each do |name|
      define_method "custom_#{name}" do |attribute, *args|
        opts       = args.extract_options!
        label_text = opts.delete(:label_text)    || @object ? @object.class.human_attribute_name(attribute) : attribute.to_s.titleize
        label_opts = opts.delete(:label_options) || {}
        html_opts  = opts.delete(:html)          || {}
        html_opts[:class] = name

        label  = label attribute, label_text
        field  = send name, attribute, *(args << opts)
        
        DryForms.field_markup label, field, @object && @object.errors[attribute], html_opts
      end
    end

    def fields_for_association association, options = {}, &block
      association = association.to_s

      unless @object.respond_to? "#{association.pluralize}_attributes="
        raise NotImplementedError, "Please call `accepts_nested_attributes_for :#{association.pluralize}` in your `#{@object.class}` Model"
      end

      raise ArgumentError, "Missing block" unless block_given?

      association_class = @object.class.reflect_on_association(association.to_sym).klass
      singular_name     = association.singularize
      fields            = @object.send(association).map{ |obj| association_fields(association, obj, &block) }.join
      new_object        = @object.send(association).build options.delete(:default_attributes) || {}
      js_fields         = association_fields association, new_object, :child_index => "new_#{singular_name}", &block

      @template.concat <<-HTML
      <div id="#{association}">
        #{fields}
        #{@template.javascript_tag "var fields_for_#{singular_name} = '#{js_fields.strip.gsub /\n\s+|\n/, ''}';"}
        <a href="#" class="add_fields" data-association="#{singular_name}">#{I18n.t 'dry_forms.add', :model => association_class.human_name}</a>
      </div>
      HTML
    end
    
    def custom_fields_for *args, &block
      opts      = args.extract_options!
      html_opts = opts.delete(:html) || {}
      fields    = @template.capture{fields_for *(args << opts), &block}
      @template.concat DryForms.fields_for_markup(fields, html_opts) unless fields.empty?
    end

    private
    def association_fields association, object, opts = {}, &block
      opts.merge! :html => {:class => "associated", :'data-association' => association.singularize}
      
      fields = @template.capture do
        custom_fields_for association.to_sym, object, opts do |fields|
          @template.concat fields.hidden_field :_destroy, :class => 'destroy'
          yield fields
          @template.concat %{<a class="remove" href="#">#{I18n.t "dry_forms.remove"}</a>}
        end
      end
    end

    # def submit *args
    #   options         = args.extract_options!
    #   options[:class] = "submit #{ options[:class] }".strip
    #   value           = args.first || I18n.t(@object.new_record? ? 'create' : 'save', :scope => 'helpers.submit')
    #   super value, options
    # end
  end
end