import 'dart:convert';

import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gettext/gettext.dart';
import 'package:gettext_parser/gettext_parser.dart' as gettextParser;
import 'package:sprintf/sprintf.dart';

class GettextLocalizations {
  final Gettext gt;

  GettextLocalizations(this.gt);

  static GettextLocalizations of(BuildContext context) {
    return Localizations.of<GettextLocalizations>(
      context,
      GettextLocalizations,
    );
  }

  String gettext(
    String msgid, [
    List args = const [],
  ]) {
    return sprintf(gt.gettext(msgid), args);
  }

  String ngettext(
    String msgid,
    String msgidPlural,
    int count, [
    List arg = const [],
  ]) {
    return sprintf(
      gt.ngettext(msgid, msgidPlural, count),
      <dynamic>[count]..addAll(arg),
    );
  }
}

class GettextLocalizationsDelegate
    extends LocalizationsDelegate<GettextLocalizations> {
  final Map<Locale, String> locales;

  const GettextLocalizationsDelegate(this.locales);

  @override
  bool isSupported(Locale locale) => locales.containsKey(locale);

  @override
  bool shouldReload(LocalizationsDelegate<GettextLocalizations> old) => true;

  @override
  Future<GettextLocalizations> load(Locale locale) async {
    final fileName = locales[locale];

    final data = await rootBundle.load(fileName);
    final loader = _loaders[extension(fileName)];
    final catalog = loader(data);

    final gettext = new Gettext();
    gettext.addTranslations(locale.toString(), catalog["translations"]);
    gettext.locale = locale.toString();

    return GettextLocalizations(gettext);
  }
}

int some(int v) => null;

const _loaders = {
  ".json": _json,
  ".mo": _mo,
  ".po": _po,
};

Map<String, dynamic> _json(ByteData data) {
  return json.decode(utf8.decode(data.buffer.asUint8List()));
}

Map<String, dynamic> _mo(ByteData data) {
  return gettextParser.mo.parse(data);
}

Map<String, dynamic> _po(ByteData data) {
  return gettextParser.po.parse(utf8.decode(data.buffer.asUint8List()));
}