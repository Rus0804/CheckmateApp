// IMPORTS
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:crypt/crypt.dart';

// Class to store all firebase related functions
class FirebaseService {
  // Inializing the app based on currentplatform as defined in firebase_options
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Getting the db instance
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  // Comparing passwords for login (will add hashing in the future)
  static Future<bool> loginAuth(name, pass) async {
    var result =
        await db.collection("users").where("Name", isEqualTo: name).get();
    if (result.docs.isNotEmpty) {
      var data = result.docs.first.data();
      final hash = Crypt(data["Password"]);
      if (hash.match(pass)) {
        return true;
      }
    }
    return false;
  }

  // Function to get the userID for future use
  static Future<String> getID(name) async {
    var result =
        await db.collection("users").where("Name", isEqualTo: name).get();
    if (result.docs.isEmpty) {
      return '';
    }
    String id = result.docs.first.reference.id;

    return id;
  }

  // Sign up functionality
  static Future<void> addUser(Map<String, dynamic> userDoc) async {
    final passHash = Crypt.sha512(userDoc['Password']);
    userDoc['Password'] = passHash.toString();
    userDoc.addAll({
      "Friends": [],
      "SentFriendReq": [],
      "RecievedFriendReq": [],
      "isPlaying": [],
      "SentGameReq": [],
      "RecievedGameReq": [],
    });
    db.collection("users").add(userDoc);
  }

  // Checks if username is taken before signup
  static Future<bool> checkExists(name) async {
    var result =
        await db.collection("users").where("Name", isEqualTo: name).get();
    return result.docs.isNotEmpty;
  }

  // Gets all users for display in the Socials Page
  static Future<List<Map<String, dynamic>>> getUsers(
    String id,
    List<dynamic> frenList,
    bool all,
  ) async {
    var result =
        await db
            .collection("users")
            .where(FieldPath.documentId, isNotEqualTo: id)
            .get();
    var data = result.docs.iterator;
    List<Map<String, dynamic>> userList = [];
    if (all) {
      while (data.moveNext()) {
        userList.add({
          'Name': data.current.data()['Name'],
          'Fren': frenList.contains(data.current.reference.id),
          'ID': data.current.reference.id,
        });
      }
    } else {
      while (data.moveNext()) {
        if (frenList.contains(data.current.reference.id)) {
          userList.add({
            'Name': data.current.data()['Name'],
            'ID': data.current.reference.id,
          });
        }
      }
    }
    return userList;
  }

  static Future<List<Map<String, dynamic>>> searchUser(
    String id,
    String search,
  ) async {
    if (id == '') {
      return [];
    }
    var result = await db.collection("users").doc(search).get();
    Map<String, dynamic> user = {
      "Name": result.data()?["Name"],
      "Fren": result.data()?["Friends"].contains(id),
    };
    return [user];
  }

  // Get list of Frens or Requests
  static Future<List<dynamic>> getFrens(String id, String field) async {
    var user = await db.collection("users").doc(id).get();
    List<dynamic> frenList = user.data()?[field];
    return frenList;
  }

  // Send FrenReq
  static Future<void> sendFrenReq(String from, String to) async {
    var fromDoc = await db.collection("users").doc(from).get();
    var toDoc = await db.collection("users").doc(to).get();
    fromDoc.reference.update({
      "SentFriendReq": FieldValue.arrayUnion([to]),
    });
    toDoc.reference.update({
      "RecievedFriendReq": FieldValue.arrayUnion([from]),
    });
  }

  // Manage FrenReq, reject or remove (accpet = false), accept (accept = true)
  static Future<void> frenRequest(String from, String to, bool accept) async {
    var fromDoc = await db.collection("users").doc(from).get();
    var toDoc = await db.collection("users").doc(to).get();
    // whatever it is we must remove it from pending requests
    fromDoc.reference.update({
      "SentFriendReq": FieldValue.arrayRemove([to]),
    });
    toDoc.reference.update({
      "RecievedFriendReq": FieldValue.arrayRemove([from]),
    });
    //adding friends
    if (accept) {
      fromDoc.reference.update({
        "Friends": FieldValue.arrayUnion([to]),
      });
      toDoc.reference.update({
        "Friends": FieldValue.arrayUnion([from]),
      });
    }
    // if condition to make sure the ordering is right and the IDs are correctly used
  }

  static Future<void> delFren(String id, String fren) async {
    var userDoc = await db.collection("users").doc(id).get();
    var frenDoc = await db.collection("users").doc(fren).get();
    userDoc.reference.update({
      "Friends": FieldValue.arrayRemove([fren]),
    });
    frenDoc.reference.update({
      "Friends": FieldValue.arrayRemove([id]),
    });
  }

  static Future<void> delAcc(String id) async {
    var result = await db.collection("users").get();
    for (var doc in result.docs) {
      if (doc.reference.id == id) {
        doc.reference.delete();
      } else {
        doc.reference.update({
          'Friends': FieldValue.arrayRemove([id]),
          'SentFriendReq': FieldValue.arrayRemove([id]),
          'RecievedFriendReq': FieldValue.arrayRemove([id]),
          'SentGameReq': FieldValue.arrayRemove([id]),
          'RecievedGameReq': FieldValue.arrayRemove([id]),
        });
      }
    }
  }
}
