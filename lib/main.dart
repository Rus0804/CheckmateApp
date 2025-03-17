<<<<<<< HEAD
import 'package:chess_website/Pages/game_page.dart';
import 'package:chess_website/Pages/socials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/login.dart';
import 'Firebase/db_social.dart';
import 'Pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginPageState()),
        ChangeNotifierProvider(create: (context) => PageState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        title: "hey",
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Checkmate Website"),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu),
                );
              },
            ),
          ),
          body: Center(child: Routes()),
          drawer: Drawer(elevation: 4, child: SideBar()),
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    var pageState = context.read<PageState>();
    return userState.login
        ? ListView(
          padding: EdgeInsets.all(0),
          children: [
            DrawerHeader(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(""),
            ),
            ListTile(
              title: Text("Home"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(0);
              },
            ),
            ListTile(
              title: Text("Profile"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(1);
              },
            ),
            ListTile(
              title: Text("Social"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(2);
              },
            ),
            ElevatedButton(
              onPressed: () {
                pageState.setPage(0);
                userState.setLogin();
              },
              child: Text("Logout"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseService.delAcc(userState.id);
                userState.setLogin();
              },
              child: Text("Delete Account"),
            ),
          ],
        )
        : ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(""),
            ),
            ListTile(title: Text("hello")),
          ],
        );
  }
}

class UserState extends ChangeNotifier {
  String id = '';
  var login = false;
  List<dynamic> frenList = [];
  void setLogin() {
    login = !login;
    notifyListeners();
  }

  void setUserID(name) async {
    id = await FirebaseService.getID(name);
    await setUserFrens(id);
    notifyListeners();
  }

  Future<void> setUserFrens(id) async {
    frenList = await FirebaseService.getFrens(id, "Friends");
    notifyListeners();
  }
}

class PageState extends ChangeNotifier {
  int pageNo = 0;
  String? gameID;
  void setPage(int pNo, {String? gID}) {
    pageNo = pNo;
    gameID = gID;
    notifyListeners();
  }
}

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _Routes();
}

class _Routes extends State<Routes> {
  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    var pageState = context.watch<PageState>();
    var login = userState.login;
    if (!login) {
      return LoginPage();
    } else {
      switch (pageState.pageNo) {
        case 1:
          return ProfilePage();
        case 2:
          return UsersPage();
        case 3:
          return Multiplayer(gameID: pageState.gameID!);
        default:
          return HomePage();
      }
    }
  }
}
=======
import 'package:chess_website/Pages/game_page.dart';
import 'package:chess_website/Pages/socials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/login.dart';
import 'Firebase/db_social.dart';
import 'Pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginPageState()),
        ChangeNotifierProvider(create: (context) => PageState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        title: "hey",
        home: Scaffold(
          appBar: AppBar(
            title: const Text("hey"),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu),
                );
              },
            ),
          ),
          body: Center(child: Routes()),
          drawer: Drawer(elevation: 4, child: SideBar()),
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    var pageState = context.read<PageState>();
    return userState.login
        ? ListView(
          padding: EdgeInsets.all(0),
          children: [
            DrawerHeader(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(""),
            ),
            ListTile(
              title: Text("Home"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(0);
              },
            ),
            ListTile(
              title: Text("Profile"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(1);
              },
            ),
            ListTile(
              title: Text("Social"),
              hoverColor: Colors.deepPurple[200],
              onTap: () {
                pageState.setPage(2);
              },
            ),
            ElevatedButton(
              onPressed: () {
                pageState.setPage(0);
                userState.setLogin();
              },
              child: Text("Logout"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseService.delAcc(userState.id);
                userState.setLogin();
              },
              child: Text("Delete Account"),
            ),
          ],
        )
        : ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(""),
            ),
            ListTile(title: Text("hello")),
          ],
        );
  }
}

class UserState extends ChangeNotifier {
  String id = '';
  var login = false;
  List<dynamic> frenList = [];
  void setLogin() {
    login = !login;
    notifyListeners();
  }

  void setUserID(name) async {
    id = await FirebaseService.getID(name);
    await setUserFrens(id);
    notifyListeners();
  }

  Future<void> setUserFrens(id) async {
    frenList = await FirebaseService.getFrens(id, "Friends");
    notifyListeners();
  }
}

class PageState extends ChangeNotifier {
  int pageNo = 0;
  String? gameID;
  void setPage(int pNo, {String? gID}) {
    pageNo = pNo;
    gameID = gID;
    notifyListeners();
  }
}

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _Routes();
}

class _Routes extends State<Routes> {
  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    var pageState = context.watch<PageState>();
    var login = userState.login;
    if (!login) {
      return LoginPage();
    } else {
      switch (pageState.pageNo) {
        case 1:
          return ProfilePage();
        case 2:
          return UsersPage();
        case 3:
          return Multiplayer(gameID: pageState.gameID!);
        default:
          return HomePage();
      }
    }
  }
}
>>>>>>> 412e97079a4e2bc03662c07a2b2be9c4058038d7
