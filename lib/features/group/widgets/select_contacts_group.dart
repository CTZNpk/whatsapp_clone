import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/features/select_contacts/controller/select_contact_controller.dart';
import 'package:whatsapp_clone/share/model/contact_model.dart';
import 'package:whatsapp_clone/share/widgets/error.dart';
import 'package:whatsapp_clone/share/widgets/loading_screen.dart';

final selectedGroupContacts = StateProvider<List<ContactModel>>((ref) => []);

class SelectContactsGroup extends ConsumerStatefulWidget {
  const SelectContactsGroup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectContactsGroupState();
}

class _SelectContactsGroupState extends ConsumerState<SelectContactsGroup> {
  List<int> selectedContactsIndex = [];

  void selectContacts(int index, ContactModel contact) {
    if (selectedContactsIndex.contains(index)) {
      selectedContactsIndex.remove(index);
    } else {
      selectedContactsIndex.add(index);
    }
    setState(() {});
    ref
        .read(selectedGroupContacts.notifier)
        .update((state) => [...state, contact]);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getContactProvider).when(
          data: (contactList) => Expanded(
            child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return InkWell(
                  onTap: () => selectContacts(index, contact),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: selectedContactsIndex.contains(index)
                          ? Icon(
                              Icons.done,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          error: (err, trace) => ErrorScreen(error: err.toString()),
          loading: () => const LoadingScreen(),
        );
  }
}
