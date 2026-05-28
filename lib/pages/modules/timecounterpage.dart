import 'dart:async';
import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../utils/preferences.dart';
import '../../utils/snackbar.dart';

class TimeCounterPage extends StatefulWidget {
  const TimeCounterPage({super.key});

  @override
  State<TimeCounterPage> createState() => _TimeCounterPageState();
}

class _TimeCounterPageState extends State<TimeCounterPage> {
  List<String> timeListen = [];
  TextEditingController textEditingController = TextEditingController();
  int editIndex = -1;
  int editIndex2 = -1;
  late DateTime now;
  late Timer timer;

  bool selectedAskTimeDeletionValue = true;
  bool selectedReorderValue = true;

  @override
  void initState() {
    super.initState();
    Preferences.getPrefBool('reorder').then((reorderValue) {
      setState(() {
        selectedReorderValue = reorderValue;
      });
    });
    Preferences.getPrefList('times').then((timeList) {
      setState(() {
        timeListen = timeList;
      });
    });
    Preferences.getPrefBool('time-deletion').then((timeDeletionValue) {
      setState(() {
        selectedAskTimeDeletionValue = timeDeletionValue;
      });
    });

    now = DateTime.now();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Stop the timer before the widget is destroyed
    super.dispose();
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
                  child: Text(localizations.categoryCounters,
                      style: const TextStyle(fontSize: 50))),
              PopupMenuButton<int>(
                onSelected: (value) {
                  if (value == 1) {
                    toggleSwitchReorder();
                  }
                  if (value == 2) {
                    _showDeleteDialog(context, -2, 'times');
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
          timeListen.isNotEmpty
              ? Expanded(
                  child: ReorderableListView.builder(
                    itemCount: timeListen.length,
                    itemBuilder: (context, index) {
                      final thisDateTime = DateTime.parse(timeListen
                          .elementAt(index)
                          .substring(
                              0, timeListen.elementAt(index).indexOf('|')));
                      final thisName = timeListen
                          .elementAt(index)
                          .replaceAll('$thisDateTime|', '');
                      Duration thisDifference = now.difference(thisDateTime);

                      return Card(
                        key: Key('$index'),
                        child: Slidable(
                          key: Key('$index'),
                          startActionPane: ActionPane(
                            extentRatio: 0.8,
                            motion: const BehindMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  setState(() {
                                    editIndex2 = index;
                                    textEditingController.text = thisName;
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
                                  _showDateTimeDialog(context, thisDateTime,
                                      timeListen, index, 'times');
                                },
                                backgroundColor: Colors.green,
                                icon: Icons.timer,
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  _showResetConfirmationDialog(
                                      context, index, 'times', thisName);
                                },
                                backgroundColor: Colors.amber,
                                icon: Icons.restart_alt,
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  _showDeleteDialog(context, index, 'times');
                                },
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(thisName),
                            subtitle: Text(localizations.counterRunningFor(
                                thisDifference.inDays,
                                thisDifference.inHours -
                                    (thisDifference.inDays * 24),
                                thisDifference.inMinutes -
                                    (thisDifference.inHours * 60),
                                thisDifference.inSeconds -
                                    (thisDifference.inMinutes * 60))),
                            trailing: Visibility(
                              visible: selectedReorderValue,
                              child: ReorderableDragStartListener(
                                  index: index, child: const Icon(Icons.menu)),
                            ),
                          ),
                        ),
                      );
                    },
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final String item = timeListen.removeAt(oldIndex);
                        timeListen.insert(newIndex, item);
                        Preferences.setPrefList('times', timeListen);
                      });
                    },
                  ),
                )
              : Expanded(
                  child: Card(
                    child: ListTile(
                        title: Text(localizations.generalNoEntriesFound)),
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
                        if (editIndex2 == -1) {
                          setState(() {
                            timeListen.add(
                                '${DateTime.now()}|${textEditingController.text}');
                            textEditingController.text = '';
                            Preferences.setPrefList('times', timeListen);
                          });
                        } else {
                          setState(() {
                            timeListen[editIndex2] =
                                '${timeListen.elementAt(editIndex2).substring(0, timeListen.elementAt(editIndex2).indexOf('|'))}|${textEditingController.text}';
                            Preferences.setPrefList('times', timeListen);
                            textEditingController.text = '';
                            editIndex2 = -1;
                          });
                        }
                      } else {
                        Snackbar().show(
                            context, localizations.generalFieldMustNotBeEmpty);
                      }
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: editIndex2 == -1
                            ? localizations.countersExampleName
                            : localizations.countersEditFieldText),
                  )),
                  const SizedBox(width: 10),
                  IconButton(
                      icon: editIndex2 == -1
                          ? const Icon(Icons.add)
                          : const Icon(Icons.create),
                      onPressed: () {
                        if (textEditingController.text.isNotEmpty) {
                          if (editIndex2 == -1) {
                            setState(() {
                              timeListen.add(
                                  '${DateTime.now()}|${textEditingController.text}');
                              textEditingController.text = '';
                              Preferences.setPrefList('times', timeListen);
                            });
                          } else {
                            setState(() {
                              timeListen[editIndex2] =
                                  '${timeListen.elementAt(editIndex2).substring(0, timeListen.elementAt(editIndex2).indexOf('|'))}|${textEditingController.text}';
                              Preferences.setPrefList('times', timeListen);
                              textEditingController.text = '';
                              editIndex2 = -1;
                            });
                          }
                        } else {
                          Snackbar().show(context,
                              localizations.generalFieldMustNotBeEmpty);
                        }
                      }),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: editIndex2 != -1,
                    child: Row(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              setState(() {
                                textEditingController.text = '';
                                editIndex2 = -1;
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

    if (key == 'times' && !selectedAskTimeDeletionValue) {
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
    if (key == 'times') {
      if (index == -2) {
        setState(() {
          Preferences.remPref(key);
          timeListen.clear();
        });
      } else {
        setState(() {
          timeListen.removeAt(index);
          Preferences.setPrefList(key, timeListen);
        });
      }
    } else {
      Snackbar().show(context, 'How did we get here?');
    }
  }

  Future<void> _showDateTimeDialog(BuildContext context, DateTime dateTime,
      List<String> liste, int index, String key) async {
    final localizations = AppLocalizations.of(context)!;
    TextEditingController textFieldController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime));

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.dialogCounterChangeDateTime,
              style: TextStyle(fontSize: 20)),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: 'yyyy-MM-dd HH:mm:ss'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(localizations.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                if (textFieldController.text != "") {
                  try {
                    final newDateTime =
                        DateTime.parse(textFieldController.text);
                    liste[index] =
                        '$newDateTime|${liste[index].substring(liste[index].indexOf('|') + 1)}';
                    Preferences.setPrefList(key, liste);
                  } catch (ex) {
                    Snackbar().show(context, localizations.dialogInvalidInput);
                  } finally {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(localizations.dialogOk),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetConfirmationDialog(
      BuildContext context, int index, String key, String thisName) async {
    final localizations = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.dialogConfirmTitle,
              style: TextStyle(fontSize: 20)),
          content: Text(localizations.dialogResetSubtitle),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(localizations.dialogCancel),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  timeListen[index] = '${DateTime.now().toString()}|$thisName';
                  Preferences.setPrefList('times', timeListen);
                });
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
