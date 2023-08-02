import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/auth/controller/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/service/chat_service.dart';
import 'package:whatsapp_clone/share/enums/message_enum.dart';
import 'package:whatsapp_clone/share/model/chat_contact.dart';
import 'package:whatsapp_clone/share/model/group_model.dart';
import 'package:whatsapp_clone/share/model/message.dart';
import 'package:whatsapp_clone/share/providers/message_reply_provider.dart';

final chatControllerProvider = Provider((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatController(ref: ref, chatService: chatService);
});

class ChatController {
  final ChatService chatService;
  final ProviderRef ref;
  ChatController({required this.chatService, required this.ref});

  void sendTextMessage(
    BuildContext context,
    String text,
    String recieverUserId,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatService.sendTextMessage(
            context: context,
            text: text,
            recieverUserId: recieverUserId,
            senderUser: value!,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  void sendFileMessage(
    BuildContext context,
    File file,
    String recieverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
  ) {
    final messageReply = ref.read(messageReplyProvider);
    ref.read(userDataAuthProvider).whenData(
          (value) => chatService.sendFileMessage(
            context: context,
            file: file,
            recieverUserId: recieverUserId,
            senderUserData: value!,
            messageEnum: messageEnum,
            ref: ref,
            messageReply: messageReply,
            isGroupChat: isGroupChat,
          ),
        );
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  Stream<List<ChatContact>> chatContacts() {
    return chatService.getChatContacts();
  }

  Stream<List<Group>> chatGroups() {
    return chatService.getChatGroups();
  }

  Stream<List<Message>> groupChatStream(String recieverUserId) {
    return chatService.getGroupChatStream(recieverUserId);
  }

  Stream<List<Message>> chatStream(String recieverUserId) {
    return chatService.getChatStream(recieverUserId);
  }

  void setChatMessageSeen(
      BuildContext context, String recieverUserId, String messageId) {
    chatService.setChatMessageSeen(
      context,
      recieverUserId,
      messageId,
    );
  }
}
