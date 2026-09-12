# -*- coding: utf-8 -*-
"""CQ1.03, seconda parte: via il flag dell'avvio, il pulsante cambia posto."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/tarot/stesa_tre_carte_screen.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:70])
    s = s.replace(vecchio, nuovo)


# --- il campo sparisce --------------------------------------------------
cambia("""  /// **SE LA LETTURA E' STATA AVVIATA. Ordine CO voce 07**, 3 settembre 2026.
  ///
  /// Il fondatore ha chiesto un pulsante esplicito per cominciare, e la
  /// ragione si vede aprendo la schermata: c'era un ventaglio di carte coperte
  /// e nient'altro. **Chi arrivava qui non sapeva che si cominciava toccando
  /// una carta**, perche' niente glielo diceva: la stesa cominciava sul primo
  /// tocco, e un rito che comincia senza che nessuno l'abbia cominciato non e'
  /// un rito, e' un incidente.
  ///
  /// Falso finche' non si preme. Da quel momento il ventaglio accetta i tocchi
  /// e il rito e' cominciato per volonta' di chi lo compie.
  bool _letturaAvviata = false;

""", '')

# --- il metodo dell'avvio sparisce, il cancello resta -------------------
cambia("""  /// Avvia la lettura: e' il pulsante, ed e' l'unico punto che la comincia.
  ///
  /// **Il cancello del piano si guarda QUI e non alla prima carta.** Ordine CO
  /// voce 07: prima si guardava sul primo tocco, che era il momento giusto
  /// finche' il primo tocco era l'inizio. Adesso l'inizio e' questo, e chi non
  /// puo' stendere lo scopre premendo "Inizia la lettura" invece che
  /// toccando una carta che poi non si muove.
  void _avviaLaLettura() {
    if (_letturaAvviata) return;
    if (!_laStesaSiPuoAprire(riprova: _avviaLaLettura)) return;
    unawaited(PaletteSensoriale.momento(context,
        aptica: SchemaAptico.conferma, suono: SuonoDelCerchio.soglia));
    setState(() => _letturaAvviata = true);
  }

""", '')

cambia("""    // **IL CANCELLO NON STA PIU' QUI**, sta su `_avviaLaLettura`, che e' il
    // pulsante: ordine CO voce 07. Guardarlo di nuovo a ogni carta sarebbe la
    // seconda porta sullo stesso permesso.
""", """    // **IL CANCELLO NON STA PIU' QUI**, sta su `_apriIlResponso`, che e' il
    // pulsante: ordine CQ voce 1.03. Guardarlo di nuovo a ogni carta sarebbe
    // la seconda porta sullo stesso permesso, e per di piu' farebbe pagare
    // una stesa a chi si limita a scegliere.
""")

# --- il pulsante esce dal blocco delle carte da pescare -----------------
vecchio_pulsante = """          // **IL PULSANTE CHE COMINCIA LA LETTURA. Ordine CO voce 07**, 3
          // settembre 2026.
          //
          // Prima qui c'era il ventaglio e nient'altro: chi arrivava non
          // sapeva che si cominciava toccando una carta, e la stesa partiva
          // sul primo tocco. **Un rito che comincia senza che nessuno l'abbia
          // cominciato non e' un rito, e' un incidente**, e chi non poteva
          // stenderla lo scopriva toccando una carta che poi non si muoveva.
          //
          // Sparisce appena la lettura e' avviata: da li' in poi il ventaglio
          // parla da solo, e un pulsante che resta acceso dopo aver fatto il
          // suo lavoro e' una cosa in piu' da capire.
          if (!_letturaAvviata) ...[
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: FilledButton.icon(
                key: const Key('stesa_inizia'),
                onPressed: _avviaLaLettura,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Inizia la lettura'),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                      vertical: SpacingTokens.sm),
                  textStyle: TypographyTokens.titoloDiRiga(),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xxs),
            Center(
              child: Text(
                'Poi scegli tre carte dal ventaglio.',
                key: const Key('stesa_inizia_come'),
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
"""
cambia(vecchio_pulsante, '')

# --- e rinasce dopo le tre carte ---------------------------------------
ancora = """        // La sintesi memorabile, sopra le tre carte.
        if (_responsoInScena) ...["""
cambia(ancora, """        // **IL PULSANTE CHE APRE IL RESPONSO. Ordine CQ voce 1.03**, 3
        // settembre 2026, e ribalta l'ordine CO voce 07.
        //
        // **Sta fuori dal blocco `!_complete`, e la prima stesura di questa
        // voce ci era caduta dentro.** Li' spariva esattamente nell'istante in
        // cui doveva accendersi, cioe' alla terza carta, e nessuna prova che
        // lo cercava lo trovava piu'.
        //
        // C'e' sempre finche' il responso non e' aperto, e si accende solo a
        // tre carte posate: **chi arriva vede subito cosa dovra' premere**, e
        // vede anche che adesso non si puo'. Scegliere non consuma niente,
        // premere si'.
        if (!_responsoPronto) ...[
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: FilledButton.icon(
              key: const Key('stesa_inizia'),
              onPressed: _complete && !_stoPerRiflettere
                  ? () => unawaited(_apriIlResponso())
                  : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Leggi il responso'),
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                disabledBackgroundColor: palette.gold.withValues(alpha: 0.22),
                disabledForegroundColor:
                    palette.deepest.withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
                textStyle: TypographyTokens.titoloDiRiga(),
              ),
            ),
          ),
          if (!_complete) ...[
            const SizedBox(height: SpacingTokens.xxs),
            Center(
              child: Text(
                'Scegli tre carte dal ventaglio, poi premi qui.',
                key: const Key('stesa_inizia_come'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.md),
        ],
""" + ancora)

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO. _letturaAvviata rimasto:', s.count('_letturaAvviata'))
print('stesa_inizia presente:', s.count("Key('stesa_inizia')"))
