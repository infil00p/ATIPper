// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var sendRequests = function(evt)
{
  console.log('inside method');
  var token = $('#form_token')[0].value;
  $('.request_box').each(function(i, ele) {
    var id = ele.id.split('_')[1];
    if(ele.checked == true)
    {
      jQuery.ajax({
        "type" : "PUT",
        "url" : "/requests/" + id,
        "data" : { "setOrder" : true, "authenticity_token" : token },
        "success" : function(resp) 
        {
          console.log('win');
        }
      });
    }
  });
  return false;
}

$('#add_requests').bind('onclick', function(evt) { console.log('foo'); return sendRequests(evt);} );

