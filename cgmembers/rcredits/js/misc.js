function showMore(pgFactor) {
  more = true; 
  $('.showMore').css('visibility','hidden'); 
  page = Math.floor(page * pgFactor); 
  showPage(0);
}

function showPage(add) {
  page += add;
  var pghd = more ? '.PAGE-' : '.page-'; 
  $('.prevPage').css('visibility', page < 1 ? 'hidden' : 'visible'); 
  $('.nextPage').css('visibility', $(pghd + (page + 1)).length ? 'visible' : 'hidden'); 
  $('.txRow').hide(); 
  $('.txRow.head, ' + pghd + page).show();
}

function deleteCookie(name) {
  document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
}

function toggleFields(fields, show) {
  fields.split(' ').forEach(function(e) {$('.form-item-' + e).toggle(show); });
}

function toggle(field) {
  field = "#" + field;
  jQuery(field + "-YES, " + field + "-NO").toggle().toggleClass("visible invisible");
  jQuery(field).val(jQuery(field + "-YES").is(":visible"));
}

function commafy(n) {return isNaN(n) ? '0.00' : n.toLocaleString();}

jQuery("#which, #help").addClass("popup");
jQuery('button[type="submit"]').click(function() {
  this.form.opid.value = this.id;
//  $('<input type="hidden" name="opid" />').appendTo(this.form).val(this.form.id);
});

var page=0;
var more=false;
var indexZ = 2;
jQuery("#index a").mouseover(function() {
  var detail = jQuery("#" + this.id + "-detail");
  indexZ++;
  detail.css("zIndex", indexZ); // hiding the others fails here (as does detail.zIndex(indexZ))
  detail.show();
});
jQuery(".index-detail").click(function() {jQuery("#edit-acct-index, .index-detail").hide();});
jQuery(".noEdit").prev().attr("disabled", 1);

jQuery('[data-toggle="popover"][data-trigger="hover"]').popover(); 
jQuery('[data-toggle="popover"][data-trigger="click"]').popover(); 

var mobile = jQuery('.navbar-toggle').is(':visible');
jQuery('.submenu [data-toggle="popover"]').each(function(index) {
  jQuery(this).popover({
    html: true,
    content: function() {return jQuery(this).prev().html();},
    placement: (mobile ? 'left' : 'bottom')
  });
});
jQuery('#main .list-group-item.ladda-button').attr('data-spinner-color', '#191970').click(function() {
  jQuery(this).find('.glyphicon').css('color', 'white');
});
Ladda.bind('.ladda-button');
if (!mobile) jQuery('.navbar-nav > li > a').hover(function() {
  jQuery(this).popover('show');
  Ladda.bind('.ladda-button'); // these buttons are not available to Ladda until now
  // ('#' + jQuery(this).parent().parent().attr('id') + ' > li > a') doesn't work
  jQuery('.submenu > a').not(jQuery(this)).popover('hide');
});
if (!mobile) jQuery('form div').hover(function() {jQuery('* [data-toggle="popover"]').popover('hide');});

/**
 * post or get data to/from the server
 * @param string op: what to get
 * @param object data: parameters for the get
 * @param function success(jsonObject): what to do upon success (do nothing on failure)
 */
function get(op, data, success) {
  data = {op:op, sid:ajaxSid, data:data};
  jQuery.get(ajaxUrl, data, success);
}

function post(op, data, success) {
  data = {op:op, sid:ajaxSid, data:data};
  jQuery.post(ajaxUrl, data, success); // jQuery not $, because drupal.js screws it up on formVerify
}

function yesno(question, yes, no) {
  if (typeof no === 'undefined') no = (function() {});
  $.confirm({title: 'Yes or No', text: question, confirm: yes, cancel: no, confirmButton: 'Yes', cancelButton: 'No'});
}

function which(question, choices, choose, cancel) {
  $("#which").modal("show");
}

var yesSubmit = false; // set true when user confirms submission (or makes a choice)
var jForm; // jquery form object

function noSubmit() {
  $('.ladda-button').removeAttr('disabled').removeAttr('data-loading');
  $('#messages').hide();
}
function yesSubmit() {}

function who(form, id, question, amount, askGift) {
  jForm = $(form);
  if (yesSubmit) return true;
  get('who', {who:$(id).val(), question:question, amount:amount}, function(j) {
    if (j.ok) {
      if (j.who) {
        $(id).val(j.who);
        yesno(j.confirm, function() {
          {yesSubmit = true; jForm.submit();}
        }, noSubmit);
      } else which(jForm, id, j.title, j.which);
    } else {noSubmit(); $.alert(j.message);}
  });
  return false;
}

function which(jForm, id, title, body) {
  $('<div id="which">' + body + '</div>').dialog({
    title: title,
    modal: true,
    closeText: '&times;', // fails
    dialogClass: 'which'
  });
  $('.ui-dialog-titlebar-close').html('&times;');
  $('.ui-dialog-titlebar-close').click(function() {noSubmit();});
  $('#which option').click(function() {
    yesSubmit = true;
    $(id).val($(this).val());
    jForm.submit();
  });
}

function suggestWho(sel) {
  var members = new Bloodhound({
  //  datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    prefetch: {
      url: ajaxUrl + '?op=typeWho&data=&sid=' + ajaxSid,
      cache: false
    }
  /*  remote: {
      url: ajaxUrl + '?op=typeWho&data=%QUERY&sid=' + ajaxSid,
      wildcard: '%QUERY'
    } */
  });

  $(sel).wrap('<div></div>').typeahead(
    {
      minLength: 3,
      highlight: true
    },
    {
      name: 'rMembers',
  //    display: 'value',
      source: members
    }
  );
  /*$(sel).bind('typeahead:select', function(ev, suggestion) {
    console.log('Selection: ' + suggestion);
  }); */
}

var signoutWarning = 'You still there? (otherwise we\'ll sign you out, to protect your account)';

function sessionTimeout() {
  return setTimeout(function() {
    $.confirm({
      title:'Long Time No Click',
      text:signoutWarning,
      confirmButton:'Yes',
      cancelButtonClass:'hidden',
      confirm:function() {
        clearTimeout(sTimeout); // don't sign out
        $.get(ajaxUrl, {op:'refresh'}); // reset PHP garbage collection timer
        sTimeout = sessionTimeout(); // restart warning timer
      }
    });
    sTimeout = setTimeout(function() {location.href = signoutUrl;}, Math.max(1, signoutWarningAdvance - 10));
  }, sessionLife - signoutWarningAdvance);
}

function SelectText(element) { // from http://stackoverflow.com/questions/985272
  var doc = document;
  var text = doc.getElementById(element);
  var range, selection;
  if (doc.body.createTextRange) {
    range = doc.body.createTextRange();
    range.moveToElementText(text);
    range.select();
  } else if (window.getSelection) {
    selection = window.getSelection();        
    range = doc.createRange();
    range.selectNodeContents(text);
    selection.removeAllRanges();
    selection.addRange(range);
  }
}

var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-30262912-1']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
