import 'dart:convert';
import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'package:gettext/gettext.dart';
import 'package:gettext_parser/gettext_parser.dart' as gettextParser;
import 'package:path/path.dart';
import 'package:glob/glob.dart';

final formatter = new DartFormatter();

void main(List<String> args) async {
  final files = Glob("resources/*.po")
      .list()
      .where((fileEntity) => fileEntity is File)
      .cast<File>();

  final parts = <String>[];

  await for (final file in files) {
    final data = gettextParser.po.parse(await file.readAsString());
    final name = basenameWithoutExtension(file.path);
    //final language = data["headers"]["language"];
    final out = File("lib/i18n/locale_$name.dart");
    parts.add(name);
    await out.writeAsString(_generatePart(name, data));
    print("Generated $name locale");
  }

  final locales = File("lib/i18n/locales.dart");

  await locales.writeAsString(_generateLocales(parts));
}

String _generateLocales(List<String> locales) {
  return formatter.format([
    "import 'package:gettext/gettext.dart';",
    locales.map((locale) => "part 'locale_$locale.dart';").join("\n"),
    "final catalogs = {",
    locales.map((locale) => '"$locale": catalog_$locale,').join("\n"),
    "};",
  ].join("\n\n"));
}

String _generatePart(String locale, Map<String, dynamic> data) {
  final gettext = new Gettext();
  gettext.addTranslations("__catalog", data["translations"]);

  final domains = new StringBuffer();

  gettext.catalogs["__catalog"].domains.forEach((domain, translations) {
    domains.writeln('"$domain": Translations({');

    translations.contexts.forEach((ctx, msgs) {
      domains.writeln('${_stringify(ctx)}: {');
      msgs.forEach((id, translation) {
        domains.writeln('${_stringify(id)}: Translation([');
        domains.writeAll(translation.msgstr.map(_stringify), ",");
        domains.writeln(']),');
      });
      domains.writeln('},');
    });
    domains.writeln('}),');
  });

  return formatter.format([
    "part of 'locales.dart';",
    "final catalog_$locale = Catalog({$domains});",
  ].join("\n\n"));
}

String _stringify(String msg) => 'r"' + msg.replaceAll('"', r'\"') + '"';
