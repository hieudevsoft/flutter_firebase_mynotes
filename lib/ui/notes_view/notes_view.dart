import 'package:flutter/material.dart';
import 'package:mynotes/controller/firebase/auth.dart';
import 'package:mynotes/controller/note_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _noteService;
  String get userEmail => getCurrentUser().email!;

  @override
  void initState() {
    _noteService = NotesService();
    _noteService.open();
    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text("Log out")),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  shouldLogOut.runIfTrue(() {
                    logout();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  });
                  break;
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: userEmail),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder(
              stream: _noteService.allNotes,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Waiting for all notes coming...');
                  default:
                    return const Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                }
              },
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

enum MenuAction { logout }

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out ?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes')),
        ],
      );
    },
    barrierDismissible: false,
    barrierLabel: "Log out?",
    useSafeArea: true,
  ).then((value) => value ?? false);
}

extension Extension on bool {
  bool runIfTrue(Function t) {
    if (this) t.call();
    return this;
  }

  bool runIfFalse(Function t) {
    if (!this) t.call();
    return this;
  }
}
