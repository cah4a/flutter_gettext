import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gettext/flutter_gettext.dart';

void main() {
  runApp(new MyApp());
}

final localizations = {
  Locale('en', 'US'): 'assets/l10n/en_US.json',
  Locale('fr', 'FR'): 'assets/l10n/fr_FR.po',
  Locale('es', 'ES'): 'assets/l10n/es_ES.mo',
};

final locales = localizations.keys.toList();

final gettextLocalizationsDelegate =
    new GettextLocalizationsDelegate(localizations);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void nextLocale(BuildContext context) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());

    final index = locales.indexOf(state.locale);
    state.setLocale(locales[(index + 1) % locales.length]);
  }

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.ancestorStateOfType(TypeMatcher<_MyAppState>());
    state.setLocale(locale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale locale = locales.first;

  setLocale(Locale locale) {
    setState(() => this.locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      locale: locale,
      localizationsDelegates: [
        gettextLocalizationsDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: locales,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gt = GettextLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(title: Text(gt.gettext("Hello, %s", [locale.toString()]))),
      body: Center(
        child: RaisedButton(
          child: Text(gt.gettext("Change")),
          onPressed: () {
            MyApp.nextLocale(context);
          },
        ),
      ),
    );
  }
}
