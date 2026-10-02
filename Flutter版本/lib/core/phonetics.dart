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
const russianVowels = ['а', 'я', 'о', 'ё', 'у', 'ю', 'ы', 'и', 'э', 'е'];
final russianConsonants = 'бвгджзйклмнпрстфхцчшщ'.split('');
bool uncommon(String c, String v) =>
    c == 'й' ||
    ('гкхжшчщ'.contains(c) && v == 'ы') ||
    ('жшчщц'.contains(c) && 'яю'.contains(v)) ||
    ('чщ'.contains(c) && v == 'э');
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
