
#define :: list_vt_cons
#define nil list_vt_nil()



//  Form Validation Field Rules 
// ----------------------------------------------------------------------------
val rfirstname  = in_range(1, 32)
val rlastname   = in_range(1, 32)
val remail      = is_email * in_range(1, 128)
val rbirthday   = is_date
val rhometown   = in_range(0, 200)
val rgender     = is_gender
val rpassword   = in_range(0, 128)

         

//=============================================================================
//||                              S1                                         ||
//=============================================================================


// Create a new user 
// ----------------------------------------------------------------------------
val register_form =
    checkp("firstname", rfirstname)
>=> checkp("lastname", rlastname)
>=> checkp("email", remail)
>=> checkp("birthday", rbirthday)
>=> checkp("hometown", rhometown)
>=> checkp("gender", rgender)
>=> checkp("password", rpassword)

val register_controller = 
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val successful = 
      (make_user(r.db, p["firstname"], p["lastname"], p["email"],
                       p["birthday"], p["hometown"], p["gender"],
                       p["password"], "elliot.png"))
                  .map(lam result => result.command_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else
      MakeBadRequest(request)
  end) : Controller
   
val register_request =
    ensure_not_loggedin
>=> register_form
>=> register_controller
    

// Login with created user 
// ----------------------------------------------------------------------------
val login_form =
    checkp("email", remail)
>=> checkp("password", rpassword)

val login_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val result = user_login(r.db, p["email"], p["password"])
    prval () = fold@(request)
  in
    if result.count() = 1 then
      MakeGoodRequest(request, Direct(
        KRM("session", result, asObjects) ::
        nil))
    else let
      val () = free(result)
    in
      MakeBadRequest(request, LoginFailed())
     end
  end) : Controller

val login_request = 
    ensure_not_loggedin
>=> login_form
>=> login_controller



// Search for other users 
// ----------------------------------------------------------------------------
val search_users_form =
    checkp("name", in_range(0, 100))

val search_users_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val result = find_users(r.db, p["name"])
    prval () = fold@(request)
  in
    MakeGoodRequest(request, Direct(
      KRM("users", result, asObjects) ::
      nil))
  end) : Controller

val search_users_request =
    search_users_form
>=> search_users_controller

// Add a user as a friend 
// ----------------------------------------------------------------------------
val add_friend_form =
    checkp("friend_id", is_int)    

val add_friend_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val s = (r.session) : dict
    val () = println!("user's id is = ", s["user_id"])
    val successful =
      (add_friend(r.db, s["user_id"], p["friend_id"]))
       .map(lam result => result.command_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else   
      MakeBadRequest(request)
  end) : Controller

val add_friend_request =
    ensure_loggedin
>=> add_friend_form
>=> add_friend_controller


// List the friends 
// ----------------------------------------------------------------------------
val list_friend_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val s = (r.session) : dict
    val result = get_user_friends(r.db, s["user_id"])
    prval () = fold@(request)
  in
    if result.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("users", result, asObjects) ::
        nil))
    else let
      val () = free(result)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val list_friend_request =
    ensure_loggedin
>=> list_friend_controller


// Top 10 Active Users
// ----------------------------------------------------------------------------
val top10_active_users_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val users = top10_active_users(r.db)
    prval () = fold@(request)
  in
    if users.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("users", users, asObjects) ::
        nil))
    else let
      val () = free(users)
    in
      MakeBadRequest(request)
    end
  end) : Controller


val top10_active_users_request =
    top10_active_users_controller 


//=============================================================================
//||                              S2                                         ||
//=============================================================================


// View User's Albums 
// ----------------------------------------------------------------------------
val view_user_albums_form =
  checkp("user_id", is_int)

val view_user_albums_controller = 
   (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val user_id = p["user_id"]
    val user_info = get_user(r.db, user_id)
    val album_info = get_user_albums(r.db, user_id) 
    prval () = fold@(request)
  in
    if user_info.count() = 1 then
      MakeGoodRequest(request, Direct(
        KRM("user", user_info, asObjects) ::
        KRM("albums", album_info, asObjects) ::
        nil))
    else let
      val () = free(user_info)
      val () = free(album_info)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val view_user_albums_request =
    view_user_albums_form
>=> view_user_albums_controller


// List All User Albums 
// ----------------------------------------------------------------------------
//val list_albums_form =
//  checkp("user_id", is_int)

val list_user_albums_controller = 
   (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val albums = query(r.db, "SELECT * FROM album_detail")
    prval () = fold@(request)
  in
    if albums.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("albums", albums, asObjects) ::
        nil))
    else let
      val () = free(albums)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val view_user_albums_request =
//    view_user_albums_form
    view_user_albums_controller




// View Album 
// ----------------------------------------------------------------------------
val view_album_form =
  checkp("album_id", is_int)

val view_album_controller = 
   (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
//    val user_info = basic_user_info(r.db, user_id)
    val album_info = get_album(r.db, p["album_id"]) 
    val album_photos = get_album_photos(r.db, p["album_id"])
    prval () = fold@(request)
  in
    if album_photos.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("photos", album_photos, asObjects) ::
        KRM("album", album_info, asObjects) ::
        nil))
    else let
      val () = free(album_photos)
      val () = free(album_info)
    in
      MakeBadRequest(request)
    end
  end) : Controller


val view_album_request =
    view_album_form
>=> view_album_controller




// View Photo 
// List photo's comments 
// ----------------------------------------------------------------------------
val view_photo_form =
    checkp("photo_id", is_int)

val view_photo_controller =
   (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val likes = get_photo_likes(r.db, p["photo_id"])
    val photo = get_photo(r.db, p["photo_id"])
    val recommended_tags = recommended_tags(r.db, s["user_id"], p["photo_id"])
    val tags = get_photo_tags(r.db, p["photo_id"])
    val comments = get_photo_comments(r.db, p["photo_id"])
    prval () = fold@(request)
  in
    if photo.count() = 1 then
      MakeGoodRequest(request, Direct(
        KRM("photo", photo, asObjects) ::
        KRM("comments", comments, asObjects) ::
        KRM("likes", likes, asObjects) ::
        KRM("recommended_tags", recommended_tags, asObjects) ::
        KRM("tags", tags, asObjects) ::
        nil))
    else let
      val () = free(photo)
      val () = free(comments)
      val () = free(likes)
      val () = free(recommended_tags)
      val () = free(tags)
    in
      MakeBadRequest(request, PhotoNotFound())
    end
  end) : Controller

val view_photo_request =
    view_photo_form
>=> view_photo_controller


// Create a new album 
// ----------------------------------------------------------------------------
val make_album_form =
    checkp("album_name", in_range(1,32))

val make_album_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val result = make_album(r.db, s["user_id"], p["album_name"])
    prval () = fold@(request)
  in
    if result.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("albums", result, asObjects) ::
        nil))
    else let
      val () = free(result)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val make_album_request =
    ensure_loggedin
>=> make_album_form
>=> make_album_controller




// Upload photo to user's album 
// ----------------------------------------------------------------------------
val make_photo_form =
    checkp("album_id", is_int)
>=> checkp("photo_caption", in_range(0, 1000))
>=> checkf("photo_file", not_blank)

val make_photo_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val f  = (r.files) : dict
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val photo_file = f["photo_file"]
    val filename = string_make_substring(photo_file, i2sz(8), strlen(photo_file))
    val result = make_photo(r.db, s["user_id"], p["album_id"], p["photo_caption"], filename)
    prval () = fold@(request)
  in
    if result.count() = 1 then let
      // move the file into the uploads folder and generate a thumbnail
      val thumbnail_path = "website/thumbs/" + filename
      val upload_path = "website/uploads/" + filename
      val _ = make_thumbnail("300x250>", photo_file, thumbnail_path)
      val _ = myrename(photo_file, upload_path)
    in
      MakeGoodRequest(request, Direct(
        KRM("result", result, asObjects) ::
        nil))
    end
    else let
      val _ = myremove(photo_file)
      val () = free(result)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val make_photo_request =
    ensure_loggedin
>=> make_photo_form
>=> make_photo_controller



// Delete a user's album with photos in it 
// ----------------------------------------------------------------------------
val delete_album_form =
    checkp("album_id", is_int)

val delete_album_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful = (delete_album(r.db, s["user_id"], p["album_id"]))
      .map(lam r => r.command_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else 
      MakeBadRequest(request)
  end) : Controller

val delete_album_request =
    ensure_loggedin
>=> delete_album_form
>=> delete_album_controller


// Delete a user's photo 
// ----------------------------------------------------------------------------
val delete_photo_form =
    checkp("photo_id", is_int)

val delete_photo_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful = (delete_photo(r.db, s["user_id"], p["photo_id"]))
      .map(lam r => r.command_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else 
      MakeBadRequest(request)
  end) : Controller

val delete_photo_request =
    ensure_loggedin
>=> delete_photo_form
>=> delete_photo_controller












//=============================================================================
//||                              S3                                         ||
//=============================================================================


// Search by user, album, must include tags, and must exclude tags 
// ----------------------------------------------------------------------------
val search_photos_form = 
    checkp("user_id", is_int)
>=> checkp("album_id", is_int)
>=> checkp("include", is_taglist)
>=> checkp("exclude", is_taglist)
>=> checkp("caption", in_range(0, 32))

val search_photos_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val results = find_photos(r.db, p["user_id"], p["album_id"], p["caption"], p["include"], p["exclude"])
    prval () = fold@(request)
  in
    if results.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("photos", results, asObjects)
        :: nil
      ))
    else let 
      val () = free(results)
    in
      MakeBadRequest(request)
    end
  end) : Controller


val search_photos_request =
    search_photos_form
>=> search_photos_controller
 


// Tag A Photo 
// ----------------------------------------------------------------------------
val tag_photo_form = 
    checkp("photo_id", is_int)
>=> checkp("tag_name", is_tag)

val tag_photo_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful =
      (tag_photo(r.db, s["user_id"], p["photo_id"], p["tag_name"]))
      .map(lam r => r.query_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else
      MakeBadRequest(request)
  end) : Controller

val tag_photo_request =
    ensure_loggedin
>=> tag_photo_form
>=> tag_photo_controller
 

// Untag a Photo 
// ----------------------------------------------------------------------------
val untag_photo_form = 
    checkp("photo_id", is_int)
>=> checkp("tag_id", is_int)

val untag_photo_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful =
      (untag_photo(r.db, s["user_id"], p["photo_id"], p["tag_id"]))
      .map(lam r => r.query_ok())
  
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else
      MakeBadRequest(request)
  end) : Controller

val untag_photo_request =
    ensure_loggedin
>=> untag_photo_form
>=> untag_photo_controller
 




//=============================================================================
//||                              S4                                         ||
//=============================================================================


// Leave a comment as an anonymous user 
// Leave a comment as a registered user 
// Disallow commenting on personal photos 
// ----------------------------------------------------------------------------
val make_comment_form =
    checkp("photo_id", is_int)
>=> checkp("comment_body", in_range(0, 1000))


val make_comment_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful = (make_comment(r.db, s["user_id"], p["photo_id"], p["comment_body"]))
                      .map(lam r => r.count() > 0)
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else 
      MakeBadRequest(request)
  end) : Controller

val make_comment_request =
    make_comment_form
>=> make_comment_controller


// Add a like to a photo 
// ----------------------------------------------------------------------------
val make_photo_like_form =
    checkp("photo_id", is_int)

val make_photo_like_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val successful = (make_like(r.db, s["user_id"], p["photo_id"]))
                      .map(lam r => r.command_ok())
    prval () = fold@(request)
  in
    if successful then
      MakeGoodRequest(request)
    else 
      MakeBadRequest(request)
  end) : Controller


val make_photo_like_request = 
    ensure_loggedin
>=> make_photo_like_form
>=> make_photo_like_controller

// Trending tags 
// ----------------------------------------------------------------------------
val trending_tags_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val tags = trending_tags(r.db)
    prval () = fold@(request)
  in
    if tags.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("tags", tags, asObjects) ::
        nil))
    else let
      val () = free(tags)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val trending_tags_request =
    trending_tags_controller 


//=============================================================================
//||                              S5                                         ||
//=============================================================================

// Recommended tags
// ----------------------------------------------------------------------------
val recommended_tags_form = 
    checkp("photo_id", is_int)

val recommended_tags_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val s = (r.session) : dict
    val tags = recommended_tags(r.db, s["user_id"], p["photo_id"])
    prval () = fold@(request)
  in
    if tags.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("tags", tags, asObjects) ::
        nil))
    else let
      val () = free(tags)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val recommended_tags_request =
    ensure_loggedin
>=> recommended_tags_form
>=> recommended_tags_controller


// Recommended photos
// ----------------------------------------------------------------------------
val recommended_photos_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p = (r.post) : dict
    val s = (r.session) : dict
    val photos = recommended_photos(r.db, s["user_id"])
    prval () = fold@(request)
  in
    if photos.query_ok() then
      MakeGoodRequest(request, Direct(
        KRM("photos", photos, asObjects) ::
        nil))
    else let
      val () = free(photos)
    in
      MakeBadRequest(request)
    end
  end) : Controller

val recommended_photos_request =
    ensure_loggedin
>=> recommended_photos_controller


//=============================================================================
//||                           Authentication                                ||
//=============================================================================

val account_info_controller =
  (lam request => let
    val+@REQUEST(r) = request
    val p  = (r.post) : dict
    val s  = (r.session) : dict
    val account = get_user(r.db, s["user_id"])
    prval () = fold@(request)
  in
    if account.count() = 1 then
      MakeGoodRequest(request, Direct(
        KRM("account", account, asObjects)
        :: nil
      ))
    else let
      val () = free(account)
    in 
      MakeBadRequest(request)
    end
  end) : Controller

val account_info_request = 
    ensure_loggedin
>=> account_info_controller


