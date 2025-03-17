import 'package:flutter/material.dart';
import '../main.dart';
import 'package:provider/provider.dart';
import '../Firebase/db_social.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usercontroller = TextEditingController();
  final passcontroller = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userState = context.read<UserState>();
    var loginState = context.watch<LoginPageState>();
    return Center(
      child: Form(
        key: form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<LoginPageState>(
              builder: (context, loginState, child) {
                return Text(loginState.errorMessage);
              },
            ),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: usercontroller,
                decoration: InputDecoration(label: Text("Username kya bhai")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your username";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: passcontroller,
                obscureText: true,
                decoration: InputDecoration(label: Text("Password kya bhai")),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    bool authenticated = await FirebaseService.loginAuth(
                      usercontroller.text.trim(),
                      passcontroller.text.trim(),
                    );

                    if (authenticated == true) {
                      userState.setLogin();
                      userState.setUserID(usercontroller.text.trim());
                      loginState.setError1(true);
                    } else {
                      loginState.setError1(false);
                    }
                  },
                  child: Text("Submit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    loginState.setLogin();
                  },
                  child: Text("SignUp"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPageState extends ChangeNotifier {
  String errorMessage = "";
  bool isLogin = true;

  void setLogin() {
    isLogin = !isLogin;
    notifyListeners();
  }

  void setError1(bool auth) {
    if (!auth) {
      errorMessage = "Username or Password is wrong";
    } else {
      errorMessage = '';
    }
    notifyListeners();
  }

  void setError2(bool check) {
    if (check) {
      errorMessage = "Username Exists";
    } else {
      errorMessage = '';
    }
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var loginState = context.watch<LoginPageState>();
    return loginState.isLogin ? LoginForm() : SignUpForm();
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});
  @override
  State<SignUpForm> createState() => _SignUpForm();
}

class _SignUpForm extends State<SignUpForm> {
  final usercontroller = TextEditingController();
  final passcontroller = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: form,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<LoginPageState>(
              builder: (context, loginState, child) {
                return Text(loginState.errorMessage);
              },
            ),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: usercontroller,
                decoration: InputDecoration(
                  label: Text("New username kya bhai"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your username";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: passcontroller,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text("New password kya bhai"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var loginState = context.read<LoginPageState>();
                    bool check = await FirebaseService.checkExists(
                      usercontroller.text.trim(),
                    );
                    if (check) {
                      loginState.setError2(true);
                    } else {
                      Map<String, dynamic> user = {
                        "Name": usercontroller.text.trim(),
                        "Password": passcontroller.text.trim(),
                      };
                      FirebaseService.addUser(user);
                      loginState.setLogin();
                    }
                  },
                  child: Text("Submit"),
                ),
                ElevatedButton(
                  onPressed: () {
                    var loginState = context.read<LoginPageState>();
                    loginState.setLogin();
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
