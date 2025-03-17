<<<<<<< HEAD
//IMPORTS
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../Firebase/db_social.dart';
import '../Firebase/db_game.dart';

//Your profile
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late UserState userState;
  List<Map<String, dynamic>> frenMap = [];
  List<Map<String, dynamic>> sentMap = [];
  List<Map<String, dynamic>> recievedMap = [];

  fetchUsers() async {
    frenMap = await FirebaseService.getUsers(
      userState.id,
      userState.frenList,
      false,
    );
    var sent = await FirebaseService.getFrens(userState.id, "SentFriendReq");
    var recieved = await FirebaseService.getFrens(
      userState.id,
      "RecievedFriendReq",
    );
    sentMap = await FirebaseService.getUsers(userState.id, sent, false);
    recievedMap = await FirebaseService.getUsers(userState.id, recieved, false);
  }

  Future<void> fetchData() async {
    await fetchUsers();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userState = context.read<UserState>();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 11, child: Center(child: Text("Empty Space for now"))),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Text("FRIEND LIST"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              frenMap.isEmpty
                  ? const Center(child: Text("No Friends Yet"))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: frenMap.length,
                      itemBuilder: (context, index) {
                        var user = frenMap[index];
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(user['Name']),
                          trailing: ElevatedButton(
                            onPressed: () {
                              FirebaseGame.sendGameReq(
                                userState.id,
                                user['ID'],
                              );
                            },
                            child: Text("Challenge"),
                          ),
                          tileColor: const Color.fromARGB(255, 255, 208, 0),
                          textColor: Colors.black,
                        );
                      },
                    ),
                  ),
              Text("Sent Friend Requests"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              sentMap.isEmpty
                  ? const Center(child: Text("No Requests Sent"))
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
                              FirebaseService.frenRequest(
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
              Text("Recieved Friend Requests"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              recievedMap.isEmpty
                  ? const Center(child: Text("No Requests Pending"))
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
                                  await FirebaseService.frenRequest(
                                    user['ID'],
                                    userState.id,
                                    true,
                                  );
                                  await userState.setUserFrens(userState.id);
                                  await fetchData();
                                },
                                child: Text("Accept"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FirebaseService.frenRequest(
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
            ],
          ),
        ),
      ],
    );
  }
}

//A page for finding all users
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> allUsers = [];
  late UserState userState;
  //Getting all the users and their realtionship to the logged in user
  fetchUsers() async {
    allUsers = await FirebaseService.getUsers(
      userState.id,
      userState.frenList,
      true,
    );
  }

  //Required wrapper because initState can't do async/await directly
  Future<void> fetchData() async {
    await fetchUsers();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userState = context.read<UserState>();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(label: Text("Name Search")),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String search = await FirebaseService.getID(
                  controller.text.trim(),
                );
                allUsers = await FirebaseService.searchUser(
                  userState.id,
                  search,
                );
                setState(() {});
              },
              child: Text("Search"),
            ),
            ElevatedButton(
              onPressed: () async {
                fetchData();
              },
              child: Text("Clear Search"),
            ),
          ],
        ),
        //Head row with column names
        ListTile(
          leading: Text("ID"),
          title: Text("Username"),
          trailing: Text("isFren"),
          tileColor: Colors.amber[600],
          textColor: Colors.black,
        ),
        //Will give the list
        Expanded(child: UserList(allUsers: allUsers)),
      ],
    );
  }
}

//UsersList, what it says in the title
class UserList extends StatelessWidget {
  const UserList({super.key, required this.allUsers});

  final List<Map<String, dynamic>> allUsers;

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    //Custom ListView builder cuz it's not a simple list
    //item builder essentially does the equivalent of a for loop iteration
    return ListView.builder(
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        var user = allUsers[index];
        String id = (index + 1).toString();
        String name = user['Name'];
        bool isFren = user['Fren'];
        return ListTile(
          leading: Text(id.toString()),
          title: Text(name),
          trailing:
              isFren
                  ? ElevatedButton(
                    onPressed: () async {
                      await FirebaseService.delFren(userState.id, user['ID']);
                      await userState.setUserFrens(userState.id);
                    },
                    child: Text("Remove Friend"),
                  )
                  : ElevatedButton(
                    onPressed: () async {
                      FirebaseService.sendFrenReq(userState.id, user['ID']);
                    },
                    child: Text("   Add Friend   "),
                  ),
          tileColor: const Color.fromARGB(255, 255, 208, 0),
          textColor: Colors.black,
        );
      },
    );
  }
}
=======
//IMPORTS
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../Firebase/db_social.dart';
import '../Firebase/db_game.dart';

//Your profile
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late UserState userState;
  List<Map<String, dynamic>> frenMap = [];
  List<Map<String, dynamic>> sentMap = [];
  List<Map<String, dynamic>> recievedMap = [];

  fetchUsers() async {
    frenMap = await FirebaseService.getUsers(
      userState.id,
      userState.frenList,
      false,
    );
    var sent = await FirebaseService.getFrens(userState.id, "SentFriendReq");
    var recieved = await FirebaseService.getFrens(
      userState.id,
      "RecievedFriendReq",
    );
    sentMap = await FirebaseService.getUsers(userState.id, sent, false);
    recievedMap = await FirebaseService.getUsers(userState.id, recieved, false);
  }

  Future<void> fetchData() async {
    await fetchUsers();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userState = context.read<UserState>();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 11, child: Center(child: Text("Empty Space for now"))),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              Text("FRIEND LIST"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              frenMap.isEmpty
                  ? const Center(child: Text("No Friends Yet"))
                  : Expanded(
                    child: ListView.builder(
                      itemCount: frenMap.length,
                      itemBuilder: (context, index) {
                        var user = frenMap[index];
                        return ListTile(
                          leading: Text((index + 1).toString()),
                          title: Text(user['Name']),
                          trailing: ElevatedButton(
                            onPressed: () {
                              FirebaseGame.sendGameReq(
                                userState.id,
                                user['ID'],
                              );
                            },
                            child: Text("Challenge"),
                          ),
                          tileColor: const Color.fromARGB(255, 255, 208, 0),
                          textColor: Colors.black,
                        );
                      },
                    ),
                  ),
              Text("Sent Friend Requests"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              sentMap.isEmpty
                  ? const Center(child: Text("No Requests Sent"))
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
                              FirebaseService.frenRequest(
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
              Text("Recieved Friend Requests"),
              ListTile(
                leading: Text("ID"),
                title: Text("Name"),
                tileColor: Colors.amber[600],
                textColor: Colors.black,
              ),
              recievedMap.isEmpty
                  ? const Center(child: Text("No Requests Pending"))
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
                                  await FirebaseService.frenRequest(
                                    user['ID'],
                                    userState.id,
                                    true,
                                  );
                                  await userState.setUserFrens(userState.id);
                                  await fetchData();
                                },
                                child: Text("Accept"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FirebaseService.frenRequest(
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
            ],
          ),
        ),
      ],
    );
  }
}

//A page for finding all users
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> allUsers = [];
  late UserState userState;
  //Getting all the users and their realtionship to the logged in user
  fetchUsers() async {
    allUsers = await FirebaseService.getUsers(
      userState.id,
      userState.frenList,
      true,
    );
  }

  //Required wrapper because initState can't do async/await directly
  Future<void> fetchData() async {
    await fetchUsers();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    userState = context.read<UserState>();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(label: Text("Name Search")),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String search = await FirebaseService.getID(
                  controller.text.trim(),
                );
                allUsers = await FirebaseService.searchUser(
                  userState.id,
                  search,
                );
                setState(() {});
              },
              child: Text("Search"),
            ),
            ElevatedButton(
              onPressed: () async {
                fetchData();
              },
              child: Text("Clear Search"),
            ),
          ],
        ),
        //Head row with column names
        ListTile(
          leading: Text("ID"),
          title: Text("Username"),
          trailing: Text("isFren"),
          tileColor: Colors.amber[600],
          textColor: Colors.black,
        ),
        //Will give the list
        Expanded(child: UserList(allUsers: allUsers)),
      ],
    );
  }
}

//UsersList, what it says in the title
class UserList extends StatelessWidget {
  const UserList({super.key, required this.allUsers});

  final List<Map<String, dynamic>> allUsers;

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    //Custom ListView builder cuz it's not a simple list
    //item builder essentially does the equivalent of a for loop iteration
    return ListView.builder(
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        var user = allUsers[index];
        String id = (index + 1).toString();
        String name = user['Name'];
        bool isFren = user['Fren'];
        return ListTile(
          leading: Text(id.toString()),
          title: Text(name),
          trailing:
              isFren
                  ? ElevatedButton(
                    onPressed: () async {
                      await FirebaseService.delFren(userState.id, user['ID']);
                      await userState.setUserFrens(userState.id);
                    },
                    child: Text("Remove Friend"),
                  )
                  : ElevatedButton(
                    onPressed: () async {
                      FirebaseService.sendFrenReq(userState.id, user['ID']);
                    },
                    child: Text("   Add Friend   "),
                  ),
          tileColor: const Color.fromARGB(255, 255, 208, 0),
          textColor: Colors.black,
        );
      },
    );
  }
}
>>>>>>> 412e97079a4e2bc03662c07a2b2be9c4058038d7
