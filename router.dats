// ----------------------------------------------------------------------------
val method = case+ method_name of
// ----------------------------------------------------------------------------
|  "register"            =>  register_request
|  "login"               =>  login_request
|  "search_users"        =>  search_users_request
|  "add_friend"          =>  add_friend_request
|  "list_friend"         =>  list_friend_request
|  "view_user_albums"    =>  view_user_albums_request
|  "view_album"          =>  view_album_request
|  "view_photo"          =>  view_photo_request
|  "make_album"          =>  make_album_request
|  "make_photo"          =>  make_photo_request
|  "delete_album"        =>  delete_album_request
|  "delete_photo"        =>  delete_photo_request
|  "search_photos"       =>  search_photos_request
|  "tag_photo"           =>  tag_photo_request
|  "untag_photo"         =>  untag_photo_request
|  "make_comment"        =>  make_comment_request
|  "make_photo_like"     =>  make_photo_like_request
|  "account_info"        =>  account_info_request
|  "trending_tags"       =>  trending_tags_request
|  "top10_active_users"  =>  top10_active_users_request
|  "recommended_photos"  =>  recommended_photos_request
|  "recommended_tags"    =>  recommended_tags_request
// ----------------------------------------------------------------------------
| _ => method_not_found
// ----------------------------------------------------------------------------
