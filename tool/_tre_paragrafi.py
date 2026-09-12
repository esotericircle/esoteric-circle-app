# -*- coding: utf-8 -*-
"""CQ6.19 e 6.22: la bolla della runa diventa tre paragrafi, giallo bianco
giallo, nella prosa ampia, con le fonti dietro la porta per OGNI gettata."""
import io

NL = chr(10)
A = chr(39)
CR = chr(13)
F = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'

grezzo = io.open(F, 'rb').read().decode('utf-8')
crlf = (CR + NL) in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

inizio = s.index('            if (sola)' + NL + '              _IlRestoDellaRuna(')
fine = s.index("                  stile: TypographyTokens.lettura()" + NL +
               "                      .copyWith(color: ColorTokens.textSecondary))," + NL +
               "            ],", inizio)
fine = s.index('],', fine) + 3

nuovo = '''            // **TRE PARAGRAFI, E BASTA. Ordine CQ voci 6.19 e 6.22,
            // 4 settembre 2026.**
            //
            // Parole del fondatore: *Intestazione con immagine runa OK. Poi
            // sotto 3 paragrafi: Giallo, Bianco, Giallo.* E prima: *per
            // quanto riguarda la quantita' di testo nelle bolle delle singole
            // rune, non hai fatto nulla?*
            //
            // **Aveva ragione.** La porta valeva per la sola runa singola,
            // per una decisione mia: *a tre e a cinque restano dove erano,
            // perche' li' sono il corpo della lettura*. Misurato sui suoi
            // screenshot: **1833 caratteri per la gettata a tre, 3055 per la
            // Croce delle Cinque.** E' una parete.
            //
            // **La soluzione si posa da sola.** Dietro la porta vanno la
            // materia storica e la strofa, che sono la FONTE e per la legge
            // dei testi stanno brevi e in fondo. Restano esattamente i tre
            // paragrafi che il fondatore chiede, e i colori seguono il senso:
            // il significato e il cielo sono di Caligo, la risposta e' la
            // voce che parla a te.
            //
            // **UNO. Il significato del segno, in oro.**
            ParagrafiDiLettura(
                key: Key('rune_meaning_$indice'),
                testo: runa.rune.meaning,
                stile: TypographyTokens.letturaAmpia()
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            // **DUE. La risposta, in bianco**: e' cio' che la runa dice a te,
            // e sta in mezzo perche' e' la cosa che conta.
            ParagrafiDiLettura(
                key: Key('rune_riga_$indice'),
                testo: runa.riga,
                stile: TypographyTokens.letturaAmpia()
                    .copyWith(color: ColorTokens.textPrimary)),
            // **TRE. Il cielo con la domanda, in oro.** Qui vive la frase che
            // nomina la domanda scritta, una volta sola su tutta la gettata.
            if (voce != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              ParagrafiDiLettura(
                  key: Key('rune_voce_$indice'),
                  testo: voce!,
                  stile: TypographyTokens.letturaAmpia()
                      .copyWith(color: palette.goldSoft)),
            ],
            // **E LA FONTE STA DIETRO LA PORTA, per ogni gettata.** Non
            // sparisce: si apre. Chi vuole sapere da dove nasce la runa tocca
            // e legge; chi vuole la risposta l'ha gia' letta qui sopra.
            if ((daDoveNasce != null && daDoveNasce!.trim().isNotEmpty) ||
                kRuneLore[runa.rune.name] != null)
              _IlRestoDellaRuna(
                indice: indice,
                palette: palette,
                simbolo: daDoveNasce,
                voce: null,
                strofa: kRuneLore[runa.rune.name] == null
                    ? null
                    : '${kRuneLore[runa.rune.name]!.strofe.first.fonte}: '
                        '\\u00ab${kRuneLore[runa.rune.name]!.strofe.first.traduzione}\\u00bb',
              ),
'''

s = s[:inizio] + nuovo + s[fine:]
io.open(F, 'wb').write(
    (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('BOLLA RISCRITTA A TRE PARAGRAFI')
