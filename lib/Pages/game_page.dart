import '../main.dart';
import '../Firebase/db_game.dart';
import 'package:chess/chess.dart' as c;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Multiplayer extends StatefulWidget {
  final String gameID;
  const Multiplayer({super.key, required this.gameID});

  @override
  State<Multiplayer> createState() => _MultiplayerState();
}

class _MultiplayerState extends State<Multiplayer> {
  int? selectedSquare;
  String? black;
  String? white;
  late String gID;
  var boardState;
  bool shownDialog = false;

  c.Chess chess = c.Chess();

  Future<void> startGame() async {
    List<String> players = await FirebaseGame.getIDs(gID);

    setState(() {
      white = players[0];
      black = players[1];
    });
  }

  void startStartGame() async {
    await startGame();
  }

  @override
  void initState() {
    super.initState();
    gID = widget.gameID;
    gameStream.listenToGame(gID);
  }

  String squareName(int index) {
    int row = index ~/ 8;
    int col = index % 8;
    return "${'abcdefgh'[col]}${8 - row}";
  }

  Widget getPiece(int index) {
    c.Piece? piece = chess.board[index];
    if (piece == null) return const SizedBox(width: 40, height: 40);

    String color = piece.color.toString().toLowerCase().substring(6);
    String asset = "assets/$color-${piece.type}.png";
    return Image.asset(asset, height: 40, width: 40);
  }

  void makeMove(int fromIndex, int toIndex) async {
    String from = squareName(fromIndex);
    String to = squareName(toIndex);
    if ((to.endsWith('8') || to.endsWith('1')) &&
        chess.get(from)?.type == c.Chess.PAWN) {
      String promoteTo = 'q';
      String turn = chess.turn.toString().toLowerCase().substring(6);
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("Pawn Promotion")),
            content: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    promoteTo = 'q';
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/$turn-q.png",
                    width: 30,
                    height: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    promoteTo = 'r';
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/$turn-r.png",
                    width: 30,
                    height: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    promoteTo = 'b';
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/$turn-b.png",
                    width: 30,
                    height: 30,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    promoteTo = 'n';
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/$turn-n.png",
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            ),
          );
        },
      );
      chess.move({"from": from, "to": to, 'promotion': promoteTo});
    } else {
      chess.move({"from": from, "to": to});
    }
    await FirebaseGame.updateBoard(chess.fen, gID);

    setState(() {
      selectedSquare = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var userState = context.watch<UserState>();

    return StreamBuilder<String>(
      stream: gameStream.boardStream,
      builder: (context, snapshot) {
        startStartGame();
        if (snapshot.hasData) {
          chess.load(snapshot.data!);
        } else {
          chess.reset();
        }
        if (chess.game_over && !shownDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String winner =
                      (chess.turn.toString() == 'COLOR.white')
                          ? "Black"
                          : "White";
                  FirebaseGame.setWinner(gID, winner);
                  return AlertDialog(
                    title: Text("Game Over"),
                    content: Text("$winner won"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
              shownDialog = true;
            }
          });
        }
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;
                  int boardIndex =
                      black == userState.id
                          ? (7 - row) * 16 + (7 - col)
                          : row * 16 + col;
                  bool isWhite = (row + col) % 2 == 0;

                  return GestureDetector(
                    onTap: () {
                      if (chess.turn.toString().toLowerCase().substring(6)[0] ==
                              'w'
                          ? white == userState.id
                          : black == userState.id) {
                        if (selectedSquare == null) {
                          setState(
                            () =>
                                selectedSquare =
                                    black == userState.id ? 63 - index : index,
                          );
                        } else {
                          makeMove(
                            selectedSquare!,
                            black == userState.id ? 63 - index : index,
                          );
                        }
                      }
                    },
                    child: Container(
                      color:
                          black == userState.id
                              ? (selectedSquare == 63 - index
                                  ? Colors.yellow
                                  : (isWhite ? Colors.white : Colors.grey))
                              : (selectedSquare == index
                                  ? Colors.yellow
                                  : (isWhite ? Colors.white : Colors.grey)),
                      child: Center(child: getPiece(boardIndex)),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
