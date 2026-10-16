# -*- coding: utf-8 -*-
"""CQ2.02: il Soffio risponde con la sua materia, non con quella dell'Alba."""
NL = chr(10)
CR = chr(13)


def cambia(percorso, vecchio, nuovo, quante=1):
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (percorso, s.count(vecchio),
                                        vecchio[:70])
    s = s.replace(vecchio, nuovo)
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    assert nuovo.split(NL)[0].strip() in \
        open(percorso, 'rb').read().decode('utf-8'), percorso
    print('FATTO', percorso)


# --- 1. il Soffio sa comporre il proprio titolo e la propria risposta ---
cambia('lib/core/rituals/risposta_del_soffio.dart',
       """  /// Vero quando c'e' almeno una delle due righe.
  bool get ceQualcosa => apre != null || nonForzare != null;""",
       """  /// Vero quando c'e' almeno una delle due righe.
  bool get ceQualcosa => apre != null || nonForzare != null;

  /// **IL TITOLO E LA RISPOSTA DEL SOFFIO, DALLA SUA MATERIA.**
  /// Ordine CQ voce 2.02, 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** l'Alba e il Soffio danno risposte
  /// identiche.
  ///
  /// **La causa, misurata.** Il Soffio costruisce il suo dono con
  /// `DawnGift.forMaestro`, che dentro chiama `RitoAlba.diOggi` con la sola
  /// data: **il rito, la parola e la risposta erano letteralmente gli stessi
  /// oggetti dell'Alba.** Cambiava il Maestro nella cornice e nient'altro. Due
  /// Doni che dicono la stessa cosa a due ore di distanza sono un Dono solo
  /// mostrato due volte.
  ///
  /// **E il Soffio la sua materia ce l'aveva gia'**, ed e' questa classe: i
  /// transiti veri sulla carta di questa persona, cio' che si apre e cio' che
  /// non si lascia forzare. Stava piu' in basso nella schermata, sotto la
  /// risposta di un altro rito. Adesso sale in cima, dove la legge dei testi
  /// vuole la risposta.
  ///
  /// **Il titolo e' una frase chiusa e non promette niente**, come i nove del
  /// Risveglio: dice come sta il cielo di oggi per questa persona, e chi legge
  /// solo quella riga ha gia' ricevuto qualcosa.
  RispostaDelDono comeRisposta() {
    final titolo = switch ((apre != null, nonForzare != null)) {
      (true, true) => 'Oggi il tuo cielo ha una porta aperta e una che non '
            'cede.',
      (true, false) => 'Oggi il tuo cielo ha una porta aperta.',
      (false, true) => 'Oggi il tuo cielo ha un terreno che non si lascia '
            'forzare.',
      _ => 'Oggi il tuo cielo non ha ne aperture ne resistenze marcate.',
    };
    final righe = [
      if (apre != null) apre!,
      if (nonForzare != null) nonForzare!,
    ];
    return RispostaDelDono(
      titolo: titolo,
      risposta: righe.join(' '),
    );
  }""")

cambia('lib/core/rituals/risposta_del_soffio.dart',
       """import '../astro/effemeridi.dart';""",
       """import '../astro/effemeridi.dart';
import 'risposta_del_dono.dart';""")

# --- 2. il dono accetta una risposta propria ---------------------------
cambia('lib/core/rituals/dawn_gift.dart',
       """  static DawnGift forMaestro(DateTime date, Maestro maestro,
      {BirthIdentity? identity,
      PosizioneDiStamattina? posizione,
      NatalChart? carta}) {""",
       """  /// **[rispostaPropria] E' LA RISPOSTA DEL DONO CHE CHIAMA.**
  /// Ordine CQ voce 2.02, 3 settembre 2026.
  ///
  /// Il Soffio del Destino passava di qui e riceveva il rito dell'Alba
  /// identico, risposta compresa: **due Doni con la stessa risposta a due ore
  /// di distanza sono un Dono solo mostrato due volte.** Chi ha una materia
  /// sua la passa qui, e il gesto e la parola restano quelli del rito, che
  /// sono la parte comune.
  static DawnGift forMaestro(DateTime date, Maestro maestro,
      {BirthIdentity? identity,
      PosizioneDiStamattina? posizione,
      NatalChart? carta,
      RispostaDelDono? rispostaPropria}) {""")

cambia('lib/core/rituals/dawn_gift.dart',
       """    final rito =
        RitoAlba.diOggi(date, posizione: posizione, soleNatale: natalSun);""",
       """    final ritoDelGiorno =
        RitoAlba.diOggi(date, posizione: posizione, soleNatale: natalSun);
    final rito = rispostaPropria == null || ritoDelGiorno == null
        ? ritoDelGiorno
        : ritoDelGiorno.conRisposta(rispostaPropria);""")

print('parte del dono fatta')
