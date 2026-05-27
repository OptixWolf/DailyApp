import 'dart:async';
import 'dart:ui';
import 'package:DailyApp/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/preferences.dart';
import '../utils/snackbar.dart';
import 'listpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int currentPageIndex = 0;
  List<String> listen = [];
  List<String> timeListen = [];
  TextEditingController textEditingController = TextEditingController();
  Random random = Random();
  int editIndex = -1;
  int editIndex2 = -1;
  late DateTime now;
  late Timer timer;

  String selectedLanguageValue = '';
  bool selectedDarkmodeValue = true;
  bool selectedAskListDeletionValue = true;
  bool selectedAskListEntryDeletionValue = true;
  bool selectedAskTimeDeletionValue = true;
  bool selectedReorderValue = true;

  @override
  void initState() {
    super.initState();
    editIndex = -1;
    editIndex2 = -1;
    selectedLanguageValue = PlatformDispatcher.instance.locale.languageCode;
    Preferences.getPrefString('language').then((languageValue) {
      setState(() {
        selectedLanguageValue = languageValue;
      });
    });
    Preferences.getPrefBool('darkmode').then((darkmodeValue) {
      setState(() {
        selectedDarkmodeValue = darkmodeValue;
      });
    });
    Preferences.getPrefBool('list-deletion').then((listDeletionValue) {
      setState(() {
        selectedAskListDeletionValue = listDeletionValue;
      });
    });
    Preferences.getPrefBool('list-entry-deletion')
        .then((listEntryDeletionValue) {
      setState(() {
        selectedAskListEntryDeletionValue = listEntryDeletionValue;
      });
    });
    Preferences.getPrefBool('time-deletion').then((timeDeletionValue) {
      setState(() {
        selectedAskTimeDeletionValue = timeDeletionValue;
      });
    });
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
    Preferences.getPrefList('times').then((timeList) {
      setState(() {
        timeListen = timeList;
      });
    });

    now = DateTime.now();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  void saveSettings() {
    setState(() {
      Preferences.setPrefString('language', selectedLanguageValue);
      Preferences.setPrefBool('darkmode', selectedDarkmodeValue);
      Preferences.setPrefBool('list-deletion', selectedAskListDeletionValue);
      Preferences.setPrefBool('list-entry-deletion', selectedAskListEntryDeletionValue);
      Preferences.setPrefBool('time-deletion', selectedAskTimeDeletionValue);
      Phoenix.rebirth(context);
    });
  }

  void setLanguage(String languageCode) {
    setState(() {
      selectedLanguageValue = languageCode;
    });
  }

  void toggleSwitchDarkmode() {
    setState(() {
      selectedDarkmodeValue = !selectedDarkmodeValue;
    });
  }

  void toggleSwitchAskListDeletion() {
    setState(() {
      selectedAskListDeletionValue = !selectedAskListDeletionValue;
    });
  }

  void toggleSwitchAskListEntryDeletion() {
    setState(() {
      selectedAskListEntryDeletionValue = !selectedAskListEntryDeletionValue;
    });
  }

  void toggleSwitchAskTimeDeletion() {
    setState(() {
      selectedAskTimeDeletionValue = !selectedAskTimeDeletionValue;
    });
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
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: localizations.categoryLists,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.timer_outlined),
            icon: const Icon(Icons.timer),
            label: localizations.categoryCounters,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.settings_outlined),
            icon: const Icon(Icons.settings),
            label: localizations.categorySettings,
          ),
        ],
      ),
      appBar: AppBar(),
      floatingActionButton: Visibility(
        visible: currentPageIndex == 2,
        child: FloatingActionButton.extended(
          onPressed: () {
            saveSettings();
          },
          label: Text(localizations.generalFabTitle),
          icon: Icon(Icons.save),
        ),
      ),
      body: <Widget>[
        /// Listen
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              Row(
                children: [
                  const SizedBox(width: 7),
                  Expanded(
                      child: Text(localizations.categoryLists, style: const TextStyle(fontSize: 50))),
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
                                      _showDeleteDialog(
                                          context, index, 'listen');
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
                                      index: index,
                                      child: const Icon(Icons.menu)),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ListPage(
                                          listenname:
                                              listen.elementAt(index))));
                                },
                              ),
                            ),
                          );
                        },
                        onReorder: (oldIndex, newIndex) {
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
                                if (!listen
                                    .contains(textEditingController.text)) {
                                  listen.add(textEditingController.text);
                                  textEditingController.text = '';
                                  Preferences.setPrefList('listen', listen);
                                  Preferences.setPrefList(
                                      'liste-${textEditingController.text}',
                                      []);
                                } else {
                                  Snackbar().show(context, localizations.listsNameMustNotBeDuplicate);
                                }
                              });
                            } else {
                              setState(() {
                                Preferences.getPrefList(
                                        'liste-${listen.elementAt(editIndex)}')
                                    .then((listContent) {
                                  Preferences.remPref(
                                      'liste-${listen.elementAt(editIndex)}');
                                  listen[editIndex] =
                                      textEditingController.text;
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
                            Snackbar()
                                .show(context, localizations.generalFieldMustNotBeEmpty);
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
                                        'liste-${textEditingController.text}',
                                        []);
                                  } else {
                                    Snackbar().show(context, localizations.listsNameMustNotBeDuplicate);
                                  }
                                });
                              } else {
                                setState(() {
                                  Preferences.getPrefList(
                                          'liste-${listen.elementAt(editIndex)}')
                                      .then((listContent) {
                                    Preferences.remPref(
                                        'liste-${listen.elementAt(editIndex)}');
                                    listen[editIndex] =
                                        textEditingController.text;
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
                              Snackbar()
                                  .show(context, localizations.generalFieldMustNotBeEmpty);
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
            ])),

        /// Zeitzähler
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
              Row(
                children: [
                  const SizedBox(width: 7),
                  Expanded(
                      child:
                          Text(localizations.categoryCounters, style: const TextStyle(fontSize: 50))),
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
                          Duration thisDifference =
                              now.difference(thisDateTime);

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
                                      _showDeleteDialog(
                                          context, index, 'times');
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(thisName),
                                subtitle: Text(localizations.counterRunningFor(thisDifference.inDays, thisDifference.inHours - (thisDifference.inDays * 24), thisDifference.inMinutes - (thisDifference.inHours * 60), thisDifference.inSeconds - (thisDifference.inMinutes * 60))),
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
                            final String item = timeListen.removeAt(oldIndex);
                            timeListen.insert(newIndex, item);
                            Preferences.setPrefList('times', timeListen);
                          });
                        },
                      ),
                    )
                  : Expanded(
                      child: Card(
                        child: ListTile(title: Text(localizations.generalNoEntriesFound)),
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
                            Snackbar()
                                .show(context, localizations.generalFieldMustNotBeEmpty);
                          }
                        },
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: editIndex2 == -1
                              ? localizations.countersExampleName
                              : localizations.countersEditFieldText
                        ),
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
                              Snackbar()
                                  .show(context, localizations.generalFieldMustNotBeEmpty);
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
            ])),

        // Einstellungsseite
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(children: [
                  const SizedBox(width: 7),
                  Text(localizations.categorySettings, style: const TextStyle(fontSize: 50)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                Row(children: [
                  const SizedBox(width: 7),
                  Text(localizations.settingsTitleGeneral,
                      style: const TextStyle(fontSize: 25)),
                ]),
                Card(
                    child: ListTile(
                  title: Text(localizations.settingsRepoTitle),
                  subtitle: Text(localizations.settingsRepoSubtitle),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _launchURL(
                        'https://github.com/OptixWolf/DailyApp/releases/latest');
                  },
                )),
                Card(
                    child: ListTile(
                  title: const Text('Language'),
                  subtitle: const Text('Change the app language'),
                  trailing: DropdownButton<Locale>(
                    value: selectedLanguageValue != ""
                        ? Locale(selectedLanguageValue, '')
                        : Locale(
                            PlatformDispatcher.instance.locale.languageCode),
                    items: AppLocalizations.supportedLocales.map((locale) {
                      final label = switch (locale.languageCode) {
                        'de' => 'Deutsch',
                        'en' => 'English',
                        _ => locale.languageCode.toUpperCase(),
                      };

                      return DropdownMenuItem(
                        value: locale,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (Locale? newValue) {
                      if (newValue != null) {
                        setLanguage(newValue.languageCode);
                      }
                    },
                  ),
                )),
                Card(
                    child: ListTile(
                  title: Text(localizations.settingsDarkmodeTitle),
                  subtitle: Text(localizations.settingsDarkmodeSubtitle),
                  trailing: Switch(
                    value: selectedDarkmodeValue,
                    onChanged: (value) {
                      toggleSwitchDarkmode();
                    },
                  ),
                  onTap: () {
                    toggleSwitchDarkmode();
                  },
                )),
                Card(
                    child: ExpansionTile(
                  title: Text(localizations.settingsConfirmationsForDeletion),
                  children: [
                    Card(
                        child: ListTile(
                      title: Text(localizations.settingsConfirmationListDeletionTitle),
                      subtitle: Text(localizations.settingsConfirmationListDeletionSubtitle),
                      trailing: Switch(
                        value: selectedAskListDeletionValue,
                        onChanged: (value) {
                          toggleSwitchAskListDeletion();
                        },
                      ),
                      onTap: () {
                        toggleSwitchAskListDeletion();
                      },
                    )),
                    Card(
                        child: ListTile(
                      title: Text(localizations.settingsConfirmationListEntryDeletionTitle),
                      subtitle: Text(localizations.settingsConfirmationListEntryDeletionSubtitle),
                      trailing: Switch(
                        value: selectedAskListEntryDeletionValue,
                        onChanged: (value) {
                          toggleSwitchAskListEntryDeletion();
                        },
                      ),
                      onTap: () {
                        toggleSwitchAskListEntryDeletion();
                      },
                    )),
                    Card(
                        child: ListTile(
                      title: Text(localizations.settingsConfirmationCounterDeletionTitle),
                      subtitle: Text(localizations.settingsConfirmationCounterDeletionSubtitle),
                      trailing: Switch(
                        value: selectedAskTimeDeletionValue,
                        onChanged: (value) {
                          toggleSwitchAskTimeDeletion();
                        },
                      ),
                      onTap: () {
                        toggleSwitchAskTimeDeletion();
                      },
                    )),
                  ],
                ))
              ],
            ),
          ),
        )
      ][currentPageIndex],
    );
  }

  _launchURL(String url) async {
    final localizations = AppLocalizations.of(context)!;
    final Uri finalUrl = Uri.parse(url);
    if (!await launchUrl(finalUrl)) {
      throw Exception(localizations.launchUrlFailed(finalUrl.toString()));
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context, int index, String key) async {
      final localizations = AppLocalizations.of(context)!;

    if (key == 'listen' && !selectedAskListDeletionValue) {
      deleteSpecificPrefData(context, index, key);
    } else if (key == 'times' && !selectedAskTimeDeletionValue) {
      deleteSpecificPrefData(context, index, key);
    } else {
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
    } else if (key == 'times') {
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

  Future<void> _showResetConfirmationDialog(
      BuildContext context, int index, String key, String thisName) async {
        final localizations = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.dialogConfirmTitle, style: TextStyle(fontSize: 20)),
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
}
