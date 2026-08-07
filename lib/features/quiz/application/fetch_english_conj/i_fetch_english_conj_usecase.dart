import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IFetchEnglishConjUseCase {
  Future<Result<Map<String, String>>> execute(int wordId);
}
