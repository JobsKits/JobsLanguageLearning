// Created by Jobs on 2026年10月2日，星期五.
class KanaRow {
  final String consonant;
  final String kana;
  final List<String> readings;
  const KanaRow(this.consonant, this.kana, this.readings);
}

const japaneseVowels = ['あ', 'い', 'う', 'え', 'お'];
const romanVowels = ['a', 'i', 'u', 'e', 'o'];
const kanaRows = [
  KanaRow('k', 'かきくけこ', ['ka', 'ki', 'ku', 'ke', 'ko']),
  KanaRow('s', 'さしすせそ', ['sa', 'shi', 'su', 'se', 'so']),
  KanaRow('t', 'たちつてと', ['ta', 'chi', 'tsu', 'te', 'to']),
  KanaRow('n', 'なにぬねの', ['na', 'ni', 'nu', 'ne', 'no']),
  KanaRow('h', 'はひふへほ', ['ha', 'hi', 'fu', 'he', 'ho']),
  KanaRow('m', 'まみむめも', ['ma', 'mi', 'mu', 'me', 'mo']),
  KanaRow('y', 'や ゆ よ', ['ya', '', 'yu', '', 'yo']),
  KanaRow('r', 'らりるれろ', ['ra', 'ri', 'ru', 're', 'ro']),
  KanaRow('w', 'わ   を', ['wa', '', '', '', 'o']),
  KanaRow('g', 'がぎぐげご', ['ga', 'gi', 'gu', 'ge', 'go']),
  KanaRow('z', 'ざじずぜぞ', ['za', 'ji', 'zu', 'ze', 'zo']),
  KanaRow('d', 'だぢづでど', ['da', 'ji', 'zu', 'de', 'do']),
  KanaRow('b', 'ばびぶべぼ', ['ba', 'bi', 'bu', 'be', 'bo']),
  KanaRow('p', 'ぱぴぷぺぽ', ['pa', 'pi', 'pu', 'pe', 'po']),
];
const kanaIPA = {
  'あ': 'a',
  'い': 'i',
  'う': 'ɯ',
  'え': 'e',
  'お': 'o',
  'か': 'ka',
  'き': 'ki',
  'く': 'kɯ',
  'け': 'ke',
  'こ': 'ko',
  'さ': 'sa',
  'し': 'ɕi',
  'す': 'sɯ',
  'せ': 'se',
  'そ': 'so',
  'た': 'ta',
  'ち': 'tɕi',
  'つ': 'tsɯ',
  'て': 'te',
  'と': 'to',
  'な': 'na',
  'に': 'ni',
  'ぬ': 'nɯ',
  'ね': 'ne',
  'の': 'no',
  'は': 'ha',
  'ひ': 'çi',
  'ふ': 'ɸɯ',
  'へ': 'he',
  'ほ': 'ho',
  'ま': 'ma',
  'み': 'mi',
  'む': 'mɯ',
  'め': 'me',
  'も': 'mo',
  'や': 'ja',
  'ゆ': 'jɯ',
  'よ': 'jo',
  'ら': 'ɾa',
  'り': 'ɾi',
  'る': 'ɾɯ',
  'れ': 'ɾe',
  'ろ': 'ɾo',
  'わ': 'wa',
  'を': 'o',
  'が': 'ɡa',
  'ぎ': 'ɡi',
  'ぐ': 'ɡɯ',
  'げ': 'ɡe',
  'ご': 'ɡo',
  'ざ': 'za',
  'じ': 'dʑi',
  'ず': 'zɯ',
  'ぜ': 'ze',
  'ぞ': 'zo',
  'だ': 'da',
  'ぢ': 'dʑi',
  'づ': 'dzɯ',
  'で': 'de',
  'ど': 'do',
  'ば': 'ba',
  'び': 'bi',
  'ぶ': 'bɯ',
  'べ': 'be',
  'ぼ': 'bo',
  'ぱ': 'pa',
  'ぴ': 'pi',
  'ぷ': 'pɯ',
  'ぺ': 'pe',
  'ぽ': 'po',
  'ん': 'ɴ',
};
String kanaIpaFor(String kana) => kanaIPA[kana] ?? '';
const russianVowels = ['а', 'я', 'о', 'ё', 'у', 'ю', 'ы', 'и', 'э', 'е'];
final russianConsonants = 'бвгджзйклмнпрстфхцчшщ'.split('');
bool uncommon(String c, String v) =>
    c == 'й' ||
    ('гкхжшчщ'.contains(c) && v == 'ы') ||
    ('жшчщц'.contains(c) && 'яю'.contains(v)) ||
    ('чщ'.contains(c) && v == 'э');

const russianRomanConsonants = {
  'б': 'b',
  'в': 'v',
  'г': 'g',
  'д': 'd',
  'ж': 'zh',
  'з': 'z',
  'й': 'y',
  'к': 'k',
  'л': 'l',
  'м': 'm',
  'н': 'n',
  'п': 'p',
  'р': 'r',
  'с': 's',
  'т': 't',
  'ф': 'f',
  'х': 'kh',
  'ц': 'ts',
  'ч': 'ch',
  'ш': 'sh',
  'щ': 'shch',
};
const russianRomanVowels = {
  'а': 'a',
  'я': 'ya',
  'о': 'o',
  'ё': 'yo',
  'у': 'u',
  'ю': 'yu',
  'ы': 'y',
  'и': 'i',
  'э': 'e',
  'е': 'e',
};
const russianIPAConsonants = {
  'б': 'b',
  'в': 'v',
  'г': 'ɡ',
  'д': 'd',
  'ж': 'ʐ',
  'з': 'z',
  'й': 'j',
  'к': 'k',
  'л': 'l',
  'м': 'm',
  'н': 'n',
  'п': 'p',
  'р': 'r',
  'с': 's',
  'т': 't',
  'ф': 'f',
  'х': 'x',
  'ц': 't͡s',
  'ч': 't͡ɕ',
  'ш': 'ʂ',
  'щ': 'ɕː',
};
const russianIPAVowels = {
  'а': 'a',
  'я': 'a',
  'о': 'o',
  'ё': 'o',
  'у': 'u',
  'ю': 'u',
  'ы': 'ɨ',
  'и': 'i',
  'э': 'e',
  'е': 'e',
};
const frenchIPAVowels = {
  'a': 'a',
  'e': 'ə~ɛ',
  'i': 'i',
  'o': 'o',
  'u': 'y',
  'y': 'i',
};
const frenchIPAConsonants = {
  'b': 'b',
  'd': 'd',
  'f': 'f',
  'k': 'k',
  'l': 'l',
  'm': 'm',
  'n': 'n',
  'p': 'p',
  's': 's',
  't': 't',
  'v': 'v',
  'z': 'z',
};
const spanishIPAVowels = {'a': 'a', 'e': 'e', 'i': 'i', 'o': 'o', 'u': 'u'};
const spanishIPAConsonants = {
  'b': 'b',
  'd': 'd',
  'f': 'f',
  'k': 'k',
  'l': 'l',
  'm': 'm',
  'n': 'n',
  'ñ': 'ɲ',
  'p': 'p',
  's': 's',
  't': 't',
  'v': 'b',
  'w': 'w',
  'y': 'ʝ',
};
const germanIPAVowels = {
  'a': 'aː~a',
  'ä': 'ɛː~ɛ',
  'e': 'eː~ɛ',
  'i': 'iː~ɪ',
  'o': 'oː~ɔ',
  'ö': 'øː~œ',
  'u': 'uː~ʊ',
  'ü': 'yː~ʏ',
  'y': 'i~y',
};
const germanIPAConsonants = {
  'b': 'b',
  'c': 'k~ts',
  'd': 'd',
  'f': 'f',
  'g': 'ɡ',
  'h': 'h',
  'j': 'j',
  'k': 'k',
  'l': 'l',
  'm': 'm',
  'n': 'n',
  'p': 'p',
  'q': 'kv',
  'r': 'ʁ',
  's': 'z~s',
  't': 't',
  'v': 'f~v',
  'w': 'v',
  'x': 'ks',
  'z': 'ts',
  'ch': 'ç~x',
  'sch': 'ʃ',
  'sp': 'ʃp',
  'st': 'ʃt',
  'pf': 'pf',
  'tsch': 'tʃ',
};

String germanConsonantIPA(String consonant, String vowel) {
  if (consonant == 'c') return 'eiyäöü'.contains(vowel) ? 'ts' : 'k';
  if (consonant == 'ch') return 'ç~x';
  return germanIPAConsonants[consonant] ?? consonant;
}

const germanVowels = ['a', 'ä', 'e', 'i', 'o', 'ö', 'u', 'ü', 'y'];
const germanConsonants = [
  'b',
  'c',
  'd',
  'f',
  'g',
  'h',
  'j',
  'k',
  'l',
  'm',
  'n',
  'p',
  'q',
  'r',
  's',
  't',
  'v',
  'w',
  'x',
  'z',
  'ch',
  'sch',
  'sp',
  'st',
  'pf',
  'tsch',
];
const germanQOverrides = {
  'q|a': 'qua',
  'q|ä': 'quä',
  'q|e': 'que',
  'q|i': 'qui',
  'q|o': 'quo',
  'q|ö': 'quö',
  'q|u': 'quu',
  'q|ü': 'quü',
};
String russianHintForVowel(String vowel) =>
    '${russianRomanVowels[vowel]} /${russianIPAVowels[vowel]}/';
String russianHintForConsonant(String consonant) =>
    '${russianRomanConsonants[consonant]} /${russianIPAConsonants[consonant]}/';
String russianHintForSyllable(String consonant, String vowel) {
  final roman =
      '${russianRomanConsonants[consonant]}${russianRomanVowels[vowel]}';
  var ipa = russianIPAConsonants[consonant]!;
  if ('яёюеи'.contains(vowel) && !'жшцйчщ'.contains(consonant)) ipa += 'ʲ';
  final ipaVowel = 'жшц'.contains(consonant) && vowel == 'и'
      ? 'ɨ'
      : russianIPAVowels[vowel]!;
  return '$roman /$ipa$ipaVowel/';
}

const arabicVowels = ['َ', 'ِ', 'ُ'];
const arabicConsonants = [
  'ء',
  'ب',
  'ت',
  'ث',
  'ج',
  'ح',
  'خ',
  'د',
  'ذ',
  'ر',
  'ز',
  'س',
  'ش',
  'ص',
  'ض',
  'ط',
  'ظ',
  'ع',
  'غ',
  'ف',
  'ق',
  'ك',
  'ل',
  'م',
  'ن',
  'ه',
  'و',
  'ي',
];
const arabicRomanVowels = {'َ': 'a', 'ِ': 'i', 'ُ': 'u'};
const arabicIPAVowels = {'َ': 'a', 'ِ': 'i', 'ُ': 'u'};
const arabicRomanConsonants = {
  'ء': 'ʾ',
  'ب': 'b',
  'ت': 't',
  'ث': 'th',
  'ج': 'j',
  'ح': 'ḥ',
  'خ': 'kh',
  'د': 'd',
  'ذ': 'dh',
  'ر': 'r',
  'ز': 'z',
  'س': 's',
  'ش': 'sh',
  'ص': 'ṣ',
  'ض': 'ḍ',
  'ط': 'ṭ',
  'ظ': 'ẓ',
  'ع': 'ʿ',
  'غ': 'gh',
  'ف': 'f',
  'ق': 'q',
  'ك': 'k',
  'ل': 'l',
  'م': 'm',
  'ن': 'n',
  'ه': 'h',
  'و': 'w',
  'ي': 'y',
};
const arabicIPAConsonants = {
  'ء': 'ʔ',
  'ب': 'b',
  'ت': 't',
  'ث': 'θ',
  'ج': 'd͡ʒ',
  'ح': 'ħ',
  'خ': 'x',
  'د': 'd',
  'ذ': 'ð',
  'ر': 'r',
  'ز': 'z',
  'س': 's',
  'ش': 'ʃ',
  'ص': 'sˤ',
  'ض': 'dˤ',
  'ط': 'tˤ',
  'ظ': 'ðˤ',
  'ع': 'ʕ',
  'غ': 'ɣ',
  'ف': 'f',
  'ق': 'q',
  'ك': 'k',
  'ل': 'l',
  'م': 'm',
  'ن': 'n',
  'ه': 'h',
  'و': 'w',
  'ي': 'j',
};
const koreanRomanInitials = {
  'ㄱ': 'g',
  'ㄲ': 'kk',
  'ㄴ': 'n',
  'ㄷ': 'd',
  'ㄸ': 'tt',
  'ㄹ': 'r',
  'ㅁ': 'm',
  'ㅂ': 'b',
  'ㅃ': 'pp',
  'ㅅ': 's',
  'ㅆ': 'ss',
  'ㅇ': '',
  'ㅈ': 'j',
  'ㅉ': 'jj',
  'ㅊ': 'ch',
  'ㅋ': 'k',
  'ㅌ': 't',
  'ㅍ': 'p',
  'ㅎ': 'h',
};
const koreanIPAInitials = {
  'ㄱ': 'k',
  'ㄲ': 'k͈',
  'ㄴ': 'n',
  'ㄷ': 't',
  'ㄸ': 't͈',
  'ㄹ': 'ɾ',
  'ㅁ': 'm',
  'ㅂ': 'p',
  'ㅃ': 'p͈',
  'ㅅ': 's',
  'ㅆ': 's͈',
  'ㅇ': '',
  'ㅈ': 't͡ɕ',
  'ㅉ': 't͡ɕ͈',
  'ㅊ': 't͡ɕʰ',
  'ㅋ': 'kʰ',
  'ㅌ': 'tʰ',
  'ㅍ': 'pʰ',
  'ㅎ': 'h',
};
const koreanRomanVowels = {
  'ㅏ': 'a',
  'ㅐ': 'ae',
  'ㅑ': 'ya',
  'ㅒ': 'yae',
  'ㅓ': 'eo',
  'ㅔ': 'e',
  'ㅕ': 'yeo',
  'ㅖ': 'ye',
  'ㅗ': 'o',
  'ㅘ': 'wa',
  'ㅙ': 'wae',
  'ㅚ': 'oe',
  'ㅛ': 'yo',
  'ㅜ': 'u',
  'ㅝ': 'wo',
  'ㅞ': 'we',
  'ㅟ': 'wi',
  'ㅠ': 'yu',
  'ㅡ': 'eu',
  'ㅢ': 'ui',
  'ㅣ': 'i',
};
const koreanIPAVowels = {
  'ㅏ': 'a',
  'ㅐ': 'ɛ~e',
  'ㅑ': 'ja',
  'ㅒ': 'jɛ~je',
  'ㅓ': 'ʌ',
  'ㅔ': 'e',
  'ㅕ': 'jʌ',
  'ㅖ': 'je',
  'ㅗ': 'o',
  'ㅘ': 'wa',
  'ㅙ': 'wɛ~we',
  'ㅚ': 'we',
  'ㅛ': 'jo',
  'ㅜ': 'u',
  'ㅝ': 'wʌ',
  'ㅞ': 'we',
  'ㅟ': 'wi',
  'ㅠ': 'ju',
  'ㅡ': 'ɯ',
  'ㅢ': 'ɯi',
  'ㅣ': 'i',
};
const koreanRomanCodas = {
  '': '',
  'ㄱ': 'g',
  'ㄲ': 'kk',
  'ㄳ': 'gs',
  'ㄴ': 'n',
  'ㄵ': 'nj',
  'ㄶ': 'nh',
  'ㄷ': 'd',
  'ㄹ': 'l',
  'ㄺ': 'lg',
  'ㄻ': 'lm',
  'ㄼ': 'lb',
  'ㄽ': 'ls',
  'ㄾ': 'lt',
  'ㄿ': 'lp',
  'ㅀ': 'lh',
  'ㅁ': 'm',
  'ㅂ': 'b',
  'ㅄ': 'bs',
  'ㅅ': 's',
  'ㅆ': 'ss',
  'ㅇ': 'ng',
  'ㅈ': 'j',
  'ㅊ': 'ch',
  'ㅋ': 'k',
  'ㅌ': 't',
  'ㅍ': 'p',
  'ㅎ': 'h',
};
const koreanIPACodas = {
  '': '',
  'ㄱ': 'k̚',
  'ㄲ': 'k̚',
  'ㄳ': 'k̚',
  'ㄴ': 'n',
  'ㄵ': 'n',
  'ㄶ': 'n',
  'ㄷ': 't̚',
  'ㄹ': 'l',
  'ㄺ': 'k̚',
  'ㄻ': 'm',
  'ㄼ': 'p̚',
  'ㄽ': 'l',
  'ㄾ': 'l',
  'ㄿ': 'p̚',
  'ㅀ': 'l',
  'ㅁ': 'm',
  'ㅂ': 'p̚',
  'ㅄ': 'p̚',
  'ㅅ': 't̚',
  'ㅆ': 't̚',
  'ㅇ': 'ŋ',
  'ㅈ': 't̚',
  'ㅊ': 't̚',
  'ㅋ': 'k̚',
  'ㅌ': 't̚',
  'ㅍ': 'p̚',
  'ㅎ': 't̚',
};

enum SyllableKind { alphabetic, hangul }

class PronunciationCourse {
  final String title;
  final String language;
  final List<String> vowels;
  final List<String> consonants;
  final String notice;
  final SyllableKind kind;
  final List<String> codas;
  final Set<String> rareConsonants;
  final Set<String> unavailable;
  final Map<String, String> overrides;

  const PronunciationCourse({
    required this.title,
    required this.language,
    required this.vowels,
    required this.consonants,
    required this.notice,
    this.kind = SyllableKind.alphabetic,
    this.codas = const [],
    this.rareConsonants = const {},
    this.unavailable = const {},
    this.overrides = const {},
  });

  bool get isHangul => kind == SyllableKind.hangul;

  String displayVowel(String vowel) => language == 'ar-SA' ? '◌$vowel' : vowel;

  String speechTextForVowel(String vowel) =>
      language == 'ar-SA' ? 'ء$vowel' : vowel;

  String? syllable(String consonant, String vowel, [String coda = '']) {
    if (unavailable.contains('$consonant|$vowel')) return null;
    if (isHangul) {
      final initial = hangulInitials.indexOf(consonant);
      final medial = hangulVowelOrder.indexOf(vowel);
      final finalIndex = hangulFinals.indexOf(coda);
      if (initial < 0 || medial < 0 || finalIndex < 0) return null;
      return String.fromCharCode(
        0xac00 + ((initial * 21 + medial) * 28) + finalIndex,
      );
    }
    return overrides['$consonant|$vowel'] ?? '$consonant$vowel';
  }

  bool isRare(String consonant) => rareConsonants.contains(consonant);

  String pronunciationHintForVowel(String vowel) {
    if (language == 'ar-SA') {
      return '${arabicRomanVowels[vowel]} /${arabicIPAVowels[vowel]}/';
    }
    if (isHangul) {
      return '${koreanRomanVowels[vowel]} /${koreanIPAVowels[vowel]}/';
    }
    if (language == 'ru-RU') {
      return '${russianRomanVowels[vowel]} /${russianIPAVowels[vowel]}/';
    }
    if (language == 'fr-FR') return '/${frenchIPAVowels[vowel]}/';
    if (language == 'es-ES') return '/${spanishIPAVowels[vowel]}/';
    if (language == 'de-DE') {
      return '$vowel /${germanIPAVowels[vowel] ?? vowel}/';
    }
    return vowel;
  }

  String pronunciationHintForConsonant(String consonant) {
    if (language == 'ar-SA') {
      return '${arabicRomanConsonants[consonant]} /${arabicIPAConsonants[consonant]}/';
    }
    if (isHangul) {
      final roman = koreanRomanInitials[consonant] ?? consonant;
      final ipa = koreanIPAInitials[consonant] ?? consonant;
      return roman.isEmpty ? '— /∅/' : '$roman /$ipa/';
    }
    if (language == 'ru-RU') {
      return '${russianRomanConsonants[consonant]} /${russianIPAConsonants[consonant]}/';
    }
    if (language == 'de-DE') {
      return '/${germanIPAConsonants[consonant] ?? consonant}/';
    }
    if (language == 'fr-FR') {
      switch (consonant) {
        case 'c':
          return '/k~s/';
        case 'g':
          return '/ɡ~ʒ/';
        case 'h':
          return '不发音 /∅/';
        case 'q':
          return '/k/';
        case 'ch':
          return '/ʃ/';
        case 'gn':
          return '/ɲ/';
        case 'ph':
          return '/f/';
        case 'r':
          return '/ʁ/';
        case 'w':
          return '/w~v/';
        case 'x':
          return '/ks/';
        default:
          return '/${frenchIPAConsonants[consonant] ?? consonant}/';
      }
    }
    if (language == 'es-ES') {
      switch (consonant) {
        case 'c':
          return '/k~θ/';
        case 'g':
          return '/ɡ~x/';
        case 'h':
          return '不发音 /∅/';
        case 'q':
          return '/k/';
        case 'r':
          return '词首颤音 /r/';
        case 'v':
          return '/b/';
        case 'ch':
          return '/tʃ/';
        case 'j':
          return '/x/';
        case 'x':
          return '/ks/';
        case 'y':
        case 'll':
          return '/ʝ/';
        case 'z':
          return '/θ/';
        default:
          return '/${spanishIPAConsonants[consonant] ?? consonant}/';
      }
    }
    return consonant;
  }

  String pronunciationHint(String consonant, String vowel, [String coda = '']) {
    if (language == 'ar-SA') {
      return '${arabicRomanConsonants[consonant]}${arabicRomanVowels[vowel]} '
          '/${arabicIPAConsonants[consonant]}${arabicIPAVowels[vowel]}/';
    }
    if (isHangul) {
      final roman =
          (koreanRomanInitials[consonant] ?? consonant) +
          (koreanRomanVowels[vowel] ?? vowel) +
          (koreanRomanCodas[coda] ?? coda);
      final ipa =
          (koreanIPAInitials[consonant] ?? consonant) +
          (koreanIPAVowels[vowel] ?? vowel) +
          (koreanIPACodas[coda] ?? '');
      return '${roman.isEmpty ? '∅' : roman} /${ipa.isEmpty ? '∅' : ipa}/';
    }
    if (language == 'ru-RU') {
      final roman =
          '${russianRomanConsonants[consonant] ?? consonant}'
          '${russianRomanVowels[vowel] ?? vowel}';
      var ipa = russianIPAConsonants[consonant] ?? consonant;
      if ('яёюеи'.contains(vowel) && !'жшцйчщ'.contains(consonant)) ipa += 'ʲ';
      final ipaVowel = 'жшц'.contains(consonant) && vowel == 'и'
          ? 'ɨ'
          : russianIPAVowels[vowel] ?? vowel;
      return '$roman /$ipa$ipaVowel/';
    }
    if (language == 'fr-FR') {
      final initial = switch (consonant) {
        'c' => 'eiy'.contains(vowel) ? 's' : 'k',
        'g' => 'eiy'.contains(vowel) ? 'ʒ' : 'ɡ',
        'ch' => 'ʃ',
        'gn' => 'ɲ',
        'ph' => 'f',
        'h' => '',
        'j' => 'ʒ',
        'q' => 'k',
        'r' => 'ʁ',
        'w' => 'w~v',
        'x' => 'ks',
        _ => frenchIPAConsonants[consonant] ?? consonant,
      };
      final ipaVowel = consonant == 'q' && vowel == 'e'
          ? 'ə'
          : frenchIPAVowels[vowel] ?? vowel;
      return '/$initial$ipaVowel/';
    }
    if (language == 'es-ES') {
      final initial = switch (consonant) {
        'c' => 'ei'.contains(vowel) ? 'θ' : 'k',
        'g' => 'ei'.contains(vowel) ? 'x' : 'ɡ',
        'ch' => 'tʃ',
        'h' => '',
        'j' => 'x',
        'q' => 'k',
        'r' => 'r',
        'v' => 'b',
        'x' => 'ks',
        'y' || 'll' => 'ʝ',
        'z' => 'θ',
        _ => spanishIPAConsonants[consonant] ?? consonant,
      };
      return '/$initial${spanishIPAVowels[vowel] ?? vowel}/';
    }
    if (language == 'de-DE') {
      final initial = germanConsonantIPA(consonant, vowel);
      final vowelIPA = germanIPAVowels[vowel] ?? vowel;
      final soundSequence = consonant == 'ch'
          ? '$initial $vowelIPA'
          : '$initial$vowelIPA';
      final spelling = syllable(consonant, vowel, coda) ?? '$consonant$vowel';
      return '$spelling /$soundSequence/';
    }
    return '';
  }
}

const frenchCourse = PronunciationCourse(
  title: '法语拼读',
  language: 'fr-FR',
  vowels: ['a', 'e', 'i', 'o', 'u', 'y'],
  consonants: [
    'b',
    'c',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    'm',
    'n',
    'p',
    'q',
    'r',
    's',
    't',
    'v',
    'w',
    'x',
    'z',
    'ch',
    'gn',
    'ph',
  ],
  notice: '6 个元音字母与常见辅音组合可点读，并附宽式 IPA 提示。法语 e、y、c、g、q、h 及 ch / gn / ph 受拼写位置影响；q 只提供 que / qui。IPA 不覆盖鼻化、重音和全部位置规则；系统 TTS 试听不等同于人工音素录音。',
  rareConsonants: {'k', 'w', 'x'},
  unavailable: {'q|a', 'q|o', 'q|u', 'q|y'},
  overrides: {'q|e': 'que', 'q|i': 'qui'},
);

const spanishCourse = PronunciationCourse(
  title: '西班牙语拼读',
  language: 'es-ES',
  vowels: ['a', 'e', 'i', 'o', 'u'],
  consonants: [
    'b',
    'c',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    'm',
    'n',
    'ñ',
    'p',
    'q',
    'r',
    's',
    't',
    'v',
    'w',
    'x',
    'y',
    'z',
    'ch',
    'll',
  ],
  notice: '5 个元音、22 个辅音字母与常见 ch / ll 拼写组合可点读，并附宽式 IPA 提示。c、g 会随后接元音改变读音；h 不发音，q 通过 que / qui 拼写；b / v 同音。表按西班牙本土读音标注 /θ/，拉美 seseo 地区会读 /s/；k / w / x 多见于外来词。',
  rareConsonants: {'k', 'w', 'x'},
  unavailable: {'q|a', 'q|o', 'q|u'},
  overrides: {'q|e': 'que', 'q|i': 'qui'},
);

const germanCourse = PronunciationCourse(
  title: '德语拼读',
  language: 'de-DE',
  vowels: germanVowels,
  consonants: germanConsonants,
  notice: '8 个基础元音字母与 20 个基础辅音字母可组合点读，并提供常见 ch / sch / sp / st / pf / tsch 拼写。q 行组合自动补入 u；元音长短、c / ch / s / v 等读音受拼写位置和词源影响，注音为常见入门提示。系统 TTS 试听不等同于人工音素录音。',
  rareConsonants: {'c', 'q', 'x'},
  unavailable: {'q|ö', 'q|u', 'q|ü', 'q|y'},
  overrides: germanQOverrides,
);

const koreanVowels = [
  'ㅏ',
  'ㅑ',
  'ㅓ',
  'ㅕ',
  'ㅗ',
  'ㅛ',
  'ㅜ',
  'ㅠ',
  'ㅡ',
  'ㅣ',
  'ㅐ',
  'ㅒ',
  'ㅔ',
  'ㅖ',
  'ㅘ',
  'ㅙ',
  'ㅚ',
  'ㅝ',
  'ㅞ',
  'ㅟ',
  'ㅢ',
];
const hangulInitials = [
  'ㄱ',
  'ㄲ',
  'ㄴ',
  'ㄷ',
  'ㄸ',
  'ㄹ',
  'ㅁ',
  'ㅂ',
  'ㅃ',
  'ㅅ',
  'ㅆ',
  'ㅇ',
  'ㅈ',
  'ㅉ',
  'ㅊ',
  'ㅋ',
  'ㅌ',
  'ㅍ',
  'ㅎ',
];
const hangulVowelOrder = [
  'ㅏ',
  'ㅐ',
  'ㅑ',
  'ㅒ',
  'ㅓ',
  'ㅔ',
  'ㅕ',
  'ㅖ',
  'ㅗ',
  'ㅘ',
  'ㅙ',
  'ㅚ',
  'ㅛ',
  'ㅜ',
  'ㅝ',
  'ㅞ',
  'ㅟ',
  'ㅠ',
  'ㅡ',
  'ㅢ',
  'ㅣ',
];
const hangulFinals = [
  '',
  'ㄱ',
  'ㄲ',
  'ㄳ',
  'ㄴ',
  'ㄵ',
  'ㄶ',
  'ㄷ',
  'ㄹ',
  'ㄺ',
  'ㄻ',
  'ㄼ',
  'ㄽ',
  'ㄾ',
  'ㄿ',
  'ㅀ',
  'ㅁ',
  'ㅂ',
  'ㅄ',
  'ㅅ',
  'ㅆ',
  'ㅇ',
  'ㅈ',
  'ㅊ',
  'ㅋ',
  'ㅌ',
  'ㅍ',
  'ㅎ',
];
const koreanCourse = PronunciationCourse(
  title: '朝鲜语拼读',
  language: 'ko-KR',
  vowels: koreanVowels,
  consonants: hangulInitials,
  codas: hangulFinals,
  kind: SyllableKind.hangul,
  notice: '19 个声母、21 个元音可组合成韩文音节块，并可选择 27 种收音或无收音。音节附韩国修订罗马字与宽式 IPA；ㅇ 作声母时不发音。收音在词中会受连音和音变规则影响，标注只作入门提示，系统 TTS 仅供试听。',
);

const arabicCourse = PronunciationCourse(
  title: '阿拉伯语短元音拼读',
  language: 'ar-SA',
  vowels: arabicVowels,
  consonants: arabicConsonants,
  notice: '28 个辅音分别组合 َ a、ِ i、ُ u，并附简化拉丁注音与宽式 IPA。阿拉伯语日常书写通常省略短元音符号；本表不覆盖长元音、辅音连缀、词形变化和地区口音。',
);

const pronunciationCourses = [
  frenchCourse,
  spanishCourse,
  germanCourse,
  koreanCourse,
  arabicCourse,
];
String hiragana(String text) => String.fromCharCodes(
  text.runes.map(
    (code) => code >= 0x30a1 && code <= 0x30f6 ? code - 0x60 : code,
  ),
);
String spokenReading(String text) =>
    hiragana(text.replaceAll('.', '').replaceAll('-', ''));
String katakana(String text) => String.fromCharCodes(
  text.runes.map(
    (code) => code >= 0x3041 && code <= 0x3096 ? code + 0x60 : code,
  ),
);
List<Map<String, dynamic>> allowedSenses(
  Map<String, dynamic> word,
  String spelling,
  String reading,
) {
  final readings = (word['readings'] as List).cast<Map>();
  final matched = readings.where((r) => r['text'] == reading).first;
  final restriction = matched['restr'] as List;
  if ((matched['no_kanji'] == true && spelling != reading) ||
      (restriction.isNotEmpty && !restriction.contains(spelling))) {
    return [];
  }
  return (word['senses'] as List)
      .cast<Map>()
      .where((s) {
        final k = s['stagk'] as List;
        final r = s['stagr'] as List;
        return (k.isEmpty || k.contains(spelling)) &&
            (r.isEmpty || r.contains(reading));
      })
      .map((s) => Map<String, dynamic>.from(s))
      .toList();
}
