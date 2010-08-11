class DryFormsJsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory "public/javascripts"
      m.file "jquery.dry_forms.associations.js", "public/javascripts/jquery.dry_forms.associations.js"
    end
  end
end
