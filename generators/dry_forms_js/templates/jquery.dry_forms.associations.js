// github.com/maca/dry_forms
(function(a){
  dryForms = {
    associations :  {
      removeAssociation : function(){
        var fieldset = $(this).closest('fieldset');
        fieldset.slideUp('slow').find('input.destroy').val('1');
        this.removeCallback(fieldset);
        return false;
      },

      addAssociation : function(){
        var link        = $(this);
        var association = link.attr('data-association');
        var new_id      = new Date().getTime();
        var regexp      = new RegExp('new_' + association, 'g');
        var fields      = $(eval('fields_for_' + association).replace(regexp, association + "_" + new_id)).hide();
        
        fields.find('a.remove').click(dryForms.associations.removeAssociation);
      
        link.before(fields);
        this.addCallback(fields);
        fields.slideDown('slow');
        return false;
      }
    }
  };
  
  $.fn.createAssociation = function(opts){
    var defaults = {
      addCallback : function(){},
      removeCallback : function(){}
    };
    $.extend(defaults, opts || {});
    $('fieldset[data-association] a.remove').click(dryForms.associations.removeAssociation);
    
    return this.each(function(){
      $(this).click(dryForms.associations.addAssociation);
      $.extend(this, defaults);
    });
  };
})(jQuery);


// This may go in application.js
jQuery(function(){
  $('.add_fields').createAssociation();
});
