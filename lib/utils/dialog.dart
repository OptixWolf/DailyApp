import 'package:uuid/uuid.dart';

import 'database.dart';
import 'package:flutter/material.dart';

class TextfieldDialog extends StatefulWidget {
  final int? userid;

  const TextfieldDialog({super.key, required this.userid});

  @override
  State<TextfieldDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<TextfieldDialog> {
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Instanz erstellen/hinzufügen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Erstellen:'),
          TextField(
            controller: _controller1,
            decoration: const InputDecoration(
              hintText: 'Instanzname (Max. 128 Zeichen)',
            ),
          ),
          SizedBox(height: 10),
          Divider(height: 2),
          SizedBox(height: 10),
          Text('Beitreten'),
          TextField(
            controller: _controller2,
            decoration: const InputDecoration(
              hintText: 'Instanzcode (36 Zeichen)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final guid = _controller2.text;

            if (guid != "" && guid.length == 36) {
              var instances = await DatabaseService().executeQuery(
                  'SELECT Id, name, invitationAccess, inviteCode FROM instance');

              for (var instance in instances) {
                if (instance['invitationAccess'] &&
                    instance['inviteCode'] == guid) {
                  // Save
                }
              }
            }

            Navigator.of(context).pop();
          },
          child: const Text('Beitreten'),
        ),
        TextButton(
          onPressed: () async {
            var uuid = Uuid();

            final instanceName = _controller1.text;
            final now = DateTime.now();
            final date = DateTime(now.day, now.month, now.year);
            final guid = uuid.v4();

            if (instanceName != "" && instanceName.length <= 128) {
              var instance = await DatabaseService().executeQuery(
                  'INSERT INTO instance(name, invitationAccess, inviteCode, date, bypassDeletion) VALUES (\'$instanceName\', false, \'$guid\', $date, false)');
              return instance.last['Id'];
            }

            Navigator.of(context).pop();
          },
          child: const Text('Erstellen'),
        ),
      ],
    );
  }
}
