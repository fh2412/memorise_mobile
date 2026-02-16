import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/friend_add_row_view_model.dart';
import 'friend_scanner_screen_view.dart';
import 'package:confetti/confetti.dart';

class FriendAddRow extends StatefulWidget {
  const FriendAddRow({super.key});

  @override
  State<FriendAddRow> createState() => _FriendAddRowState();
}

class _FriendAddRowState extends State<FriendAddRow> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleSend(FriendAddViewModel vm) async {
    await vm.sendFriendRequest();

    if (vm.errorMessage == null && mounted) {
      _confettiController.play();

      // Optional: Show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request sent! 🎉"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Consumer<FriendAddViewModel>(
          builder: (context, vm, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Text Field with integrated Scan button
                    Expanded(
                      child: TextField(
                        controller: vm.codeController,
                        decoration: InputDecoration(
                          hintText: "Friend Code",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            onPressed: () async {
                              final code = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScannerScreen(),
                                ),
                              );
                              if (code != null) vm.updateCode(code);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send Button
                    vm.isLoading
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton.filled(
                            onPressed: () => _handleSend(vm),
                            icon: const Icon(Icons.send_rounded),
                            tooltip: "Send Request",
                          ),
                  ],
                ),
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      vm.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // The Confetti Widget (invisible until .play() is called)
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality:
              BlastDirectionality.explosive, // Shoots in all directions
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          numberOfParticles: 20,
          gravity: 0.1,
        ),
      ],
    );
  }
}
