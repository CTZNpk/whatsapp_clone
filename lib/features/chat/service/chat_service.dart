import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/share/enums/message_enum.dart';
import 'package:whatsapp_clone/share/model/chat_contact.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';
import 'package:whatsapp_clone/share/model/group_model.dart';
import 'package:whatsapp_clone/share/model/message.dart';
import 'package:whatsapp_clone/share/model/user_model.dart';
import 'package:whatsapp_clone/share/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/share/services/shared_firebase_storage_services.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';

final chatServiceProvider = Provider((ref) => ChatService(
    firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance));

class ChatService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatService({
    required this.firestore,
    required this.auth,
  });

  Stream<List<Group>> getChatGroups() {
    return firestore.collection('groups').snapshots().map(
      (event) {
        List<Group> groups = [];
        for (var document in event.docs) {
          var chatGroup = Group.fromMap(document.data());
          if (chatGroup.membersUid.contains(auth.currentUser!.uid)) {
            groups.add(chatGroup);
          }
        }
        return groups;
      },
    );
  }

  Stream<List<Message>> getGroupChatStream(String groupId) {
    return firestore
        .collection('users')
        .doc(groupId)
        .collection('chats')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(
            Message.fromMap(
              document.data(),
            ),
          );
        }
        return messages;
      },
    );
  }

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContact> contacts = [];
        for (var document in event.docs) {
          var chatContact = ChatContact.fromMap(document.data());
          contacts.add(chatContact);
        }
        return contacts;
      },
    );
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map(
      (event) {
        List<Message> messages = [];
        for (var document in event.docs) {
          messages.add(
            Message.fromMap(
              document.data(),
            ),
          );
        }
        return messages;
      },
    );
  }

  Future sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    await _MessageService(firestore: firestore, auth: auth).sendTextMessage(
      context: context,
      text: text,
      recieverUserId: recieverUserId,
      senderUser: senderUser,
      messageReply: messageReply,
      isGroupChat: isGroupChat,
    );
  }

  Future sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required UserModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();

      String imageUrl = await ref
          .read(sharedFirebaseStorageServiceProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/$recieverUserId/$messageId',
              file);

      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = 'Photo';
          break;
        case MessageEnum.video:
          contactMsg = 'Video';
          break;
        case MessageEnum.audio:
          contactMsg = 'Audio';
          break;
        case MessageEnum.gif:
          contactMsg = 'GIF';
          break;
        default:
          contactMsg = 'GIF';
      }

      _MessageService(firestore: firestore, auth: auth)
          ._saveDataToContactSubCollection(
        senderUserData,
        recieverUserData,
        contactMsg,
        timeSent,
        recieverUserId,
        isGroupChat,
      );



      if(!isGroupChat){
      String recieverContactName = recieverUserData!.name;
      var recieverContact = await firestore
          .collection('users')
          .doc(senderUserData.uid)
          .collection('contacts')
          .doc(recieverUserData.uid)
          .get();
      if (recieverContact.data() != null) {
        ContactModel recieverContactMap =
            ContactModel.fromMap(recieverContact.data()!);
        recieverContactName = recieverContactMap.name;
      }

      String senderContactName = senderUserData.name;
      var senderContact = await firestore
          .collection('users')
          .doc(recieverUserData.uid)
          .collection('contacts')
          .doc(senderUserData.uid)
          .get();
      if (senderContact.data() != null) {
        ContactModel senderContactMap =
            ContactModel.fromMap(senderContact.data()!);
        senderContactName = senderContactMap.name;
      }
      _MessageService(firestore: firestore, auth: auth)
          ._saveMessageToMessageSubCollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        messageType: messageEnum,
        recieverUserName: recieverContactName,
        senderUserName: senderContactName,
        messageReply: messageReply,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum,
        isGroupChat: isGroupChat,
      );
      }

      _MessageService(firestore: firestore, auth: auth)
          ._saveMessageToMessageSubCollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        messageType: messageEnum,
        recieverUserName: recieverUserData!.name,
        senderUserName: senderUserData.name,
        messageReply: messageReply,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
      BuildContext context, String recieverUserId, String messageId) async {
    try {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}

class _MessageService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  _MessageService({
    required this.firestore,
    required this.auth,
  });

  Future sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
    required MessageReply? messageReply,
    required bool isGroupChat,
  }) async {
    try {
      var timeSent = DateTime.now();
      UserModel? recieverUserData;
      if (!isGroupChat) {
        var userDataMap =
            await firestore.collection('users').doc(recieverUserId).get();
        recieverUserData = UserModel.fromMap(userDataMap.data()!);
      }

      var messageId = const Uuid().v1();

      await _saveDataToContactSubCollection(senderUser, recieverUserData, text,
          timeSent, recieverUserId, isGroupChat);

      String?  recieverContactName;
      String? senderContactName = senderUser.name;
      if(!isGroupChat){
      recieverContactName = recieverUserData!.name;
      var recieverContact = await firestore
          .collection('users')
          .doc(senderUser.uid)
          .collection('contacts')
          .doc(recieverUserData.uid)
          .get();
      if (recieverContact.data() != null) {
        ContactModel recieverContactMap =
            ContactModel.fromMap(recieverContact.data()!);
        recieverContactName = recieverContactMap.name;
      }

      senderContactName = senderUser.name;
      var senderContact = await firestore
          .collection('users')
          .doc(recieverUserData.uid)
          .collection('contacts')
          .doc(senderUser.uid)
          .get();
      if (senderContact.data() != null) {
        ContactModel senderContactMap =
            ContactModel.fromMap(senderContact.data()!);
        senderContactName = senderContactMap.name;
      }
      }


      await _saveMessageToMessageSubCollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        messageReply: messageReply,
        recieverUserName: recieverContactName,
        senderUserName: senderContactName,
        repliedMessageType:
            messageReply == null ? MessageEnum.text : messageReply.messageEnum,
        isGroupChat: isGroupChat,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future _saveDataToContactSubCollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
    bool isGroupChat,
  ) async {
    if (isGroupChat) {
      await firestore.collection('groups').doc(recieverUserId).update(
        {
          'lastmessage': text,
          'timeSent': DateTime.now().millisecondsSinceEpoch
        },
      );
    } else {
      String senderContactName = senderUserData.name;
      var senderContact = await firestore
          .collection('users')
          .doc(recieverUserData!.uid)
          .collection('contacts')
          .doc(senderUserData.uid)
          .get();
      if (senderContact.data() != null) {
        ContactModel senderContactMap =
            ContactModel.fromMap(senderContact.data()!);
        senderContactName = senderContactMap.name;
      }

      var recieverChatContact = ChatContact(
        name: senderContactName,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await _saveDataToRecieverContactSubCollection(
        recieverChatContact: recieverChatContact,
        recieverUserId: recieverUserId,
      );

      String recieverContactName = recieverUserData.name;
      var recieverContact = await firestore
          .collection('users')
          .doc(senderUserData.uid)
          .collection('contacts')
          .doc(recieverUserData.uid)
          .get();
      if (recieverContact.data() != null) {
        ContactModel recieverContactMap =
            ContactModel.fromMap(recieverContact.data()!);
        recieverContactName = recieverContactMap.name;
      }
      var senderChatContact = ChatContact(
        name: recieverContactName,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text,
      );
      await _saveDataToSenderContactSubCollection(
        senderChatContact: senderChatContact,
        recieverUserId: recieverUserId,
      );
    }
  }

  Future _saveDataToRecieverContactSubCollection(
      {required ChatContact recieverChatContact,
      required String recieverUserId}) async {
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());
  }

  Future _saveDataToSenderContactSubCollection(
      {required ChatContact senderChatContact,
      required String recieverUserId}) async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(senderChatContact.toMap());
  }

  Future _saveMessageToMessageSubCollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUserName,
    required String? recieverUserName,
    required MessageEnum repliedMessageType,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      recieverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUserName
              : recieverUserName ?? '',
      repliedMessageType: repliedMessageType,
    );
    if (isGroupChat) {
      await firestore
          .collection('groups')
          .doc(recieverUserId)
          .collection('chats')
          .doc(messageId)
          .set(message.toMap());
    } else {
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      await firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    }
  }
}
