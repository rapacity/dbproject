//=============================================================================
//||                             Router                                      ||
//=============================================================================


var router = {
  frontpage: frontpage_request,
  register: register_screen,
  login: login_screen,
  logout: logout_screen,
  members: members_screen,
  friends: list_friend_controller,
  photos: photos_controller,
  albums: view_user_albums_router,
  user: view_user_albums_router,
  myalbums: view_user_albums_router,
  album: view_album_router,
  photo: view_photo_router,
  recommendations: recommended_photos_controller,
  results: results_controller
};




