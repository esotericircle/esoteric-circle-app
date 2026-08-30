import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'navigation_controller.dart';
import 'vie_del_cerchio.dart';

/// Bottom bar a cinque voci: Santuario, i tre Maestri nell'ordine fisso
/// (Medora, Caligo, Aura) e il Cosmic Passport, distinto e staccato.
///
/// Le voci Maestro sono porte dirette al dominio del Maestro, non centrano il
/// busto: il cambio del centro nel Santuario avviene col carosello. Nel
/// Santuario resta acceso solo Santuario; le icone Maestro restano spente,
/// sono scorciatoie verso i domini.
class SantuarioBottomBar extends StatelessWidget {
  const SantuarioBottomBar({
    super.key,
    required this.view,
    required this.onSantuario,
    required this.onMaestro,
    required this.onPassport,
    this.maestroCorrente,
    this.fuoriDalGuscio = false,
  });

  /// Vero quando la schermata in cima e' una rotta spinta SOPRA il guscio
  /// (dominio, chat, Consiglio): le voci del guscio, Il Cerchio e Passport,
  /// restano SPENTE, perche' la vista sotto e' solo la provenienza. Ordine
  /// 2163, voce 6: nel Consiglio, arrivandoci dal Passport, la voce
  /// Passport restava accesa mentre la schermata era il Consiglio.
  final bool fuoriDalGuscio;

  /// Il Maestro di cui si sta guardando il dominio o la chat, quando si e'
  /// fuori dal guscio.
  ///
  /// **E' "dove sei", e da qui in avanti conta.** Finche' la barra viveva
  /// dentro il guscio le icone Maestro erano solo scorciatoie e restavano tutte
  /// spente, perche' da li' non si era mai "da" un Maestro. Adesso la barra si
  /// vede anche nel dominio e nella chat, e li' una voce accesa dice dove si e'
  /// invece di lasciarlo indovinare. Nullo dentro il guscio, dove a dirlo e'
  /// gia' la vista.
  final Maestro? maestroCorrente;

  final ShellView view;
  final VoidCallback onSantuario;
  final ValueChanged<Maestro> onMaestro;
  final VoidCallback onPassport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onSantuarioView = view == ShellView.santuario;

    // **LA BARRA SI PORTA IL SUO MATERIAL, e da oggi le serve.** Le sue voci
    // sono `InkWell`, che pretende un `Material` antenato: dentro il guscio
    // glielo dava lo Scaffold, ma sopra il Navigator non c'e' nessuno Scaffold
    // e la barra non si costruiva affatto. Trasparente, perche' il fondo lo
    // dipinge gia' il gradiente qui sotto, e in un posto solo: cosi' vale
    // ovunque la si monti, e non dipende da chi la monta.
    // LA BARRA E' TRASPARENTE, ORDINE 2164 VOCE 1.
    //
    // **QUESTA RIGA DISFA UNA DECISIONE DELL'ARCHITETTO, e non e' una
    // regressione.** Con l'ordine 2163 voce 7 questa superficie era stata
    // resa OPACA, con una fascia misurata col TextPainter dietro il titolo,
    // per impedire che ESPLORA si stampasse sopra le carte. Mauro ha
    // guardato la 2163 e ha deciso il contrario: la barra deve essere
    // trasparente. E' una scelta sua che supera la mia, e sta scritta qui
    // perche' nessuno la ribalti domani credendo di correggere un difetto.
    //
    // Il difetto che la fascia risolveva NON e' stato dimenticato: il
    // titolo adesso porta la sua OMBRA MORBIDA (vedi [ombraDelTitolo]), che
    // lo tiene leggibile su qualunque cosa passi sotto senza mettergli
    // dietro un fondo pieno. La prova a pixel di ieri e' stata cambiata di
    // grandezza, non allentata: adesso misura il contrasto del titolo.
    return Material(
      type: MaterialType.transparency,
      child: Container(
      decoration: BoxDecoration(
        // Una sfumatura morbida che nasce dal basso e muore molto prima del
        // titolo: da' peso al piede della barra senza essere un fondo.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest.withValues(alpha: 0.38),
            palette.deepest.withValues(alpha: 0.88),
            palette.deepest.withValues(alpha: 0.94),
          ],
          // La sfumatura sale in fretta: il titolo vive nei primi venti punti
          // della barra, e con la salita lenta il contrasto nel Consiglio si
          // fermava a 4,23 contro il 4,5 richiesto. In cima resta comunque
          // trasparente, cioe' il contenuto entra nella barra e si vede.
          stops: const [0.0, 0.16, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        // **SEI E NON PIU\' DODICI, ordine CF voce 03.** Parole del
        // fondatore: "anche la barra ESPLORA e' molto alta". Il margine
        // esterno era lo spazio piu' grande della barra, ventiquattro punti
        // fra sopra e sotto, e non serviva a niente che si veda: sotto c'e'
        // gia' il `SafeArea`, sopra c'e' gia' l'alone del titolo.
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: 6,
          ),
          // LE VOCI VENGONO DALL'ELENCO UNICO, non da qui.
          //
          // Il nome, il disegno e l'ordine stanno in `ViaDelCerchio`. Qui
          // restano le cose che appartengono davvero alla barra, cioe' quale
          // voce e' accesa e cosa succede al tocco.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IL TITOLO, IN ORO. Sta sopra le voci, piccolo, senza icona e
              // senza tocco, e la sua riga e' alta quanto una lettera. Il
              // colore si legge da [coloreDelTitolo], un punto solo: chi lo
              // scrive a mano qui dentro fa cadere una prova.
              // L'ALONE MORBIDO DIETRO LA SCRITTA, ordine 2164 voce 1.
              //
              // **Non e' la fascia che Mauro ha tolto, e la differenza si
              // vede.** La fascia del 2163 era un rettangolo pieno alto
              // quanto il titolo e largo quanto lo schermo: un fondo. Questo
              // e' un alone radiale che sfuma a zero, senza bordi, cioe' cio'
              // che l'ordine chiama ombra morbida. Serve perche' gli aloni
              // del testo nascono dai glifi e sopra e sotto le lettere si
              // spengono: col solo testo ombreggiato il Consiglio misurava
              // 3,85 di contrasto contro il 4,5 richiesto, con le schede
              // chiare che gli passavano dietro.
              Container(
                // CINQUE E NON TRE, dall'ordine A: il titolo e' passato da
                // undici punti al pavimento di dodici, quindi il suo rettangolo
                // e' cresciuto e l'alone, restando fermo, ne copriva una quota
                // minore. Misurato nel Consiglio: 4,31 di contrasto contro il
                // 4,5 richiesto. L'alone cresce quanto e' cresciuto il testo.
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                decoration: BoxDecoration(
                  // **IL RAGGIO DELL\'ALONE DA 0,85 A 3,0. Ordine CF voce 03.**
                  //
                  // **Il difetto era vecchio e si e' visto adesso.** Il raggio
                  // di un `RadialGradient` e' una frazione del LATO PIU' CORTO
                  // del riquadro, e quel riquadro e' alto ventisette punti e
                  // largo piu' di cento: con 0,85 il fondo pieno arrivava a
                  // ventitre punti dal centro, cioe' copriva la meta' di mezzo
                  // della parola e lasciava le due ESTREMITA' di ESPLORA su
                  // un alone gia' quasi trasparente. Finche' la barra era alta
                  // 134 dietro quelle estremita' passava roba scura e non si
                  // notava; abbassandola a 112 la scritta e' scesa di sedici
                  // punti, e li' la prova del contrasto ha misurato 4,28
                  // contro il 4,5 che la legge chiede.
                  //
                  // **Il riquadro non cambia di un punto**, quindi nessuna
                  // altezza torna indietro: cambia solo quanto lontano dal
                  // centro il fondo resta pieno. Misurato dopo: 5,64,
                  // sopra il 5,48 che la stessa prova leggeva prima di
                  // questa voce.
                  gradient: RadialGradient(
                    radius: 3.0,
                    colors: [
                      palette.deepest,
                      palette.deepest.withValues(alpha: 0.97),
                      palette.deepest.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: Text(
                titolo,
                key: const Key('barra_titolo'),
                style: TypographyTokens.etichetta().copyWith(
                  color: coloreDelTitolo(palette),
                  letterSpacing: 3.2,
                  // L'OMBRA AL POSTO DELLA FASCIA, ordine 2164 voce 1: e'
                  // cio' che tiene il titolo leggibile adesso che dietro
                  // di lui passa il contenuto.
                  shadows: ombraDelTitolo(palette),
                ),
                ),
              ),
              // **LO SPAZIO CHE IL FONDATORE HA NOMINATO, e valeva due
              // punti.** Parole sue: "basterebbe anche solo ridurre lo
              // spazio tra la scritta 'esplora' e le icone sottostanti".
              // Misurato prima di toccarlo: erano DUE, piu' i cinque
              // dell\'alone sotto il testo. **Ridurre solo quello non poteva
              // bastare**, e infatti la barra scende soprattutto altrove.
              // I cinque dell\'alone non si toccano: l\'ordine A li ha portati
              // da tre a cinque per una ragione di contrasto misurata,
              // 4,31 contro il 4,5 richiesto.
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final via in ViaDelCerchio.tutte) ...[
                // Il Passport, staccato dai Maestri da un filo verticale.
                if (via.specie == SpecieDiVia.passport)
                  Container(
                    width: 1,
                    height: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: palette.gold.withValues(alpha: 0.2),
                  ),
                _BarItem(
                  // La chiave dichiara QUALE voce e': da quando la striscia
                  // delle arti vive anche in home, il nome di un Maestro a
                  // video non e' piu' uno solo, e chi deve toccare la barra
                  // la nomina per chiave, non per testo.
                  key: Key('barra_voce_${via.id}'),
                  label: via.etichetta,
                  icona: via.icona,
                  // DOVE SEI, ACCESA. Dentro il guscio lo dice la vista: nel
                  // Santuario le icone Maestro restano spente, perche' li' sono
                  // scorciatoie e non lo stato del centro. Fuori dal guscio lo
                  // dice il Maestro di cui si sta guardando il dominio o la
                  // chat, e allora la sua voce si accende.
                  selected: switch (via.specie) {
                    SpecieDiVia.cerchio => !fuoriDalGuscio &&
                        maestroCorrente == null &&
                        onSantuarioView,
                    SpecieDiVia.maestro => via.maestro == maestroCorrente,
                    SpecieDiVia.passport => !fuoriDalGuscio &&
                        maestroCorrente == null &&
                        view == ShellView.passport,
                  },
                  onTap: () => switch (via.specie) {
                    SpecieDiVia.cerchio => onSantuario(),
                    SpecieDiVia.maestro => onMaestro(via.maestro!),
                    SpecieDiVia.passport => onPassport(),
                  },
                ),
              ],
            ],
          ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Il titolo della barra, deciso da Mauro il 6 agosto 2026.
  static const String titolo = 'ESPLORA';

  /// L'altezza resa della barra intera, titolo compreso: la stessa misura
  /// che `BarraDelCerchio.altezza` dichiara e che una prova confronta con
  /// la resa vera. Vive qui perche' serve al gradiente per convertire la
  /// fascia del titolo in uno stop, senza importare la barra (che importa
  /// questo file).
  /// CENTOVENTINOVE E NON PIU' CENTOVENTITRE, ordine 2164 voce 1: l'alone
  /// morbido dietro il titolo porta tre punti di respiro sopra e tre sotto,
  /// e la barra e' cresciuta di sei. Il numero NON e' una stima: la prova
  /// `una_barra_sola_test` confronta cio' che qui si dichiara con la resa
  /// vera e cade se divergono, ed e' lei che ha denunciato i sei punti.
  /// CENTOTRENTAQUATTRO DALL'ORDINE A: il titolo e' passato da undici punti al
  /// pavimento di dodici e l'alone dietro di lui e' cresciuto da tre a cinque
  /// per lato, quindi la barra e' cresciuta di cinque. Anche stavolta il numero
  /// non e' una stima: e' la stessa prova che lo ha denunciato, misurando 5,0
  /// di scarto contro i 2,0 che tollera.
  /// **CENTODODICI DALL\'ORDINE CF VOCE 03, e la storia si ferma di
  /// crescere.** Il fondatore ha chiesto la barra piu' bassa e ha indicato
  /// lo spazio fra la scritta e le icone: misurato, quello valeva DUE
  /// punti, quindi non poteva bastare. I ventidue vengono da dove c'era
  /// margine vero: dodici dal margine esterno della barra, otto dall\'aria
  /// attorno alle cinque voci, due dallo spazio che lui ha nominato.
  /// **Nessuno viene dal bersaglio del dito**, che resta un cerchio da
  /// quarantaquattro dentro un\'area da cinquantadue, ne' dall\'alone del
  /// titolo, che l\'ordine A aveva alzato per una ragione di contrasto
  /// misurata.
  static const double altezzaResa = 112;

  /// IL COLORE DEL TITOLO: L'ORO DELLA PALETTE. Deciso da Mauro il 7 agosto
  /// 2026, e SUPERA la decisione del mattino del 6 agosto che lo voleva nel
  /// grigio del testo smorzato. Quella decisione nasceva da una misura vera,
  /// cinque voci dorate piu' un titolo dorato facevano una fascia illeggibile,
  /// ma Mauro l'ha cambiata: chi legge la vecchia decisione NON lo rimetta
  /// grigio. Il colore vive QUI e in nessun altro posto: una prova legge
  /// questo punto e cade se qualcuno lo scrive a mano altrove.
  static Color coloreDelTitolo(MaestroPalette palette) => palette.gold;

  /// L'OMBRA DEL TITOLO, ordine 2164 voce 1, punto unico.
  ///
  /// Sostituisce la fascia piena dietro ESPLORA: due aloni del fondale, uno
  /// stretto e quasi pieno che stacca le lettere e uno largo e piu' tenue
  /// che spegne il contrasto locale di cio' che passa sotto. Il colore e'
  /// il fondale del Maestro, non un nero fisso, cosi' l'ombra appartiene
  /// alla casa in cui si e'.
  /// I TRE ALONI SONO MISURATI, non scelti a occhio: con due soli aloni
  /// (0,95 a raggio 4 e 0,85 a raggio 10) nel Consiglio il contrasto
  /// scendeva a 3,32 contro il 4,5 richiesto, perche' li' dietro il titolo
  /// passano le schede chiare. Il terzo alone largo spegne proprio quel
  /// fondo. Chi li tocca rilegga il numero che la prova stampa.
  static List<Shadow> ombraDelTitolo(MaestroPalette palette) => [
        Shadow(color: palette.deepest, blurRadius: 3),
        Shadow(color: palette.deepest, blurRadius: 8),
        Shadow(color: palette.deepest, blurRadius: 14),
        Shadow(color: palette.deepest, blurRadius: 20),
        Shadow(
            color: palette.deepest.withValues(alpha: 0.98), blurRadius: 28),
      ];
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icona,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Il disegno dell'icona, colore e lato decisi qui dentro perche' lo stato
  /// attivo e la dimensione ottica sono della barra, non della singola voce.
  /// Prima era un `IconData`, e un `IconData` non puo' essere una falce dentro
  /// un anello: la voce del Cerchio non esiste fra le icone di Material.
  final Widget Function(Color colore, double lato) icona;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color color = selected ? palette.goldSoft : ColorTokens.textMuted;

    // LO SPAZIO SEGUE IL NOME, e non e' un dettaglio di layout: e' la ragione
    // per cui una voce si vedeva monca.
    //
    // Con `Expanded` ogni voce prendeva un quinto della barra, cioe' 62,4 punti
    // su un telefono da 360, uguali per tutte. Ma i nomi non sono uguali: a
    // dodici punti "Il Cerchio" ne chiede 70,4 e "Aura" 33,4, quindi la prima
    // usciva troncata in "Il" mentre l'ultima nuotava nel vuoto. Alzare il
    // numero non era una via, e rimpicciolire il carattere nemmeno: il problema
    // era lo spazio, e si risolve qui.
    //
    // Adesso ogni voce e' larga quanto le serve e il resto si distribuisce fra
    // loro. La somma dei cinque nomi misura 264,3 punti contro i 312 che la
    // barra ha, quindi ci stanno tutti con quarantotto punti di margine.
    // LO SPAZIO SI DIVIDE IN PROPORZIONE AL NOME, e il peso e' la larghezza
    // vera del testo.
    //
    // Le voci naturali, senza nessun vincolo, stavano bene a scala uno e
    // uscivano dalla barra di 27 pixel quando il corpo del testo di sistema
    // sale a 1,3, che e' il tetto che l'app concede: misurato dalla prova del
    // textScaler. `Expanded` e `Flexible` a peso uguale hanno il difetto
    // opposto, perche' danno un quinto a testa e "Il Cerchio" ne chiede di
    // piu' di "Aura", tanto che usciva troncato in "Il".
    //
    // Col peso proporzionale valgono tutti e due i casi: a scala normale
    // ciascuna voce riceve piu' o meno quello che le serve, e quando la scala
    // cresce si stringono tutte insieme invece che una sola.
    final peso = _larghezzaDel(label, selected);
    return Flexible(
      flex: peso,
      fit: FlexFit.loose,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        // **QUATTRO E NON PIU\' OTTO, ordine CF voce 03.** Il cerchio resta
        // quarantaquattro, che e' il bersaglio del dito e non si tocca: qui
        // scende solo l\'aria attorno, e il bersaglio resta cinquantadue
        // punti di altezza, sopra il minimo di quarantotto.
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? palette.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? palette.gold.withValues(alpha: 0.8)
                        : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: palette.glow.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: icona(color, 21),
              ),
              const SizedBox(height: 4),
              // ORDINE B: il nome della via era un TextStyle costruito a mano a
              // 10,5 punti, cioe' sotto il pavimento dell'app, e i token non lo
              // vedevano nemmeno per dirlo. Adesso e' il ruolo `etichetta`,
              // dodici punti, e la barra sta sotto OGNI schermata: era il posto
              // dove un testo troppo piccolo si vedeva piu' spesso di ogni
              // altro.
              //
              // La spaziatura fra le lettere scende da 1,6 a 0,2, e non e' un
              // modo per rimpicciolire di nascosto: la misura resta dodici. Il
              // valore alto del ruolo serve al maiuscoletto cerimoniale, che
              // qui non c'e', e in una casella larga un quinto di schermo
              // ruberebbe piu' spazio delle lettere stesse.
              Text(
                label,
                maxLines: 1,
                // L'ellissi esiste solo per il caso estremo del corpo di
                // sistema al massimo: a scala normale nessuna voce ci arriva.
                overflow: TextOverflow.ellipsis,
                style: _stileDellaVoce(color, selected),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Lo stile del nome della via, in un punto solo: lo usano il disegno e la
  /// misura del peso, e se vivesse in due copie il peso non descriverebbe piu'
  /// il testo che si vede.
  ///
  /// La spaziatura fra le lettere scende da 1,6 a 0,2, e non e' un modo per
  /// rimpicciolire di nascosto: la misura resta dodici, cioe' il pavimento. Il
  /// valore alto del ruolo serve al maiuscoletto cerimoniale, che qui non c'e',
  /// e in una casella stretta ruberebbe piu' spazio delle lettere stesse.
  static TextStyle _stileDellaVoce(Color color, bool selected) =>
      TypographyTokens.etichetta(weight: selected ? 700 : 500)
          .copyWith(color: color, letterSpacing: 0.2);

  /// La larghezza vera del nome, arrotondata: e' il peso con cui la voce
  /// concorre allo spazio della barra.
  static int _larghezzaDel(String label, bool selected) {
    final tp = TextPainter(
      text: TextSpan(
          text: label, style: _stileDellaVoce(const Color(0xFFFFFFFF), selected)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    // Mai zero: un peso nullo toglierebbe alla voce ogni spazio.
    return tp.width.ceil().clamp(1, 1000);
  }
}
