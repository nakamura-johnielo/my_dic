/// The app-facing MyWord presentation entry.
export 'package:my_dic/features/my_word/internal/presentation/view/my_word_fragment.dart'
    show MyWordFragment;
export 'package:my_dic/features/my_word/internal/presentation/view/my_word_status_buttons_entry.dart';

/// MyWord-specific status entry types for shared app presentation shells.
export 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
export 'package:my_dic/features/my_word/internal/presentation/ui_model/my_word_ui_model.dart';
export 'package:my_dic/features/my_word/internal/di/view_model_di.dart'
    show myWordItemUiModelProvider, myWordStatusCommandProvider;
