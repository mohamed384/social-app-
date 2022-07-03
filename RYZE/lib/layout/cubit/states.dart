abstract class HomeStates {}

class HomeInitialState extends HomeStates {}

class ChangeButtonNav extends HomeStates {}

class ChangeIsSentimentPostState extends HomeStates {}

class ChangeIsSentimentPostAnimState extends HomeStates {}

class ChangePostIndexState extends HomeStates {}

class ChangeIsLoadedNav extends HomeStates {}

class ChangeShowBarNav extends HomeStates {}

class FirebaseGetPostsState extends HomeStates {}

class FirebaseGetProfilePostsState extends HomeStates {}

class FirebaseGetHomePostsState extends HomeStates {}
class FirebaseGetStoryState extends HomeStates {}

class FirebaseGetMyStoryState extends HomeStates {}

class FirebasePostsErrorState extends HomeStates {
  final String error;

  FirebasePostsErrorState({required this.error});
}class FirebaseStoryErrorState extends HomeStates {
  final String error;

  FirebaseStoryErrorState({required this.error});
}



class FirebaseGetUserDataState extends HomeStates {}

class FirebaseGetUserDataErrorState extends HomeStates {
  final String error;

  FirebaseGetUserDataErrorState({required this.error});
}

class CurrentIndicatorIndexHomeState extends HomeStates {}

class ChangeIsLikePostState extends HomeStates {}

class ChangeCommentLengthState extends HomeStates {}

class ChangeRemovePostState extends HomeStates {}

class ChangeIsEditAnimState extends HomeStates {}



//profile states
class ChangeIsMyProfileState extends HomeStates {}
//firebase follow


class ChangeIsLoadPostState extends HomeStates {}

class ChangeIsFollowBtnState extends HomeStates {}
