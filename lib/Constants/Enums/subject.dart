enum Subject {
  yo,
  tu,
  el,
  nosotros,
  vosotros,
  ellos,
}

extension SubjectExtension on Subject {
  String get displayEsp {
    switch (this) {
      case Subject.yo:
        return "Yo";
      case Subject.tu:
        return "Tú";
      case Subject.el:
        return "Él/Ella/Usted";
      case Subject.nosotros:
        return "Nosotr@s";
      case Subject.vosotros:
        return "Vosotr@s";
      case Subject.ellos:
        return "Ell@s/Ustedes";
    }
  }
  // String get displayJap {
  //   switch (this) {
  //     case Subject.yo:
  //       return "1";
  //     case Subject.tu:
  //       return "Tú";
  //     case Subject.el:
  //       return "Él/Ella/Usted";
  //     case Subject.nosotros:
  //       return "Nosotr@s";
  //     case Subject.vosotros:
  //       return "Vosotr@s";
  //     case Subject.ellos:
  //       return "Ell@s/Ustedes";
  //   }
  // }
}
