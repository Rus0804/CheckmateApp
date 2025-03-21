// IMPORTS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'db_social.dart';
import 'dart:math';
import 'dart:async';

class FirebaseGame {
  static FirebaseFirestore get db => FirebaseService.db;

  // Send FrenReq
  static Future<void> sendGameReq(String from, String to) async {
    var fromDoc = await db.collection("users").doc(from).get();
    fromDoc.reference.update({
      "SentGameReq": FieldValue.arrayUnion([to]),
    });
    var toDoc = await db.collection("users").doc(to).get();
    toDoc.reference.update({
      "RecievedGameReq": FieldValue.arrayUnion([from]),
    });
  }

  // Manage FrenReq, reject or remove (accpet = false), accept (accept = true)
  static Future<void> gameRequest(String from, String to, bool accept) async {
    var fromDoc = await db.collection("users").doc(from).get();
    var toDoc = await db.collection("users").doc(to).get();
    String? id;

    fromDoc.reference.update({
      "SentGameReq": FieldValue.arrayRemove([to]),
    });
    toDoc.reference.update({
      "RecievedGameReq": FieldValue.arrayRemove([from]),
    });
    if (accept) {
      bool isWhite = Random().nextBool();
      id = await newGame(isWhite ? from : to, isWhite ? to : from);
      fromDoc.reference.update({
        "isPlaying": FieldValue.arrayUnion([id]),
      });
      toDoc.reference.update({
        "isPlaying": FieldValue.arrayUnion([id]),
      });
    }
  }

  static Future<String?> newGame(String p1, String p2) async {
    String? id;
    Map<String, dynamic> gameData = {
      "Player1": p1,
      "Player2": p2,
      "board": 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      "winner": "",
    };
    await db
        .collection('games')
        .add(gameData)
        .then((documentSnapshot) => {id = documentSnapshot.id});
    return id;
  }

  static Future<void> updateBoard(String fen, String id) async {
    var result = await db.collection("games").doc(id).get();
    result.reference.update({'board': fen});
  }

  static Future<List<String>> getIDs(String id) async {
    var result = await db.collection("games").doc(id).get();
    List<String> players = [
      result.data()?['Player1'],
      result.data()?['Player2'],
    ];
    return players;
  }

  static Future<List<Map<String, dynamic>>> getGames(String userID) async {
    var userDB = await db.collection("users").doc(userID).get();
    List<dynamic> gameList = userDB.data()?['isPlaying'];
    List<Map<String, dynamic>> games = [];
    for (var game in gameList) {
      var gameDB = await db.collection("games").doc(game).get();
      String oppID =
          gameDB.data()?['Player1'] == userID
              ? (gameDB.data()?['Player2'])
              : gameDB.data()?['Player1'];
      var opp = await db.collection("users").doc(oppID).get();
      games.add({"ID": oppID, "Name": opp.data()?['Name'], "Game": game});
    }
    return games;
  }

  static Future<String> getRef(int gID) async {
    var gameDB =
        await db.collection("games").where("gameID", isEqualTo: gID).get();
    String docID = gameDB.docs.first.reference.id;
    return docID;
  }

  static Future<void> setWinner(String gID, String winner) async {
    var gameDB = await db.collection("games").doc(gID).get();
    if (winner == "white") {
      gameDB.reference.update({"winner": gameDB.data()?['Player1']});
      winner = gameDB.data()?['Player1'];
    } else if (winner == "black") {
      gameDB.reference.update({"winner": gameDB.data()?['Player2']});
      winner = gameDB.data()?['Player2'];
    } else {
      gameDB.reference.update({"winner": "Draw"});
    }
    await endGame(gameDB.data()?['Player1'], gID, winner);
    await endGame(gameDB.data()?['Player2'], gID, winner);
  }

  static Future<void> endGame(String pID, String gID, String won) async {
    var userDB = await db.collection("users").doc(pID).get();
    String field;
    if (pID == won) {
      field = "Wins";
    } else if (won == "None") {
      field = 'Draws';
    } else {
      field = "Loses";
    }
    userDB.reference.update({
      "isPlaying": FieldValue.arrayRemove([gID]),
      "History": FieldValue.arrayUnion([gID]),
      field: FieldValue.increment(1),
    });
  }
}

class GameStream {
  final _controller = StreamController<String>.broadcast();
  Stream<String> get boardStream => _controller.stream;

  void listenToGame(String gameID) async {
    FirebaseFirestore.instance
        .collection("games")
        .doc(gameID)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            _controller.add(snapshot.data()?['board'] ?? "");
          }
        });
  }
}

final gameStream = GameStream(); // 🔹 Singleton instance
