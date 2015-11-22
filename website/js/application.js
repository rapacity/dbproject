
//=============================================================================
//||                           Application                                   ||
//=============================================================================

var homepage = 'myalbums'


function initialize_screen() {
  $("#sidebar-search input").keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which);
      if (keycode == '13')
        search_photos_invoke();
    });
  $("#sidebar-search button").click(function () { 
      search_photos_invoke();
    });
}





// Frontpage  
// ----------------------------------------------------------------------------
function frontpage_screen(result) {
  $clear('main');
  $draw('main', $view('frontpage', result));
  $('#frontpage-search-photos-bar').keypress(function(event){
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if (keycode == '13') {
      $("#sidebar-search input").val($('#frontpage-search-photos-bar').val());
      search_photos_invoke();
      sidebar.sidebar('show');
    }
  });
}



function fix_trending_tags(tags) {
  for (var i = 0; i < tags.length; i++) {
    var str = tags[i].photo_id_and_code;
    var split = str.split(/ (.+)?/);
    tags[i].photo_id = split[0];
    tags[i].photo_code = split[1];
  }
}

function frontpage_request() {
  var trending_tags = request({method: 'trending_tags'})
  var top10_active_users = request({method: 'top10_active_users'})

  $.when(trending_tags, top10_active_users).then(function(trend_ret, top10) {
    var tags = trend_ret.tags;
    fix_trending_tags(tags);
    frontpage_screen({tags: tags, users: top10.users});
  });
}






//=============================================================================
//||                               S1                                        ||
//=============================================================================


// Register 
// ----------------------------------------------------------------------------
var register_fields = [
  "firstname",
  "lastname",
  "email",
  "birthday",
  "hometown",
  "gender",
  "password"
];

function register_request(data) {
  data.method = 'register';

  make_request(data,
    function (result) {
      $clear('main');
      $draw('main', $view('register-success'));
    },
    function (result) {
      form_error('email', 'The email already exists in the database');
    });
}

function register_screen() {
  fullscreen(true);
  $clear('main');
  $draw('main', $view('register'));
  $('form')
    .form({
      on: 'submit',
      inline: true,
      onSuccess: function() {
        register_request(serialize_form($('form'), register_fields));
        return false;
      },
      fields: {
        firstname: ['minLength[1]', 'maxLength[32]'],
        lastname: ['minLength[1]', 'maxLength[32]'],
        email: 'email',
        birthday: 'empty', 
        hometown: 'maxLength[200]',
        gender: 'empty',
        password: 'maxLength[129]'
      }
    })
  ;
}

// Login 
// ----------------------------------------------------------------------------

function login_request(email, pass) {
  make_request({method: 'login', email: email, password: pass},
    function (result) {
      storage.setItem('session', result.session[0].user_session);
      authenticate();
      route(homepage);
      sidebar.sidebar('show');
    },
    function (result) {
      if (result.method == 'AlreadyLoggedIn') {
        route(homepage);
      } else
        logout_request();
        form_error('email', 'Username and/or password invalid.');
    });
}


function login_screen() {
  fullscreen(true);
  $clear('main');
  $draw('main', $view('login'));

  // remember last email
  var lastlogin_email = storage.getItem('lastlogin_email')

  if (lastlogin_email !== undefined)
    $('form').form('set value', 'email', lastlogin_email);

  $('form')
    .form({
      on: 'submit',
      inline: true,
      onSuccess: function() {
        var $f = $('form');
        var email = $f.form('get value', 'email');
        var password = $f.form('get value', 'password');

        // remember last user email for autocomplete 
        storage.setItem('lastlogin_email', email)

        login_request(email, password);
        return false;
      },
      fields: {
        email: 'email',
        password: 'maxLength[129]'
      }
    })
  ;
}


// Logout 
// ----------------------------------------------------------------------------

function logout_request() {
  sidebar.sidebar('hide');
  unauthenticate();
}

function logout_screen() {
  fullscreen(true);
  $clear('main');
  $draw('main', $view('logout'))
  logout_request();
}


// Search users 
// ----------------------------------------------------------------------------
function members_screen() {
  $clear('main');
  $draw('main', $view('search-users-bar')); 
  $draw('main', $view('search-users-results')); 
  search_users_request({});

  $('input[name=search-users-bar]').keypress(debounce(function () {
    var str = $(this).val();
    search_users_request({name: str });
  }, 100));
}

function search_users_screen(data) {
  $('#search-users-results').replaceWith($view('search-users-results', data));
//  $draw('main', $view('search-users-results', data));
}


function search_users_request(data) {
  data.method = "search_users";
  data.name = data.name ? '%' + data.name + '%' : '%';

  make_request(data,
    function (result) {
      search_users_screen(result);
      console.log(result); 
    },
    function (result) {
      console.log(result); 
    });
}


// Add friend 
// ----------------------------------------------------------------------------
function add_friend_request(friend_id) {
  make_request({method: 'add_friend', friend_id: friend_id},
    function (result) {
      alert('Friend Added.');
    },
    function (result) {
      alert('Already a friend.');
    });
}

// List friends 
// ----------------------------------------------------------------------------
function list_friend_controller() {
  list_friend_request();
}

function list_friend_screen(results) {
  $clear('main');
  $draw('main', $view('list-friend', results));
}




function list_friend_request() {
  make_request({method: 'list_friend'},
    function (result) {
      list_friend_screen(result);
    },
    function (result) {
      route('frontpage'); /*alert('nay');*/
    });
}

// Search photos 
// ----------------------------------------------------------------------------
function photos_controller() {
  search_photos_request(0,'', [], []);
}

function results_controller() {
  $clear('main');
}

function search_photos_invoke() {
  var is_personal = personal_input_value();
  var filter = tags_list_filter().toArray();
  var exclude = tags_list_exclude().toArray();
  var caption = caption_input_value();
  route('results')
  $.when(account).then(function (acc) {
    var user_id = 0;
    if (acc.is_successful && is_personal)
      user_id = acc.account[0].user_id;
    search_photos_request(user_id, caption, filter, exclude);
  });
}

function search_photos_request(user_id, caption, filter, exclude) {
  var data = { }
  data.method = 'search_photos';
  data.user_id = user_id ? user_id : 0;
  data.album_id = 0
  data.include = '{' + filter.join(',') + '}';
  data.exclude = '{' + exclude.join(',') + '}';
  data.caption = caption !== undefined && caption !== '' ? '%' + caption + '%' : '%';

  make_request(data,
    function (result) {
      var photos = result.photos;
      for (var i = 0; i < photos.length; i++) {
        photos[i].photo_age = moment(photos[i].photo_creation).fromNow();
      }
      search_photos_screen(result);
    },
    function (result) {
    });
}


function search_photos_screen(result) {
  if (result.is_owner)
    set_owner();
  $clear('main');
  $draw('main', $view('view-photos', result));
//  var $container = $('.ui.gallery')
//  $container.imagesLoaded(function () {
//    $container.masonry({
//      transitionDuration: 0,
//      itemSelector : '.ui.card'
//    });
//  });

}








// View User Albums 
// ----------------------------------------------------------------------------

function view_user_albums_router() {
  if (arguments.length == 0) {
    account_either(
      function (acc) { view_user_albums_controller({user_id: acc.user_id}); },
      function () { route('frontpage'); /*alert('error, no album user id specified');*/ });
  } else {
    view_user_albums_controller({user_id: arguments[0]});
  }
}


function view_user_albums_controller(data) {
  view_user_albums_screen();

  $.when(account, view_user_albums_request(data)).done(function (acc, result) {
    if (result.is_successful) {
      var is_owner = acc.is_successful && acc.account[0].user_id == result.user[0].user_id;
      var albums = result.albums;

      for (var i = 0; i < albums.length; i++) {
        albums[i].album_age = moment(albums[i].album_creation).fromNow();
        albums[i].photos = albums[i].photo_codelist.split(',');
      }

      console.log(result);
      view_user_albums_screen(is_owner, result);
    } else {
      /*alert('error');*/
      console.log(result);  
    }
  });
}




function view_user_albums_request(data) {
  data.method = 'view_user_albums';
  return request(data);
}


var make_album_fields = [
  "album_name"
];



function view_user_albums_screen(is_owner, result) {
  if (is_owner)
    set_owner();

  $clear('main');
  $draw('main', $view('view-user-albums', result)); 

  $('form')
    .form({
      on: 'submit',
      inline: true,
      onSuccess: function() {
        make_album_request(serialize_form($('form'), make_album_fields));
        return false;
      },
      fields: {
        album_name: ['minLength[1]', 'maxLength[32]'],
      }
    });
}





function make_album_request(data) {
  data.method = 'make_album';
  make_request(data,
    function (result) {
      route('albums');
    },
    function (result) {
      form_error('album_name', 'An album with the same name already exists');
    });
}



function delete_photo(id) {
  var data = { };
  data.method = 'delete_photo';
  data.photo_id = id;
  $.when(request(data)).done(function () {
    route(getHash());
    //alert('photo has been deleted');
  });
}




function delete_album(id) {
  var data = { };
  data.method = 'delete_album';
  data.album_id = id;
  $.when(request(data)).done(function () {
    route('albums');
  });
}




function view_album_router() {
  if (arguments.length == 0) {
    alert('no album specified');
  } else {
    view_album_request(arguments[0]);
  }
}

function view_album_screen(result) {
  if (result.is_owner)
    set_owner();
  $clear('main');
  $draw('main', $view('view-album', result));
  $draw('main', $view('view-photos', result));

  $('#file-upload-dialog form')
     .form({
       on: 'submit',
       inline: true,
       onSuccess: function() {
         make_photo_request();
         return false;
       },
       fields: {
         photo_caption: ['minLength[0]', 'maxLength[1000]'],
       }
     })
   ;

  //$('.ui.gallery').masonry() //{transitionDuration: 0}).layout();
  //$('.ui.gallery').masonry() //{transitionDuration: 0}).layout();
  //var $container = $('.ui.gallery')//.masonry({transitionDuration: 0}).layout();
  //$container.imagesLoaded(function () {
  //  $container.masonry({
  //    transitionDuration: 0,
  //    itemSelector : '.ui.card'
  //  });
  //});

}


function view_album_request(id) {
  var data = { };
  data.method = 'view_album';
  data.album_id = id;
  $.when(account, request(data)).then(function (acc, res) {
    if (res.is_successful) {
      var photos = res.photos;
      for (var i = 0; i < photos.length; i++) {
        photos[i].photo_creation = moment(photos[i].photo_creation).fromNow();
      }

      if (acc.is_successful) 
         res.is_owner = acc.account[0].user_id == res.album[0].user_id;

      view_album_screen(res);
    } else {
      alert('you cannot access the ablum.');
    }
  })
}







// View Photo Result 
// ----------------------------------------------------------------------------










// View Photo 
// ----------------------------------------------------------------------------
//
var make_comment_fields = [
  "photo_id",
  "comment_body"
];



function view_photo_router() {
  if (arguments.length == 0) {
    alert('no album specified');
  } else {
    view_photo_request(arguments[0]);
  }
}

function view_photo_screen(result) {
  if (result.is_owner)
    set_owner();
  //fullscreen(true);
  $clear('main');
  $draw('main', $view('view-photo', result));
  console.log(result);
  //$('.ui.gallery').masonry() //{transitionDuration: 0}).layout();
  //$('.ui.gallery').masonry() //{transitionDuration: 0}).layout();
  
  $('.ui.reply.form')
    .form({
      on: 'submit',
      inline: true,
      onSuccess: function() {
        make_comment_request(serialize_form($('.ui.reply.form'), make_comment_fields));
        return false;
      },
      fields: {
        body: ['minLength[0]', 'maxLength[1000]'],
      }
    })
  ;

  $('.ui.tag.form')
    .form({
      on: 'submit',
      inline: true,
      onSuccess: function() {
        tag_photo_request(serialize_form($('.ui.tag.form'), ['tag_name','photo_id']));
        return false;
      },
      fields: {
        tag_name: ['minLength[0]', 'maxLength[1000]'],
      }
    })
  ;

}


function view_photo_request(id) {
  var data = { };
  data.method = 'view_photo';
  data.photo_id = id;
  $.when(account, request(data)).then(function (acc, res) {
    var photo = res.photo = res.photo[0];
    if (res.is_successful) {
       photo.photo_age = moment(photo.photo_creation).fromNow();
       if (acc.is_successful)
         res.is_owner = acc.account[0].user_id == photo.user_id;

       view_photo_screen(res);
    } else {
      alert('you cannot access the ablum.');
    }
  })
}



function make_comment_request(data) {
  data.method = 'make_comment';
  $.when(request(data)).then(function (res) {
    if (res.is_successful) {
      route(getHash());
    } else {
      alert('Error posting comment.');
    }
  });
}


function make_like_request(id) {
  var data = { }
  data.method = 'make_photo_like';
  data.photo_id = id;
  $.when(request(data)).then(function (res) {
    if (res.is_successful) {
      route(getHash());
    } else {
      //alert('Error liking photo.');
    }
  });
}





function tag_photo_request(data) {
  data.method = 'tag_photo';
  //data.photo_id = photo_id;
  //data.tag_name = tag_name;
  $.when(request(data)).then(function (res) {
    if (res.is_successful) {
      route(getHash());
    } else {
      //alert('Error liking photo.');
    }
  });
}


function untag_photo_request(photo_id, tag_id) {
  var data = { }
  data.method = 'untag_photo';
  data.photo_id = photo_id;
  data.tag_id = tag_id;
  $.when(request(data)).then(function (res) {
    if (res.is_successful) {
      route(getHash());
    } else {
      //alert('Error liking photo.');
    }
  });
}







function make_photo_request() {
  var fd = new FormData();
  fd.append("photo_file", $('input[name=photo_file]')[0].files[0]);
  fd.append("photo_caption", $('input[name=photo_caption]').val());
//  fd.append("photo_caption", $('textarea[name="photo_caption"]').val());
  fd.append("album_id", $('input[name=album_id]').val());
  fd.append("method", "make_photo");
  fd.append("session", storage.getItem('session'));

  $('#file-upload-dialog .dimmer').addClass('active')

  var req = $.ajax({
    url: "/request",
    type: "POST",
    data: fd,
    processData: false,
    contentType: false 
  });


  $.when(req).then(function (res) {
    $('#file-upload-dialog .dimmer').removeClass('active')
    route(getHash());
  })

}








function recommended_tags_request(photo_id) {
  return request({method: 'recommended_tags', photo_id: photo_id});
}

function recommended_photos_request() {
  return request({method: 'recommended_photos'});
}


function recommended_photos_controller() {
  $.when(recommended_photos_request()).then(function (result) {
    var photos = result.photos;
    for (var i = 0; i < photos.length; i++) {
      photos[i].photo_age = moment(photos[i].photo_creation).fromNow();
    }
    $clear('main');
    $draw('main', $view('view-photos', result));
  });
}



