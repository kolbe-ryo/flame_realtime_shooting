import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class LobbyDialog extends StatefulWidget {
  const LobbyDialog({
    super.key,
    required this.onGameStarted,
  });

  final void Function(String gameId) onGameStarted;

  @override
  State<LobbyDialog> createState() => _LobbyDialogState();
}

class _LobbyDialogState extends State<LobbyDialog> {
  final List<String> _userids = [];
  bool _loading = false;

  /// TODO: ユニークなIDを生成してアサインする
  final myUserId = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lobby'),
      content: Visibility(
        visible: _loading,
        replacement: Text('${_userids.length} users waiting'),
        child: const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _userids.length < 2
              ? null
              : () async {
                  setState(() => _loading = true);
                  // TODO: 他のプレーヤーにロビーに入ったことを知らせる
                },
          child: const Text('start'),
        ),
      ],
    );
  }
}
