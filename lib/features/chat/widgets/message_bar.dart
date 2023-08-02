import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_clone/features/chat/widgets/message_reply_preview.dart';
import 'package:whatsapp_clone/share/enums/message_enum.dart';
import 'package:whatsapp_clone/share/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/share/utils/utils.dart';

class MessageBar extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;

  const MessageBar({
    super.key,
    required this.recieverUserId,
    required this.isGroupChat,
  });

  @override
  ConsumerState<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends ConsumerState<MessageBar> {
  bool isShowSendButton = false;
  bool isShowEmojiContainer = false;
  FocusNode focusNode = FocusNode();
  bool isRecorderInit = false;
  bool isRecording = false;

  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;

  @override
  void initState() {
    super.initState();
    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic Permission not Allowed');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.recieverUserId, messageEnum, widget.isGroupChat);
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _soundRecorder?.closeRecorder();
    isRecorderInit = false;
    super.dispose();
  }

  void setSendButtonToMicIcon() {
    setState(() {
      isShowSendButton = false;
    });
  }

  void setSendButtonToSendIcon() {
    setState(() {
      isShowSendButton = true;
    });
  }

  void sendTextMessage() async {
    if (isShowSendButton && _messageController.text.trim() != "") {
      ref.read(chatControllerProvider).sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.recieverUserId,
            widget.isGroupChat,
          );
      _messageController.text = '';
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder?.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder?.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply
            ? const MessageReplyPreview()
            : const SizedBox.shrink(),
        Row(
          children: [
            Expanded(
              child: _MessageBarHeightAndDecoration(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: _MessageTextField(
                    focusNode: focusNode,
                    messageController: _messageController,
                    toggleEmojiKeyboard: toggleEmojiKeyboardContainer,
                    setSendButtonToMicIcon: setSendButtonToMicIcon,
                    setSendButtonToSendIcon: setSendButtonToSendIcon,
                    selectImage: selectImage,
                    selectVideo: selectVideo,
                  ),
                ),
              ),
            ),
            _SendButton(
              sendTextMessage: sendTextMessage,
              isShowSendButton: isShowSendButton,
              isRecording: isRecording,
            ),
          ],
        ),
        isShowEmojiContainer
            ? SizedBox(
                height: 310,
                child: EmojiPicker(
                  onEmojiSelected: ((category, emoji) {
                    setState(
                      () {
                        _messageController.text =
                            _messageController.text + emoji.emoji;
                      },
                    );
                  }),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class _MessageBarHeightAndDecoration extends StatelessWidget {
  final Widget child;
  const _MessageBarHeightAndDecoration({required this.child});

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: myTheme.scaffoldBackgroundColor,
          ),
        ),
        color: myTheme.scaffoldBackgroundColor,
      ),
      child: child,
    );
  }
}

class _MessageTextField extends StatelessWidget {
  final FocusNode focusNode;
  final VoidCallback toggleEmojiKeyboard;
  final VoidCallback setSendButtonToMicIcon;
  final VoidCallback setSendButtonToSendIcon;
  final VoidCallback selectImage;
  final VoidCallback selectVideo;
  final TextEditingController messageController;

  const _MessageTextField({
    required this.toggleEmojiKeyboard,
    required this.focusNode,
    required this.setSendButtonToSendIcon,
    required this.setSendButtonToMicIcon,
    required this.messageController,
    required this.selectImage,
    required this.selectVideo,
  });

  @override
  Widget build(BuildContext context) {
    final myTheme = Theme.of(context);
    return TextField(
      focusNode: focusNode,
      controller: messageController,
      onChanged: (val) {
        if (val.isNotEmpty) {
          setSendButtonToSendIcon();
        } else {
          setSendButtonToMicIcon();
        }
      },
      decoration: InputDecoration(
        fillColor: myTheme.searchViewTheme.backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.only(left: 20),
        hintText: 'Enter Text',
        hintStyle: myTheme.textTheme.labelSmall,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        prefixIcon: _PrefixIcons(
          toggleEmojiKeyboard: toggleEmojiKeyboard,
        ),
        suffixIcon: _SuffixIcons(
          selectImage: selectImage,
          selectVideo: selectVideo,
        ),
      ),
    );
  }
}

class _PrefixIcons extends StatelessWidget {
  final VoidCallback toggleEmojiKeyboard;

  const _PrefixIcons({
    required this.toggleEmojiKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 50,
        child: Row(
          children: [
            IconButton(
              onPressed: toggleEmojiKeyboard,
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuffixIcons extends StatelessWidget {
  final VoidCallback selectImage;
  final VoidCallback selectVideo;
  const _SuffixIcons({required this.selectImage, required this.selectVideo});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: selectImage,
            icon: const Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: selectVideo,
            icon: const Icon(
              Icons.videocam,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback sendTextMessage;
  final bool isShowSendButton;
  final bool isRecording;
  const _SendButton({
    required this.sendTextMessage,
    required this.isShowSendButton,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
        right: 2,
        left: 2,
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF128C7E),
        child: GestureDetector(
          onTap: sendTextMessage,
          child: Icon(
            isShowSendButton
                ? Icons.send
                : isRecording
                    ? Icons.close
                    : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
