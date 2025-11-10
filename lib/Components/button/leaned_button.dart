// import 'package:flutter/material.dart';
// import 'package:my_dic/Components/button/my_icon_button.dart';
// import 'package:my_dic/Constants/Enums/word_card_view_click_listener.dart';

// class LearnedButton extends StatelessWidget {
//   final bool isSelected;
//   const LearnedButton({super.key, required this.isSelected});

//   static const Map<String, IconData> bookmarkIcon = {
//     "true": Icons.bookmark_rounded,
//     "false": Icons.bookmark_border_rounded,
//     "added": Icons.bookmark_added_rounded
//   };
//   static const Map<String, IconData> learnedIcon = {
//     "true": Icons.check_circle_rounded,
//     "false": Icons.check_circle_outline_rounded
//   };

//   static Map<WordCardViewButton, VoidCallback>? clickListeners = {
//     WordCardViewButton.bookmark: () {
//       _rankingController.updateWordStatus(index, ranking.wordId,
//           !ranking.isBookmarked, ranking.isLearned, ranking.hasNote);
//     },
//     WordCardViewButton.learned: () {
//       _rankingController.updateWordStatus(index, ranking.wordId,
//           ranking.isBookmarked, !ranking.isLearned, ranking.hasNote);
//     },
//     WordCardViewButton.note: () => log("note clicked"),
//   };

//   @override
//   Widget build(BuildContext context) {
//     return MyIconButton(
//       iconSize: 22,
//       defaultIcon: ranking.isLearned
//           ? learnedIcon["true"] ?? Icons.error
//           : learnedIcon["false"] ?? Icons.error,
//       hoveredIcon: ranking.isLearned
//           ? learnedIcon["true"] ?? Icons.error
//           : learnedIcon["false"] ?? Icons.error,
//       hoveredIconColor: const Color.fromARGB(255, 119, 119, 119),
//       onTap: () {
//         clickListeners[WordCardViewButton.learned]!();
//       },
//     );
//   }
// }
