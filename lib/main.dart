// IMPORTS
import 'package:chess_website/Pages/game_page.dart';
import 'package:chess_website/Pages/socials.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/login.dart';
import 'Firebase/db_social.dart';
import 'Pages/homepage.dart';

// Run app stuff
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // making sure everything is inialized before start
  await FirebaseService.init(); // initializing firebase db
  runApp(const MyApp());
}

// Define App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // multi provider for... multiple providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginPageState()),
        ChangeNotifierProvider(create: (context) => PageState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark, // dark theme best theme
        title: "Chess26",
        home: Scaffold(
          // app bar is the thingy at the top that is a constant trhoughout the app
          appBar: AppBar(
            title: const Text("Checkmate Website"),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  onPressed: Scaffold.of(context).openDrawer, // sidebar wooo
                  icon: const Icon(Icons.menu),
                );
              },
            ),
          ),
          body: Center(child: Routes()),
          // drawer is the sidebar call
          drawer: Drawer(elevation: 4, child: SideBar()),
        ),
      ),
    );
  }
}

// This is the sidebar... duh
class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();
    var pageState = context.read<PageState>();
    return userState.login
        ? // only show this if logged in
        ListView(
          padding: EdgeInsets.all(0),
          children: [
            DrawerHeader(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(
                "",
              ), // child is a required param, so i just added this cuz idk what else to put
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
        : // when not yet logged in, use this
        ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[200]),
              child: Text(""),
            ),
            // instead of "hello" need something better
            ListTile(title: Text("hello")),
          ],
        );
  }
}

// contains the data that we store on the user
class UserState extends ChangeNotifier {
  String id =
      ''; // note: id is a string because id is based on firebase db document id which is random shit
  var login = false; // default to not logged in
  List<dynamic> frenList =
      []; // list of user's friends is used in different places so it is more effecient to store it here

  void setLogin() {
    login = !login;
    notifyListeners();
  }

  void setUserID(name) async {
    id = await FirebaseService.getID(
      name,
    ); // when user logs in, we get the id from the db
    await setUserFrens(id);
    notifyListeners();
  }

  Future<void> setUserFrens(id) async {
    frenList = await FirebaseService.getFrens(id, "Friends");
    notifyListeners();
  }
}

// stores the page we're on
class PageState extends ChangeNotifier {
  int pageNo = 0; // initial page is homepage
  String?
  gameID; // ? means it may be null since ppl aren't always on the game page

  void setPage(int pNo, {String? gID}) {
    pageNo = pNo;
    gameID = gID;
    notifyListeners();
  }
}

// for movement between the pages
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
      // if not logged in.. login page.. boom!
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
