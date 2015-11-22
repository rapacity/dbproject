
var sidebar = null;


  var templates = $.ajax({
    url: '/templates.html',
    async: false
  }).responseText
  
  function $view(name, data) {
    data = typeof data !== 'undefined' ?  data : { };
    var template = $(templates).filter('#' + name).html();
    return Mustache.render(template, data);
  }
  
  function $clear(id) {
    $('#' + id).html('')
  }
  
  function $draw(id, obj) {
    $('#' + id).append(obj)
  }





function form_error(fieldname, error) {
  var field = $('input[name='+fieldname+']').closest(".field");
  field.addClass('error');
  field.append('<div class="ui basic red pointing prompt label transition visible">' + error + '</div>');
}

function fullscreen(bool) {
  if (bool) {
    $('body').addClass('fullscreen');
  } else {
    $('body').removeClass('fullscreen');
  }
}

function serialize_form(form, fields) {
  var ret = { };
  for (var i = 0; i < fields.length; i++)
    ret[fields[i]] = form.form('get value', fields[i]);
  return ret;
}

function icon(lst) {
  return ('<i class="' + Array.prototype.slice.call(arguments).join(" ") + ' icon"></i>');
}

function actualizeWhitespace(str) {
  return str.replace(/ /g, "&nbsp;")
            .replace(/\n/g, "<br>");
}

var statusdom = $("#status")

function error(title, errors) {
  $("#status").html($view("error", { title: title, errors: errors }));
  $("#status").show();
}

function loading() {
  $("#status").html($view("loading"));
  $("#status").show();
}

function done() {
  $("#status").html("")
  $("#status").hide()
}


var myaccount = { }
var storage = localStorage

function make_request(data, succ, fail) {
  data.session = storage.getItem('session')
  $.ajax({
     url: '/request',
     dataType: 'json',
     data: data,
     error: function () { error("Error", "Server communication failure."); },
     success: function (res) { if (res.status == "success") succ(res); else fail(res); },
     type: 'POST'
  });
}

function request(data) {
  data.session = storage.getItem('session')
  var defer =  $.ajax({
    url: '/request',
    dataType: 'json',
    data: data,
    type: 'POST'
  });

  var filtered = defer.pipe(function (result) {
    result.is_successful = true;

    if (result.method == "AlreadyLoggedIn") {
      authenticate();
    }

    if (result.status == "failure") {
      result.is_successful = false;
     
      if (result.method == "AuthenticationFailure") {
        logout_request();
      }
    }

    return result;
  });

  return filtered;
}

function preview(viewname) {
  $clear('main');
  $draw('main', $view(viewname));
}

var account = { };

function account_either(on_succ, on_fail) {
  $.when(account).then(function (acc) {
    if (acc.is_successful) {
      on_succ(acc.account[0]);
    } else {
      on_fail();
    }
  });
}

function not_found_screen() {
  $clear('main');
  $draw('main', $view('404'));
}

function request_account_info() {
  var tmp = request({method: 'account_info'});
  account = tmp;
  return tmp;
}

function set_notowner() {
  $('body').addClass('notowner-hide'); 
}

function set_owner() {
  $('body').removeClass('notowner-hide'); 
}

function render_registered_screen(account) {
  $('body').removeClass('unregistered-hide'); 
  $clear('navbar');
  $draw('navbar', $view('navbar-registered', {account: account}));
  sidebar_attach();
}

function render_anonymous_screen() {
  $('body').addClass('unregistered-hide'); 
  $clear('navbar');
  $draw('navbar', $view('navbar'));
  sidebar_attach();
}

function render_general_screen() {
  $.when(account).then(function (acc) {
    $clear('navbar');
    if (acc.is_successful) {
      render_registered_screen(acc.account[0]);
    } else {
      render_anonymous_screen();
    }
  });
}

function authenticate() {
  $.when(request_account_info()).then(function (result) {
    render_general_screen();
  });
}

function unauthenticate() {
  var tmp = $.Deferred();
  tmp.resolve({is_successful: false})
  account = tmp;
  storage.setItem('session', undefined);
  render_anonymous_screen();
}

function getHash() {
  return window.location.hash.substring(1);
}

function route(hash) {
  fullscreen(false);
  set_notowner();

  var method;
  var args   = hash.split('/');
  var target = args[0];
  args.shift();


  console.log(hash);
  console.log(args);

  if (!target) {
    method = router['frontpage'];
  } else {
    method = router[target];

    if (method === undefined) {
      hash = '404';
      args = [];
      method = not_found_screen;
    }
  }
  console.log(target);

  window.location.hash = '#' + hash;

  console.log(args);
  method.apply(this, args);
}



window.onpopstate = function(event) {
  route(getHash())
  console.log('pop: ' + getHash());
};

// https://davidwalsh.name/javascript-debounce-function 
// code from undrscore.js 
function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};


function initialize_sidebar() {
  sidebar =
    $('#sidebar')
     .sidebar({
        dimPage: false,
        closable: false,
        onVisible: function (e) {  storage.setItem('sidebar_open', 'true'); },
        onShow: function (e) {
         
          $('body').addClass('open-sidebar'); 
        },
        onHide: function (e) { storage.setItem('sidebar_open', 'false');  
                               $('body').removeClass('open-sidebar');
                               }
      });
}

function sidebar_attach() {
  sidebar.sidebar('attach events', '#sidebar-toggle');
}

// ----------------------------------------------------------------------------

function make_field_manipulator(field_name) {
  return function () {
    var field_selector = $('input[name=' + field_name + ']');
    if (arguments.length == 0) {
      return $(field_selector).val();
    } else {
      $(field_selector).val(arguments[0]);
    }
  };
}

var exclude_input_value = make_field_manipulator('tag_name_exclude');
var filter_input_value = make_field_manipulator('tag_name_filter');
var caption_input_value = make_field_manipulator('by_caption');

function personal_input_value() {
  return $('input[name=personal_only]').is(':checked');
}

function option_id(name) {  return 'tag_option_' + name; }

function tags_list(type) {
  return $("#tags_list_" + type).children().map(function () {
    return this.id.replace(/^tag_option_/, '')
  });
}

function tags_list_filter() { return tags_list('filter'); }

function tags_list_exclude() {  return tags_list('exclude'); }

function array_remove(needle, haystack) {
  return $.grep(haystack, function (value) {
    return value != needle; 
  });
}

function array_member(needle, haystack) {
  return $.inArray(needle, haystack) == -1
}


function make_sidebar_tag(type, tag_name) {
  $('#' + option_id(tag_name)).remove();

  var anchor = $('<a>', {
    class: 'ui label',
    id: option_id(tag_name),
    text: tag_name
  });

  var close_icon =  $('<i>', {
    class: 'icon close',
    click: function () {
      $(anchor).remove();
    }
  });

  anchor.append(close_icon)
  $('#tags_list_' + type).append(anchor);
}

function place_filter_tag(tag_name) {
  sidebar.sidebar('show');
  make_sidebar_tag('filter', tag_name);
  search_photos_invoke();
}

function add_filter_tag() {
  var tag_name = convert_to_tag(filter_input_value());
  if (tag_name) {
    filter_input_value('');
    make_sidebar_tag('filter', tag_name);
  } 
}


function add_exclude_tag() {
  var tag_name = convert_to_tag(exclude_input_value());
  if (tag_name) {
    exclude_input_value('');
    make_sidebar_tag('exclude', tag_name);
  } 
}

var tag_regex = /^[a-z][a-z0-9_]*$/;

function convert_to_tag(str) {
  str = str.toLowerCase().trim().replace(' ', '_');
  if (str.match(tag_regex))
    return str;

  if (str)
    alert('Not a valid tag.');
  
  return undefined;
}

// ----------------------------------------------------------------------------

$(function (){
  initialize_screen();
  initialize_sidebar();
  authenticate();

  var hash = window.location.hash.substring(1);
  route(hash); 

  if (storage.getItem('sidebar_open') === 'true') {
    $('#sidebar').addClass('visible').css('z-index', 0);
    $('body').addClass('open-sidebar');
  }
})

