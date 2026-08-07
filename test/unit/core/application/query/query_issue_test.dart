import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';

void main() {
  test('QueryIssue preserves its application source and typed error', () {
    final error = ValidationError(message: 'Meaning unavailable');
    final issue = QueryIssue(source: 'meaning', error: error);

    expect(issue.source, 'meaning');
    expect(issue.error, same(error));
  });
}
