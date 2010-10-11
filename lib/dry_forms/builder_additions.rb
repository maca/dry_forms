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
        html_opts[:class] = "#{name} #{html_opts[:class]}".strip

        label  = label attribute, label_text
        field  = send name, attribute, *(args << opts)
        
        errors =      
        if @object and name == 'file_field' # Not specked, for paperclip
          %w(file_name content_type file_size).map { |f| @object.errors["#{attribute}_#{f}".to_sym] }.unshift @object.errors[attribute]
        elsif @object
          @object.errors[attribute]
        end
        
        ActiveSupport::SafeBuffer.new DryForms.field_markup(label, field, [*errors].compact, html_opts)
      end
    end

    def fields_for_association association, *args, &block
      options     = args.extract_options!
      association = association.to_s
      objects     = args.first ? [*args.first] : @object.send(association)
      html        = options.delete(:html)

      unless @object.respond_to? "#{association.pluralize}_attributes="
        raise NotImplementedError, "Please call `accepts_nested_attributes_for :#{association.pluralize}` in your `#{@object.class}` Model"
      end

      raise ArgumentError, "Missing block" unless block_given?

      association_class = @object.class.reflect_on_association(association.to_sym).klass
      singular_name     = association.singularize
      fields            = objects.map{ |obj| association_fields(association, obj, :html => html, &block) }.join
      new_object        = @object.send(association).build options.delete(:default_attributes) || {}
      js_fields         = association_fields association, new_object, :child_index => "new_#{singular_name}", :html => html, &block

      association_fields = <<-HTML
      <div id="#{association}">
        #{fields}
        #{@template.javascript_tag "var fields_for_#{singular_name} = '#{js_fields.strip.gsub /\n\s+|\n/, ''}';"}
        <a href="#" class="add_fields" data-association="#{singular_name}">#{I18n.t 'add', :model => association_class.human_name}</a>
      </div>
      HTML

      @template.concat ActiveSupport::SafeBuffer.new association_fields
    end
    
    def custom_fields_for *args, &block
      opts      = args.extract_options!
      html_opts = opts.delete(:html) || {}
      fields    = @template.capture{fields_for *(args << opts), &block}
      @template.concat ActiveSupport::SafeBuffer.new DryForms.fields_for_markup(fields, html_opts) unless fields.empty?
    end

    private
    def association_fields association, object, opts = {}, &block
      html = opts.delete(:html) || {}
      opts.merge! :html => html.merge(:class => "associated", :'data-association' => association.singularize)
      
      association_fields = @template.capture do
        custom_fields_for association.to_sym, object, opts do |fields|
          @template.concat fields.hidden_field :_destroy, :class => 'destroy'
          yield fields
          @template.concat ActiveSupport::SafeBuffer.new %{<a class="remove" href="#">#{I18n.t "remove"}</a>}
        end
      end

      ActiveSupport::SafeBuffer.new %{#{association_fields}}
    end
  end
end
