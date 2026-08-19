import 'package:flutter/material.dart';
import 'package:my_dic/app/guest_migration/guest_data_summary.dart';

/// ローカルに保存されたゲストデータをサインイン済みアカウントへ移動するか確認します。
/// 承認時は `true`、キャンセル時は `false`/`null` を返します。
class GuestDataMigrationDialog extends StatelessWidget {
  const GuestDataMigrationDialog({super.key, required this.summary});

  final GuestDataSummary summary;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('サインイン前のデータを引き継ぎますか？'),
      content: Text(
        'サインインする前に保存した単語やステータス（${summary.totalCount}件）が見つかりました。'
        'このアカウントに引き継ぐことができます。',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('引き継ぐ'),
        ),
      ],
    );
  }
}
