import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:uuid/uuid.dart';

addToActivityFeed(
    {required String type,
    required String uid,
    required String postId,
    required String postText,
    required String profilePhoto,
    required String name,
    required List mediaUrl,
    String comment = '',
    String oldComment = ''}) async {
  bool isNotPostOwner = user!.uid != uid;
  if (isNotPostOwner) {
    if (type == 'like') {
      return await FirebaseFirestore.instance
          .collection('activity')
          .doc(uid)
          .collection("activityItems")
          .doc(postId)
          .set({
        'type': type,
        'uid': auth.currentUser!.uid,
        'profilePhotoUrl': profilePhoto,
        'name': name,
        'postId': postId,
        'postText': postText,
        'mediaUrl': mediaUrl,
        'time': Timestamp.now()
      });
    } else if (type == 'comment') {
      return await FirebaseFirestore.instance
          .collection('activity')
          .doc(uid)
          .collection("activityItems")
          .doc(postId)
          .set({
        'type': 'comment',
        'comment': comment,
        'uid': user!.uid,
        'profilePhotoUrl': profilePhoto,
        'name': name,
        'postId': postId,
        'postText': postText,
        'mediaUrl': mediaUrl,
        'time': Timestamp.now()
      });
    } else if (type == 'replyComment') {
      return await FirebaseFirestore.instance
          .collection('activity')
          .doc(uid)
          .collection("activityItems")
          .doc(postId)
          .set({
        'type': 'replyComment',
        'comment': comment,
        'oldComment': oldComment,
        'uid': user!.uid,
        'profilePhotoUrl': profilePhoto,
        'name': name,
        'postId': postId,
        'postText': postText,
        'mediaUrl': mediaUrl,
        'time': Timestamp.now()
      });
    } else if (type == 'likeComment') {
      return await FirebaseFirestore.instance
          .collection('activity')
          .doc(uid)
          .collection("activityItems")
          .doc(postId)
          .set({
        'type': type,
        'comment': comment,
        'uid': user!.uid,
        'profilePhotoUrl': profilePhoto,
        'name': name,
        'postId': postId,
        'postText': postText,
        'mediaUrl': mediaUrl,
        'time': Timestamp.now()
      });
    } else if (type == 'follow') {
      return await FirebaseFirestore.instance
          .collection('activity')
          .doc(uid)
          .collection("activityItems")
          .doc(user!.uid)
          .set({
        'type': 'follow',
        'uid': user!.uid,
        'profilePhotoUrl': profilePhoto,
        'name': name,
        'time': Timestamp.now()
      });
    }
  }
}

removeFromActivityUser({required String uid, String? userID}) async {
  userID ??= user!.uid;
  return await FirebaseFirestore.instance
      .collection('activity')
      .doc(uid)
      .collection("activityItems")
      .where('uid', isEqualTo: userID)
      .get()
      .then((value) {
    for (var i in value.docs) {
      if (i.exists) {
        i.reference.delete();
      }
    }
  });
}

//Chat
addMessage({required String email,required String message,required String voice,required List mediaUrl,bool isReplyMessage=false}) async {
  String messageId=const Uuid().v1();
  if(isReplyMessage){}else{
    return await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(getChatRoomIdByEmail(email))
        .collection('chats')
        .doc(messageId)
        .set({
      'message': message,
      'messageId':messageId,
      'replayMessage': {},
      'sendBy': user!.uid,
      'time':Timestamp.now(),
      'isRead': false,
      'isEditing': false,
      'voice': voice,
      'mediaUrl': mediaUrl,
    }).then((value)async{
      await updateLastMessageSend(email, message, mediaUrl, voice);

    });
  }

}

editMessage(String chatRoomId, String messageId,
    Map<String, dynamic> messageInfoMap) async {
  return await FirebaseFirestore.instance
      .collection('chatRoom')
      .doc(chatRoomId)
      .collection('chats')
      .doc(messageId)
      .update(messageInfoMap);
}

updateLastMessageSend(
    String email,String message,List lastMessageMediaUrl,String lastMessageVoice,) {
  return FirebaseFirestore.instance
      .collection('chatRoom')
      .doc(getChatRoomIdByEmail(email))
      .update({
    'lastMessage': message,
    'lastMessageMediaUrl': lastMessageMediaUrl,
    'lastMessageVoiceUrl': lastMessageVoice,
    'lastMessageSendTime': Timestamp.now(),
    'lastMessageSendBy': user!.uid,
    'isRead': false
  });
}

getChatRoomIdByEmail(String userEmail) {
  if (user!.email!.compareTo(userEmail) == 1 || user!.email!.compareTo(userEmail) == 0) {
    return '${user!.email}_$userEmail';
  } else {
    return  '${userEmail}_${user!.email}';
  }
}
getUserFromListUser(List users){
  if(users[0]==user!.uid){
    return users[1];
  }else{
    return users[0];
  }
}

createChatRoom( String userId,String email) async {
  final snapShot = await FirebaseFirestore.instance
      .collection('chatRoom')
      .doc(getChatRoomIdByEmail(email))
      .get();
  if (snapShot.exists) {
    return true;
  } else {
    return FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(getChatRoomIdByEmail(email))
        .set({
      'users': [user!.uid, userId]
    });
  }
}



Future<Stream<QuerySnapshot>> getChatRooms(String myEmail) async {
  return FirebaseFirestore.instance
      .collection('chatRoom')
      .orderBy('lastMessageSendTime', descending: true)
      .where('users', arrayContains: myEmail)
      .snapshots();
}

getRecentChatMessage()  {
  return FirebaseFirestore.instance
      .collection('chatRoom').where('users',arrayContains: user!.uid)
      .orderBy('lastMessageSendTime', descending: true)
      .snapshots();
}