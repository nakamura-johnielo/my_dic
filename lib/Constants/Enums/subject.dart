enum EnglishSubject { I, you, he, we, they }

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

  EnglishSubject get equiEnglish {
    switch (this) {
      case Subject.yo:
        return EnglishSubject.I;
      case Subject.tu:
        return EnglishSubject.you;
      case Subject.el:
        return EnglishSubject.he;
      case Subject.nosotros:
        return EnglishSubject.we;
      case Subject.vosotros:
        return EnglishSubject.you;
      case Subject.ellos:
        return EnglishSubject.they;
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
