import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ryze/layout/cubit/states.dart';
import 'package:ryze/shared/constants/constants.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  bool isSentimentPost = true;

  changeIsSentimentPost(value) {
    isSentimentPost = value;
    emit(ChangeIsSentimentPostState());
  }

  bool isSentimentPostAnim = false;

  changeIsSentimentPostAnim(value) {
    isSentimentPostAnim = value;
    emit(ChangeIsSentimentPostAnimState());
  }

  int currentIndex = 0;

  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeButtonNav());
  }

  bool isLoaded = true;

  void changeIsLoaded() {
    isLoaded = !isLoaded;
    emit(ChangeIsLoadedNav());
  }

  void runAll() async {
    await getTimeline();
    await getStoryTimeline();
  }

  void forRefresh() async {
    await getTimeline();
    await getStoryTimeline();
  }

  bool isLikePost = false;

  void changeIsLikePost() {
    isLikePost = !isLikePost;
    emit(ChangeIsLikePostState());
  }

  int commentLength = 0;

  void changeCommentLength(value) {
    commentLength = value;
    emit(ChangeCommentLengthState());
  }

  List postFuture = [];

  Future<QuerySnapshot<Object?>> getPosts(String userUid) async {
    postFuture.clear();
    QuerySnapshot postF = await FirebaseFirestore.instance
        .collection('userPosts')
        .where('uid', isEqualTo: userUid)
        .orderBy('time', descending: true)
        .get();

    for (var element in postF.docs) {
      postFuture.add(element.id);
    }
    emit(FirebaseGetPostsState());
    return postF;
  }

  List profilePostFuture = [];

  getProfilePosts(String userUid) async {
    profilePostFuture.clear();
    await FirebaseFirestore.instance
        .collection('userPosts')
        .where('uid', isEqualTo: userUid)
        .orderBy('time', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        profilePostFuture.add(element);
      }
      emit(FirebaseGetProfilePostsState());
    });
  }

  void removePost(index) {
    postFuture.removeAt(index);
    emit(ChangeRemovePostState());
  }

  List storyFuture = [];

  Future<void> getStory(String userUid) async {
    await FirebaseFirestore.instance
        .collection('userStory')
        .orderBy('time', descending: true)
        .get()
        .then((value) {
      storyFuture.clear();
      for (var element in value.docs) {
        storyFuture.add(element.data());
        emit(FirebaseGetMyStoryState());
      }
    }).catchError((error) {
      emit(FirebaseStoryErrorState(error: error.toString()));
    });
  }

  bool isEditAnim = false;

  void changeIsEditAnim(value) {
    isEditAnim = value;
    emit(ChangeIsEditAnimState());
  }

//Profile Screen
  bool isMyProfile = false;

  void changeIsMyProfile(value) {
    isMyProfile = value;
    emit(ChangeIsMyProfileState());
  }

  bool isLoadPost = true;

  void changeIsLoadPost(value) {
    isLoadPost = value;
    emit(ChangeIsLoadPostState());
  }

//Firebase Follow

  var followersList = [];

  getFollowers(String uid) async {
    followersList.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(uid)
        .collection("userFollowers")
        .get();
    for (var element in snapshot.docs) {
      followersList.add(element.id);
    }
  }

  bool isFollow = false;

  getIsFollow(String uid) async {
    followersList.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('followers')
        .doc(user!.uid)
        .collection("userFollowers")
        .get();
    for (var element in snapshot.docs) {
      if (element.id.toString() == uid) {
        changeIsFollowBtn(true);
      }
    }
  }

  List timelinePosts = [];

  Future<void> getTimeline() async {
    List posts = [];

    for (int i = 0; i < followersList.length; i++) {
      await FirebaseFirestore.instance
          .collection('userPosts')
          .where('uid', isEqualTo: followersList[i])
          .orderBy('time', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          posts.add(element.data());
          emit(FirebaseGetHomePostsState());
        }
      });
    }
    timelinePosts.clear();
    timelinePosts = timelinePosts + posts;
    timelinePosts = (timelinePosts..shuffle());
  }

  List timelineStories = [];

  Future<void> getStoryTimeline() async {
    List stories = [];

    for (int i = 0; i < followersList.length; i++) {
      await FirebaseFirestore.instance
          .collection('userStories')
          .where('uid', isEqualTo: followersList[i])
          .orderBy('time', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          stories.add(element.data());
          emit(FirebaseGetStoryState());
        }
      });
    }
    timelineStories.clear();
    timelineStories = timelineStories + stories;
    timelineStories = (timelineStories..shuffle());
  }

  var followingList = [];

  getFollowing(String uid) async {
    followingList.clear();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('following')
        .doc(uid)
        .collection("userFollowing")
        .get();
    for (var element in snapshot.docs) {
      followingList.add(element.id);
    }
  }

  bool isFollowBtn = false;

  void changeIsFollowBtn(value) {
    isFollowBtn = value;

    emit(ChangeIsFollowBtnState());
  }
}
