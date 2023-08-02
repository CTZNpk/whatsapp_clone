import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/services/select_contact_service.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';

final getContactProvider = FutureProvider(
  (ref) {
    final selectContactService = ref.watch(selectContactServiceProvider);
    return selectContactService.getContacts();
  },
);

final selectContactControllerProvider = Provider((ref) {
  final selectContactsService = ref.watch(selectContactServiceProvider);
  return SelectContactController(
    ref: ref,
    selectContactsService: selectContactsService,
  );
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactsService selectContactsService;

  SelectContactController({
    required this.ref,
    required this.selectContactsService,
  });

  void selectContact(ContactModel selectedContact, BuildContext context) {
    selectContactsService.selectContact(selectedContact, context);
  }

  Future syncContacts() async {
    await selectContactsService.syncContacts();
  }
}
