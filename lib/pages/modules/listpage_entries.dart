import 'dart:async';
import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../utils/preferences.dart';
import '../../utils/snackbar.dart';

class ListPageEntries extends StatefulWidget {
  final String listenname;

  const ListPageEntries({super.key, required this.listenname});

  @override
  State<ListPageEntries> createState() => _ListPageEntriesState();
}

class _ListPageEntriesState extends State<ListPageEntries> {
  List<String> liste = [];
  TextEditingController textEditingController = TextEditingController();
  int editIndex = -1;
  bool selectedReorderValue = true;
  bool listEntryDeletionValue = true;

  @override
  void initState() {
    super.initState();
    editIndex = -1;
    speechToText = SpeechToText();
    Preferences.getPrefList('liste-${widget.listenname}').then((listeninhalt) {
      setState(() {
        liste = listeninhalt;
      });
    });
    Preferences.getPrefBool('reorder').then((value) {
      setState(() {
        selectedReorderValue = value;
      });
    });
    Preferences.getPrefBool('list-entry-deletion').then((value) {
      setState(() {
        listEntryDeletionValue = value;
      });
    });
  }

  Future<void> _startListening() async {
    final localizations = AppLocalizations.of(context)!;
    if (!speechToText.isListening) {
      bool available = await speechToText.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            _showListeningDialog(context);
          }
        },
        onError: (errorNotification) {
          if (dialogOpen) {
            dialogOpen = false;
            Navigator.pop(context);
          }
        },
      );

      if (available) {
        speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              if (result.recognizedWords != "") {
                List<String> newItems = result.recognizedWords.split(localizations.sTTSeperateWord);

                for (int i = 0; i < newItems.length; i++) {
                  setState(() {
                    liste.add(newItems[i]);
                  });
                }
                Preferences.setPrefList('liste-${widget.listenname}', liste);
              }
              if (dialogOpen) {
                dialogOpen = false;
                Navigator.pop(context);
              }
            }
          },
        );
      }
    } else {
      speechToText.stop();
      if (dialogOpen) {
        dialogOpen = false;
        Navigator.pop(context);
      }
    }
  }

  void toggleSwitchReorder() {
    setState(() {
      selectedReorderValue = !selectedReorderValue;
      Preferences.setPrefBool('reorder', selectedReorderValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              Row(
                children: [
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(widget.listenname,
                          style: const TextStyle(fontSize: 50))),
                  PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        toggleSwitchReorder();
                      }
                      if (value == 2) {
                        _showDeleteDialog(
                            context, -2, 'liste-${widget.listenname}');
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
              liste.isNotEmpty
                  ? Expanded(
                      child: ReorderableListView.builder(
                        itemCount: liste.length,
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
                                            liste.elementAt(index);
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
                                      _showDeleteDialog(context, index,
                                          'liste-${widget.listenname}');
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  liste.elementAt(index),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: Visibility(
                                  visible: selectedReorderValue,
                                  child: ReorderableDragStartListener(
                                      index: index,
                                      child: const Icon(Icons.menu)),
                                ),
                              ),
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final String item = liste.removeAt(oldIndex);
                            liste.insert(newIndex, item);
                            Preferences.setPrefList(
                                'liste-${widget.listenname}', liste);
                          });
                        },
                      ),
                    )
                  : Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(localizations.generalNoEntriesFound),
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
                                liste.add(textEditingController.text);
                                textEditingController.text = '';
                                Preferences.setPrefList(
                                    'liste-${widget.listenname}', liste);
                              });
                            } else {
                              setState(() {
                                liste[editIndex] = textEditingController.text;
                                Preferences.setPrefList(
                                    'liste-${widget.listenname}', liste);
                                textEditingController.text = '';
                                editIndex = -1;
                              });
                            }
                          } else {
                            Snackbar()
                                .show(context, localizations.generalFieldMustNotBeEmpty);
                          }
                        },
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: editIndex == -1
                              ? localizations.listpageAddItem
                              : localizations.listpageEditItem
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
                                  liste.add(textEditingController.text);
                                  textEditingController.text = '';
                                  Preferences.setPrefList(
                                      'liste-${widget.listenname}', liste);
                                });
                              } else {
                                setState(() {
                                  liste[editIndex] = textEditingController.text;
                                  Preferences.setPrefList(
                                      'liste-${widget.listenname}', liste);
                                  textEditingController.text = '';
                                  editIndex = -1;
                                });
                              }
                            } else {
                              Snackbar()
                                  .show(context, localizations.generalFieldMustNotBeEmpty);
                            }
                          }),
                      const SizedBox(width: 10),
                      IconButton(
                          icon: editIndex == -1
                              ? const Icon(Icons.mic)
                              : const Icon(Icons.cancel),
                          onPressed: () {
                            if (editIndex == -1) {
                              _startListening();
                            } else {
                              setState(() {
                                editIndex = -1;
                                textEditingController.text = '';
                              });
                            }
                          }),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              )
            ])));
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int index, String key) async {
    if (!listEntryDeletionValue) {
      if (index == -2) {
        setState(() {
          liste.clear();
          Preferences.setPrefList(key, liste);
        });
      } else {
        setState(() {
          liste.removeAt(index);
          Preferences.setPrefList(key, liste);
        });
      }
    } else {
      final localizations = AppLocalizations.of(context)!;
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.dialogConfirmTitle, style: TextStyle(fontSize: 20)),
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
                  if (index == -2) {
                    setState(() {
                      liste.clear();
                      Preferences.setPrefList(key, liste);
                    });
                  } else {
                    setState(() {
                      liste.removeAt(index);
                      Preferences.setPrefList(key, liste);
                    });
                  }
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

  bool dialogOpen = false;
  late SpeechToText speechToText;

  void _showListeningDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.dialogSTTTitle,
              style: TextStyle(fontSize: 20)),
          content:
              Text(localizations.dialogSTTSubtitle),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                speechToText.cancel();
                dialogOpen = false;
                Navigator.pop(context);
              },
              child: Text(localizations.dialogCancel),
            ),
          ],
        );
      },
    );
  }
}
