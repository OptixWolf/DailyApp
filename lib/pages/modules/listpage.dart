import 'dart:async';
import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:DailyApp/pages/modules/listpage_entries.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../utils/preferences.dart';
import '../../utils/snackbar.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> listen = [];
  TextEditingController textEditingController = TextEditingController();
  int editIndex = -1;

  bool selectedAskListDeletionValue = true;
  bool selectedReorderValue = true;

  @override
  void initState() {
    super.initState();
    Preferences.getPrefBool('reorder').then((reorderValue) {
      setState(() {
        selectedReorderValue = reorderValue;
      });
    });
    Preferences.getPrefList('listen').then((lists) {
      setState(() {
        listen = lists;
      });
    });
    Preferences.getPrefBool('list-deletion').then((listDeletionValue) {
      setState(() {
        selectedAskListDeletionValue = listDeletionValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    void toggleSwitchReorder() {
      setState(() {
        selectedReorderValue = !selectedReorderValue;
        Preferences.setPrefBool('reorder', selectedReorderValue);
      });
    }

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          const SizedBox(height: 55),
          Row(
            children: [
              const SizedBox(width: 7),
              Expanded(
                  child: Text(localizations.categoryLists,
                      style: const TextStyle(fontSize: 50))),
              /*FilledButton(
                      onPressed: () => {},
                      child: Text("Offline",
                          style: TextStyle(fontWeight: FontWeight.bold))),*/
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1) {
                    toggleSwitchReorder();
                  }
                  if (value == 2) {
                    _showDeleteDialog(context, -2, 'listen');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        const Icon(Icons.menu),
                        Text(localizations.generalSwitchIndicators),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        Text(localizations.generalDeleteAllEntries),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          listen.isNotEmpty
              ? Expanded(
                  child: ReorderableListView.builder(
                    itemCount: listen.length,
                    itemBuilder: (context, index) {
                      return Card(
                        key: Key('$index'),
                        child: Slidable(
                          key: Key('$index'),
                          startActionPane: ActionPane(
                            extentRatio: 0.4,
                            motion: const BehindMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  setState(() {
                                    editIndex = index;
                                    textEditingController.text =
                                        listen.elementAt(index);
                                  });
                                },
                                backgroundColor: Colors.blue,
                                icon: Icons.edit,
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  _showDeleteDialog(context, index, 'listen');
                                },
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              listen.elementAt(index),
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Visibility(
                              visible: selectedReorderValue,
                              child: ReorderableDragStartListener(
                                  index: index, child: const Icon(Icons.menu)),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ListPageEntries(
                                      listenname: listen.elementAt(index))));
                            },
                          ),
                        ),
                      );
                    },
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final String item = listen.removeAt(oldIndex);
                        listen.insert(newIndex, item);
                        Preferences.setPrefList('listen', listen);
                      });
                    },
                  ),
                )
              : Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text(localizations.listsNoListMessage),
                    ),
                  ),
                ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Flexible(
                      child: TextField(
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      if (textEditingController.text.isNotEmpty) {
                        if (editIndex == -1) {
                          setState(() {
                            if (!listen.contains(textEditingController.text)) {
                              listen.add(textEditingController.text);
                              textEditingController.text = '';
                              Preferences.setPrefList('listen', listen);
                              Preferences.setPrefList(
                                  'liste-${textEditingController.text}', []);
                            } else {
                              Snackbar().show(context,
                                  localizations.listsNameMustNotBeDuplicate);
                            }
                          });
                        } else {
                          setState(() {
                            Preferences.getPrefList(
                                    'liste-${listen.elementAt(editIndex)}')
                                .then((listContent) {
                              Preferences.remPref(
                                  'liste-${listen.elementAt(editIndex)}');
                              listen[editIndex] = textEditingController.text;
                              Preferences.setPrefList('listen', listen);
                              Preferences.setPrefList(
                                  'liste-${listen.elementAt(editIndex)}',
                                  listContent);
                              textEditingController.text = '';
                              editIndex = -1;
                            });
                          });
                        }
                      } else {
                        Snackbar().show(
                            context, localizations.generalFieldMustNotBeEmpty);
                      }
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: editIndex == -1
                          ? localizations.listsExampleName
                          : localizations.listsEditFieldText,
                    ),
                  )),
                  const SizedBox(width: 10),
                  IconButton(
                      icon: editIndex == -1
                          ? const Icon(Icons.add)
                          : const Icon(Icons.create),
                      onPressed: () {
                        if (textEditingController.text.isNotEmpty) {
                          if (editIndex == -1) {
                            setState(() {
                              if (!listen
                                  .contains(textEditingController.text)) {
                                listen.add(textEditingController.text);
                                textEditingController.text = '';
                                Preferences.setPrefList('listen', listen);
                                Preferences.setPrefList(
                                    'liste-${textEditingController.text}', []);
                              } else {
                                Snackbar().show(context,
                                    localizations.listsNameMustNotBeDuplicate);
                              }
                            });
                          } else {
                            setState(() {
                              Preferences.getPrefList(
                                      'liste-${listen.elementAt(editIndex)}')
                                  .then((listContent) {
                                Preferences.remPref(
                                    'liste-${listen.elementAt(editIndex)}');
                                listen[editIndex] = textEditingController.text;
                                Preferences.setPrefList('listen', listen);
                                Preferences.setPrefList(
                                    'liste-${listen.elementAt(editIndex)}',
                                    listContent);
                                textEditingController.text = '';
                                editIndex = -1;
                              });
                            });
                          }
                        } else {
                          Snackbar().show(context,
                              localizations.generalFieldMustNotBeEmpty);
                        }
                      }),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: editIndex != -1,
                    child: Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                textEditingController.text = '';
                                editIndex = -1;
                              });
                            }),
                        const SizedBox(width: 10),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ]));
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int index, String key) async {
    final localizations = AppLocalizations.of(context)!;

    if (key == 'listen' && !selectedAskListDeletionValue) {
      deleteSpecificPrefData(context, index, key);
    } else {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.dialogConfirmTitle,
                style: TextStyle(fontSize: 20)),
            content: Text(localizations.dialogConfirmSubtitle),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(localizations.dialogCancel),
              ),
              TextButton(
                onPressed: () {
                  deleteSpecificPrefData(context, index, key);
                  Navigator.pop(context);
                },
                child: Text(localizations.dialogOk),
              ),
            ],
          );
        },
      );
    }
  }

  void deleteSpecificPrefData(BuildContext context, int index, String key) {
    if (key == 'listen') {
      if (index == -2) {
        setState(() {
          for (int i = 0; i <= listen.length - 1; i++) {
            Preferences.remPref('liste-${listen[i]}');
          }
          Preferences.remPref(key);
          listen.clear();
        });
      } else {
        setState(() {
          Preferences.remPref('liste-${listen.elementAt(index)}');
          listen.removeAt(index);
          Preferences.setPrefList(key, listen);
        });
      }
    } else {
      Snackbar().show(context, 'How did we get here?');
    }
  }
}
