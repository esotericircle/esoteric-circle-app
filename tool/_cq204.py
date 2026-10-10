# -*- coding: utf-8 -*-
"""CQ2.04 e 2.09: la parola del giorno dice a cosa serve, e la sera si chiude."""
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


# --- 1. l'etichetta dice a cosa serve, non che categoria e' --------------
cambia('lib/features/rituals/ritual_gift_card.dart',
       """              Text(
                'Parola del giorno',
                key: const Key('alba_etichetta_parola'),""",
       """              // **L'ETICHETTA DICE A COSA SERVE, non che categoria e'.**
              // Ordine CQ voce 2.04, 3 settembre 2026, parole del fondatore:
              // *la parola del giorno non dice a cosa serve.*
              //
              // "Parola del giorno" e' un nome di casella: dice dove sei, non
              // cosa te ne fai. **Cio' che serve saperne sta gia' scritto nel
              // dato**, in `cosaTiResta` del Dono dell'Alba: e' una parola da
              // portare con te, che stasera il Sigillo del Sogno ti
              // richiamera'. Quella riga viveva nelle tre righe del rito, che
              // la voce 2.03 ha tolto da tutti i Doni, e senza di lei la
              // parola era diventata un titolo senza scopo.
              Text(
                'LA PAROLA DA PORTARTI DIETRO',
                key: const Key('alba_etichetta_parola'),""")

cambia('lib/features/rituals/ritual_gift_card.dart',
       """              if (gift.rito?.perche != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  gift.rito!.perche,
                  key: const Key('alba_perche_della_parola'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: abito.inchiostro, height: 1.4),
                ),
              ],""",
       """              if (gift.rito?.perche != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  gift.rito!.perche,
                  key: const Key('alba_perche_della_parola'),
                  style: TypographyTokens.corpo()
                      .copyWith(color: abito.inchiostro, height: 1.4),
                ),
              ],
              // **E DOVE VA A FINIRE, che e' la seconda meta' della stessa
              // domanda.** Ordine CQ voce 2.04. Una parola che non torna da
              // nessuna parte e' una parola che si dimentica prima di sera:
              // qui si dice che la sera torna, ed e' vero, perche' il Sigillo
              // del Sogno la richiama davvero con `richiamoDellaParola`.
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Stasera il Sigillo del Sogno te la richiama, e il giorno si '
                'chiude con lei.',
                key: const Key('alba_dove_va_la_parola'),
                style: TypographyTokens.corpo()
                    .copyWith(color: abito.inchiostroMuto, height: 1.4),
              ),""")

# --- 2. e la sera la parola si chiude, invece di essere solo nominata ---
cambia('lib/core/rituals/filo_del_giorno.dart',
       """  static String richiamoDellaParola(String parola) =>
      'Stamattina la tua parola era $parola.';""",
       """  /// **IL RICHIAMO CHIUDE IL GIRO, e prima lo apriva soltanto.**
  /// Ordine CQ voce 2.09, 3 settembre 2026.
  ///
  /// Diceva *"Stamattina la tua parola era X."* e finiva li': e' un fatto,
  /// non una risposta. Chi la legge la sera ha in mano una parola presa dodici
  /// ore prima e nessuno gli dice che farsene adesso. **Il Sigillo del Sogno
  /// e' il rito che chiude la giornata**, e la parola e' l'unica cosa che
  /// l'attraversa da capo a capo: la riga lo dice, invece di lasciarlo capire.
  ///
  /// **Non promette niente e non chiede niente**, che e' la legge dei testi di
  /// questa app: dice cosa e' successo alla parola, cioe' che ha attraversato
  /// il giorno ed e' arrivata qui.
  static String richiamoDellaParola(String parola) =>
      'Stamattina la tua parola era $parola, e ha attraversato il giorno con '
      'te: adesso si chiude qui.';""")
