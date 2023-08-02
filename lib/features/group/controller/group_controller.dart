import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/group/service/group_service.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';

final groupControllerProvider = Provider((ref) {
  final groupService = ref.read(groupServiceProvider);
  return GroupController(groupService: groupService, ref: ref);
});

class GroupController {
  final GroupService groupService;
  final ProviderRef ref;

  GroupController({
    required this.groupService,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<ContactModel> selectedContacts) {
    groupService.createGroup(context, name, profilePic, selectedContacts);
  }
}
