import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// **LA TASTIERA SI CHIUDE QUANDO SI ESCE DA UN CAMPO.** Ordine EV voce 05,
/// il fondatore: *"A un certo punto, iPhone si è bloccato in home con la
/// testiera aperta e ha dovuto riavviare."*
///
/// L'app non toglieva mai il fuoco da sola: la chiusura della tastiera
/// dipendeva soltanto dalla sequenza di Flutter (la rotta che esce perde il
/// fuoco, il campo si smonta, la connessione si chiude). Con piu' rotte
/// sfilate insieme, o con un campo che sparisce mentre la tastiera si apre,
/// un sistema puo' perdere l'ultimo "nascondi" e la tastiera resta su una
/// schermata che non ha campi. Qui lo si dice esplicitamente:
/// - [adesso] toglie il fuoco e chiude la tastiera, per i gesti che portano
///   via da tutto (la barra in basso);
/// - [seNessunCampo], dopo che una rotta e' uscita, chiude la tastiera se
///   nella schermata che resta nessun campo ha il fuoco.
abstract final class LaTastieraSiChiude {
  /// Quante volte la tastiera e' stata chiusa da qui: le prove lo leggono.
  static int chiusure = 0;

  static void _nascondi() {
    chiusure++;
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  /// Toglie il fuoco a qualunque campo e chiude la tastiera.
  static void adesso() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nascondi();
  }

  /// Se nessun campo di testo ha il fuoco, la tastiera si chiude.
  static bool unCampoHaIlFuoco() {
    final contesto = FocusManager.instance.primaryFocus?.context;
    if (contesto == null) return false;
    return contesto.widget is EditableText ||
        contesto.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  /// Dopo il fotogramma in cui una rotta e' uscita: se nella schermata che
  /// resta nessun campo ha il fuoco, la tastiera si chiude.
  static void seNessunCampo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!unCampoHaIlFuoco()) _nascondi();
    });
  }
}
