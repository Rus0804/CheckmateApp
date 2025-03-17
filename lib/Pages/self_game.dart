<<<<<<< HEAD
import 'package:chess/chess.dart' as c;
import 'package:flutter/material.dart';

c.Chess chess = c.Chess();

void resetGame() {
  chess = c.Chess();
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int? selectedSquare;
  bool isBlackSide = false;

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

    setState(() {
      selectedSquare = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  isBlackSide ? (7 - row) * 16 + (7 - col) : row * 16 + col;
              bool isWhite = (row + col) % 2 == 0;
              return GestureDetector(
                onTap: () {
                  if (selectedSquare == null) {
                    setState(
                      () => selectedSquare = isBlackSide ? 63 - index : index,
                    );
                  } else {
                    makeMove(selectedSquare!, isBlackSide ? 63 - index : index);
                    if (chess.game_over) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String winner =
                              (chess.turn.toString() == 'COLOR.white')
                                  ? "Black"
                                  : "White";
                          if (chess.in_draw) {
                            winner = 'None';
                          }
                          return AlertDialog(
                            title: Text("Game Over"),
                            content:
                                winner == 'None'
                                    ? Text("Draw")
                                    : Text("$winner won"),
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
                    }
                  }
                },
                child: Container(
                  color:
                      isBlackSide
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
        ElevatedButton(
          onPressed: () {
            isBlackSide = !isBlackSide;
            setState(() {});
          },
          child: Text("Swap Sides"),
        ),
      ],
    );
  }
}
=======
import 'package:chess/chess.dart' as c;
import 'package:flutter/material.dart';

c.Chess chess = c.Chess();

void resetGame() {
  chess = c.Chess();
}

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  int? selectedSquare;
  bool isBlackSide = false;

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

    setState(() {
      selectedSquare = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  isBlackSide ? (7 - row) * 16 + (7 - col) : row * 16 + col;
              bool isWhite = (row + col) % 2 == 0;
              return GestureDetector(
                onTap: () {
                  if (selectedSquare == null) {
                    setState(
                      () => selectedSquare = isBlackSide ? 63 - index : index,
                    );
                  } else {
                    makeMove(selectedSquare!, isBlackSide ? 63 - index : index);
                    if (chess.game_over) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String winner =
                              (chess.turn.toString() == 'COLOR.white')
                                  ? "Black"
                                  : "White";
                          if (chess.in_draw) {
                            winner = 'None';
                          }
                          return AlertDialog(
                            title: Text("Game Over"),
                            content:
                                winner == 'None'
                                    ? Text("Draw")
                                    : Text("$winner won"),
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
                    }
                  }
                },
                child: Container(
                  color:
                      isBlackSide
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
        ElevatedButton(
          onPressed: () {
            isBlackSide = !isBlackSide;
            setState(() {});
          },
          child: Text("Swap Sides"),
        ),
      ],
    );
  }
}
>>>>>>> 412e97079a4e2bc03662c07a2b2be9c4058038d7
