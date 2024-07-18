import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  // ignore: prefer_const_constructors
  runApp(Phoenix(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Preferences.getPref('darkmode'),
      builder: (context, themeModeSnapshot) {
        final currentThemeMode = themeModeSnapshot.data ?? ThemeMode.system;

        return MaterialApp(
          title: 'DailyApp',
          home: const Homepage(),
          themeMode:
              currentThemeMode == true ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light(
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(
            useMaterial3: true,
          ),
        );
      },
    );
  }
}

class Preferences {
  static Future<bool> getPref(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool value = prefs.getBool(key) ?? true;
    return value;
  }

  static Future<void> setPref(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<List<String>> getPrefList(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> value = prefs.getStringList(key) ?? [];
    return value;
  }

  static Future<void> setPrefList(String key, List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<void> remPref(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

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

  bool selectedDarkmodeValue = true;
  bool selectedReorderValue = true;

  @override
  void initState() {
    super.initState();
    editIndex = -1;
    editIndex2 = -1;
    Preferences.getPref('darkmode').then((darkmodeValue) {
      setState(() {
        selectedDarkmodeValue = darkmodeValue;
      });
    });
    Preferences.getPref('reorder').then((reorderValue) {
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

  void toggleSwitchDarkmode() {
    setState(() {
      selectedDarkmodeValue = !selectedDarkmodeValue;
      Preferences.setPref('darkmode', selectedDarkmodeValue);
      Phoenix.rebirth(context);
    });
  }

  void toggleSwitchReorder() {
    setState(() {
      selectedReorderValue = !selectedReorderValue;
      Preferences.setPref('reorder', selectedReorderValue);
    });
  }

  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Listen',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.timer_outlined),
            icon: Icon(Icons.timer),
            label: 'Zeitzähler',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings_outlined),
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
      appBar: AppBar(),
      body: <Widget>[
        /// Listen
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(width: 7),
                  Text('Listen', style: TextStyle(fontSize: 50)),
                ],
              ),
              const SizedBox(height: 25),
                    listen.isNotEmpty ? Expanded(
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
                                            textEditingController.text = listen.elementAt(index);
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
                                        _showDeleteDialog(context, index, listen, 'listen');
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
                                          builder: (context) => ListPage(listenname: listen.elementAt(index))));
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
                    ) : const Expanded(
                      child: Card(child: ListTile(
                                  title: Text('Keine Listen vorhanden'),
                            ),
                          ),
                    ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Flexible(child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: editIndex == -1 ? 'Einkaufsliste' : 'Neuer Text zum bearbeiten',
                        ),
                      )),
                      const SizedBox(width: 10),
                      IconButton(icon: editIndex == -1 ? const Icon(Icons.add) : const Icon(Icons.create), onPressed: () {
                        if(textEditingController.text.isNotEmpty)
                        {
                          if(editIndex == -1)
                          {
                          setState(() {
                            if(!listen.contains(textEditingController.text))
                            {
                              listen.add(textEditingController.text);
                              textEditingController.text = '';
                              Preferences.setPrefList('listen', listen);
                              Preferences.setPrefList('liste-${textEditingController.text}', []);
                            } else {
                              _showSnackbar(context, 'Name darf nicht doppelt vorkommen!');
                            }
                          });
                          } else {
                            setState(() {
                              Preferences.getPrefList('liste-${listen.elementAt(editIndex)}').then((listContent) {
                                Preferences.remPref('liste-${listen.elementAt(editIndex)}');
                                listen[editIndex] = textEditingController.text;
                                Preferences.setPrefList('listen', listen);
                                Preferences.setPrefList('liste-${listen.elementAt(editIndex)}', listContent);
                                textEditingController.text = '';
                                editIndex = -1;
                            });
                          });
                        }} else {
                          _showSnackbar(context, 'Feld darf nicht leer sein!');
                        }
                      }),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: editIndex != -1,
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.cancel), onPressed: () {
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
            ]
          )
        ),

        /// Zeitzähler
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Row(
                children: [
                  SizedBox(width: 7),
                  Text('Zeitzähler', style: TextStyle(fontSize: 50)),
                ],
              ),
              const SizedBox(height: 25),
                    timeListen.isNotEmpty ?
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: timeListen.length,
                        itemBuilder: (context, index) {

                          final thisDateTime = DateTime.parse(timeListen.elementAt(index).substring(0, timeListen.elementAt(index).indexOf('|')));
                          final thisName = timeListen.elementAt(index).replaceAll('$thisDateTime|', '');
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
                                        _showDateTimeDialog(context, thisDateTime, timeListen, index, 'times');
                                      },
                                      backgroundColor: Colors.green,
                                      icon: Icons.timer,
                                    ),
                                    SlidableAction(
                                      onPressed: (context) {
                                        setState(() {
                                          timeListen[index] = '${DateTime.now().toString()}|$thisName';
                                          Preferences.setPrefList('times', timeListen);
                                        });
                                      },
                                      backgroundColor: Colors.amber,
                                      icon: Icons.restart_alt,
                                    ),
                                    SlidableAction(
                                      onPressed: (context) {
                                        _showDeleteDialog(context, index, timeListen, 'times');
                                      },
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                    ),
                                ],
                              ),
                              child: ListTile(
                              title: Text(thisName),
                              subtitle: Text('Am laufen seit: ${thisDifference.inDays}d ${thisDifference.inHours - (thisDifference.inDays * 24)}h ${thisDifference.inMinutes - (thisDifference.inHours * 60)}min ${thisDifference.inSeconds - (thisDifference.inMinutes * 60)}s'),
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
                    ) : const Expanded(
                      child: Card(
                        child: ListTile(title: Text('Keine Einträge gefunden')),
                        ),
                        ),
                    Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Flexible(child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: editIndex2 == -1 ? 'Name' : 'Neuer Text zum bearbeiten',
                        ),
                      )),
                      const SizedBox(width: 10),
                      IconButton(icon: editIndex2 == -1 ? const Icon(Icons.add) : const Icon(Icons.create), onPressed: () {
                        if(textEditingController.text.isNotEmpty)
                        {
                          if(editIndex2 == -1)
                          {
                          setState(() {
                              timeListen.add('${DateTime.now()}|${textEditingController.text}');
                              textEditingController.text = '';
                              Preferences.setPrefList('times', timeListen);
                          });
                          } else {
                            setState(() {
                                timeListen[editIndex2] = '${timeListen.elementAt(editIndex2).substring(0, timeListen.elementAt(editIndex2).indexOf('|'))}|${textEditingController.text}';
                                Preferences.setPrefList('times', timeListen);
                                textEditingController.text = '';
                                editIndex2 = -1;
                          });
                        }} else {
                          _showSnackbar(context, 'Feld darf nicht leer sein!');
                        }
                      }),
                      const SizedBox(width: 10),
                      Visibility(
                        visible: editIndex2 != -1,
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.cancel), onPressed: () {
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
            ]
          )
        ),

        // Einstellungsseite
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(children: [
                  SizedBox(width: 7),
                  Text('Einstellungen', style: TextStyle(fontSize: 50)),
                ]),
                const SizedBox(
                  height: 25,
                ),
                const Row(children: [
                  SizedBox(width: 7),
                  Text('Allgemeine Einstellungen',
                      style: TextStyle(fontSize: 25)),
                ]),
                Card(
                    child: ListTile(
                  title: const Text('Schaue nach Updates (Extern)'),
                  subtitle: const Text(
                      'Schau ob es eine neue Version der App gibt'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _launchURL('https://github.com/OptixWolf/DailyApp/releases/latest');
                  },
                )),
                Card(
                    child: ListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text(
                      'Wenn deaktiviert, benutzt die App das helle Design'),
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
                    child: ListTile(
                  title: const Text('Erlaube Listensortierung'),
                  subtitle: const Text(
                      'Wenn aktiviert, kann man die Listen neu anordnen'),
                  trailing: Switch(
                    value: selectedReorderValue,
                    onChanged: (value) {
                      toggleSwitchReorder();
                    },
                  ),
                  onTap: () {
                    toggleSwitchReorder();
                  },
                ))
              ],
            ),
          ),
        )
      ][currentPageIndex],
    );
  }

  _launchURL(String url) async {
  final Uri finalUrl = Uri.parse(url);
  if (!await launchUrl(finalUrl)) {
    throw Exception('Could not launch $finalUrl');
  }
  }

    Future<void> _showDeleteDialog(BuildContext context, int index, List<String> list, String key) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bestätige',
              style: TextStyle(fontSize: 20)),
          content: const Text('Möchtest du das wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if(key == 'listen')
                {
                  setState(() {
                    Preferences.remPref('liste-${list.elementAt(index)}');
                    list.removeAt(index);
                    Preferences.setPrefList(key, list);
                  });
                }
                else
                {
                  setState(() {
                    list.removeAt(index);
                    Preferences.setPrefList(key, list);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

    Future<void> _showDateTimeDialog(BuildContext context, DateTime dateTime, List<String> liste, int index, String key) async {
    TextEditingController textFieldController =
        TextEditingController(text: DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime));

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Auf welchen Zeitpunkt willst du ändern?',
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
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if (textFieldController.text != "") {   
                  try {
                    final newDateTime = DateTime.parse(textFieldController.text);
                    liste[index] = '$newDateTime|${liste[index].substring(liste[index].indexOf('|') + 1)}';
                    Preferences.setPrefList(key, liste);
                  } catch (ex) {
                    _showSnackbar(context, 'Ungültige Eingabe');
                  } finally {
                    Navigator.pop(context);
                  }
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

bool dialogOpen = false;
late SpeechToText speechToText;

class ListPage extends StatefulWidget {
  final String listenname;

  const ListPage({super.key, required this.listenname});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<String> liste = [];
  TextEditingController textEditingController = TextEditingController();
  int editIndex = -1;
  bool selectedReorderValue = true;

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
    Preferences.getPref('reorder').then((value) {
      setState(() {
        selectedReorderValue = value;
      });
    });
  }

  Future<void> _startListening() async {
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
                List<String> newItems = result.recognizedWords.split(' und ');

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 7),
                  Text(widget.listenname, style: const TextStyle(fontSize: 50)),
                ],
              ),
              const SizedBox(height: 25),
              liste.isNotEmpty ? Expanded(
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
                                          textEditingController.text = liste.elementAt(index);
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
                                        _showDeleteDialog(context, index, liste, 'liste-${widget.listenname}');
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
                              Preferences.setPrefList('liste-${widget.listenname}', liste);
                            });
                        },
                      ),
                    ) : const Expanded(
                      child: Card(child: ListTile(
                                  title: Text('Keine Einträge vorhanden'),
                            ),
                          ),
                    ),
                    Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Flexible(child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: editIndex == -1 ? 'Füge etwas hinzu...' : 'Neuer Text zum bearbeiten',
                        ),
                      )),
                      const SizedBox(width: 10),
                      IconButton(icon: editIndex == -1 ? const Icon(Icons.add) : const Icon(Icons.create), onPressed: () {
                        if(textEditingController.text.isNotEmpty)
                        {
                          if(editIndex == -1)
                          {
                          setState(() {
                              liste.add(textEditingController.text);
                              textEditingController.text = '';
                              Preferences.setPrefList('liste-${widget.listenname}', liste);
                          });
                          } else {
                            setState(() {
                              liste[editIndex] = textEditingController.text;
                              Preferences.setPrefList('liste-${widget.listenname}', liste);
                              textEditingController.text = '';
                              editIndex = -1;
                            });
                          }
                        } else {
                          _showSnackbar(context, 'Feld darf nicht leer sein!');
                        }
                      }),
                      const SizedBox(width: 10),
                      IconButton(icon: editIndex == -1 ? const Icon(Icons.mic) : const Icon(Icons.cancel), onPressed: () {
                        if(editIndex == -1)
                        {
                          _startListening();
                        }
                        else {
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
    ])
    )
    );
  }

      Future<void> _showDeleteDialog(BuildContext context, int index, List<String> list, String key) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bestätige',
              style: TextStyle(fontSize: 20)),
          content: const Text('Möchtest du das wirklich löschen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                if(key == 'listen')
                {
                  setState(() {
                    Preferences.remPref('liste-${list.elementAt(index)}');
                    list.removeAt(index);
                    Preferences.setPrefList(key, list);
                  });
                }
                else
                {
                  setState(() {
                    list.removeAt(index);
                    Preferences.setPrefList(key, list);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

  void _showSnackbar(BuildContext context, String snackbarContent) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(snackbarContent),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void _showListeningDialog(BuildContext context) {
  dialogOpen = true;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Du kannst jetzt sprechen', style: TextStyle(fontSize: 20)),
        content: const Text('Mit dem Wort "und" kannst du deine Einträge trennen'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              speechToText.cancel();
              dialogOpen = false;
              Navigator.pop(context);
            },
            child: const Text('Abbrechen'),
          ),
        ],
      );
    },
  );
}