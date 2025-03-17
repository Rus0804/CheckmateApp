//IMPORTS
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import 'self_game.dart';
import '../Firebase/db_game.dart';
import '../Firebase/db_social.dart';

//Main widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserState userState;
  List<Map<String, dynamic>> sentMap = [];
  List<Map<String, dynamic>> recievedMap = [];
  List<Map<String, dynamic>> gamesMap = [];

  fetchUsers() async {
    var sent = await FirebaseService.getFrens(userState.id, "SentGameReq");
    var recieved = await FirebaseService.getFrens(
      userState.id,
      "RecievedGameReq",
    );
    sentMap = await FirebaseService.getUsers(userState.id, sent, false);
    recievedMap = await FirebaseService.getUsers(userState.id, recieved, false);
    gamesMap = await FirebaseGame.getGames(userState.id);
  }

  Future<void> fetchData() async {
    await Future.delayed(Durations.long1);
    await fetchUsers();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userState = context.read<UserState>();
    fetchData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // reading appstate for future shenanigans
    var userState = context.watch<UserState>();
    var pageState = context.watch<PageState>();
    return Row(
      children: [
        Expanded(
          flex: 11,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      resetGame();
                      setState(() {});
                    },
                    child: Text("Reset"),
                  ),
                  SizedBox(height: 500, width: 500, child: Game()),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Text("Sent Game Requests"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              sentMap.isEmpty
                  ? const Center(child: Text("No Challenges Sent"))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: sentMap.length,
                      itemBuilder: (context, index) {
                        var user = sentMap[index];
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(user['Name']),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await FirebaseGame.gameRequest(
                                userState.id,
                                user['ID'],
                                false,
                              );
                              fetchData();
                            },
                            child: Text("Remove"),
                          ),
                          tileColor: const Color.fromARGB(255, 255, 208, 0),
                          textColor: Colors.black,
                        );
                      },
                    ),
                  ),
              Text("Recieved Challenges"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              recievedMap.isEmpty
                  ? const Center(child: Text("No Challenges Yet"))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: recievedMap.length,
                      itemBuilder: (context, index) {
                        var user = recievedMap[index];
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(user['Name']),
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseGame.gameRequest(
                                    user['ID'],
                                    userState.id,
                                    true,
                                  );
                                  await fetchData();
                                },
                                child: Text("Accept"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseGame.gameRequest(
                                    user['ID'],
                                    userState.id,
                                    false,
                                  );
                                  fetchData();
                                },
                                child: Text("Reject"),
                              ),
                            ],
                          ),
                          tileColor: const Color.fromARGB(255, 255, 208, 0),
                          textColor: Colors.black,
                        );
                      },
                    ),
                  ),
              Text("Current Game"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              gamesMap.isEmpty
                  ? const Center(child: Text("None"))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: gamesMap.length,
                      itemBuilder: (context, index) {
                        var user = gamesMap[index];
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(user['Name']),
                          trailing: ElevatedButton(
                            onPressed: () {
                              pageState.setPage(3, gID: user['Game']);
                              setState(() {});
                            },
                            child: Text("Play"),
                          ),
                          tileColor: const Color.fromARGB(255, 255, 208, 0),
                          textColor: Colors.black,
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
