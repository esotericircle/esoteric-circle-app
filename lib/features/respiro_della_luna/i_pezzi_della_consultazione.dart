import 'package:flutter/material.dart';

import '../../core/lunario/la_consultazione_della_luna.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'i_comandi_dipinti.dart';

/// **I PEZZI DELLA LUNA DI QUEST'ORA.** Ordine FX aggiunta FXA.09, 16
/// ottobre 2026: la schermata principale del Respiro della Luna diventa uno
/// strumento di consultazione, dall'alto in basso la citta', la fase, la
/// Luna vera, il righello del tempo, i dati e la barra in basso. La base e'
/// la cattura di Dora, da cui si prendono struttura e dati, mai l'aspetto:
/// ogni pezzo qui e' un'immagine dipinta di `infografica/` e `icone/`, il
/// testo e' testo Flutter posato sopra.
abstract final class IPezziDipinti {
  static const String _infografica =
      'assets/img/respiro_della_luna/infografica';
  static const String _icone = 'assets/img/respiro_della_luna/icone';

  static const String righello = '$_infografica/righello_delle_fasi_v1.webp';
  static const String cursore = '$_infografica/cursore_falce_v1.webp';
  static const String medaglioneSorge =
      '$_infografica/medaglione_sorge_v1.webp';
  static const String medaglioneCulmina =
      '$_infografica/medaglione_culmina_v1.webp';
  static const String medaglioneTramonta =
      '$_infografica/medaglione_tramonta_v1.webp';
  static const String sigilloSuperluna =
      '$_infografica/sigillo_superluna_v1.webp';
  static const String sigilloMicroluna =
      '$_infografica/sigillo_microluna_v1.webp';

  static const String frecciaSinistra = '$_icone/freccia_sinistra_v1.webp';
  static const String frecciaDestra = '$_icone/freccia_destra_v1.webp';
  static const String penna = '$_icone/penna_modifica_v1.webp';
  static const String segnaposto = '$_icone/segnaposto_luna_v1.webp';
  static const String iconaLuna = '$_icone/icona_luna_v1.webp';
  static const String iconaCalendario = '$_icone/icona_calendario_v1.webp';
  static const String iconaBussola = '$_icone/icona_bussola_v1.webp';
  static const String iconaRespiro = '$_icone/icona_respiro_v1.webp';

  /// Il sigillo della Luna fuori corso, quello del Calendario Lunare.
  static const String fuoriCorso =
      'assets/img/calendario_lunare/sig_luna_fuori_corso_v1.webp';

  /// Le misure dei pezzi in pixel, per tenerne le proporzioni.
  static const Size misuraDelRighello = Size(1784, 161);
  static const Size misuraDelCursore = Size(95, 268);
  static const Size misuraDellaFreccia = Size(478, 135);
}

const Size _misuraDelPulsante = Size(1133, PulsanteDipinto.altezzaDellImmagine);

Widget _immagine(String asset, {double? width, double? height, Key? key}) =>
    Image.asset(asset,
        key: key,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(width: width, height: height));

/// Un'ombra dipinta sotto il testo che sta sulla scena o sulla foto della
/// Luna, perche' si legga su un cielo chiaro come su uno scuro.
const List<Shadow> ombraSullaScena = [
  Shadow(color: Color(0xCC000000), blurRadius: 6),
  Shadow(color: Color(0x99000000), blurRadius: 2, offset: Offset(0, 1)),
];

/// **1. LA CITTA'.** Il nome della citta' vera dal GPS (FXA.06) col
/// segnaposto; la penna apre la scelta di un'altra citta'.
class RigaDellaCitta extends StatelessWidget {
  const RigaDellaCitta({
    super.key,
    required this.citta,
    required this.palette,
    required this.onCambia,
  });

  /// Nulla quando non c'e' nessun luogo: la riga lo dice.
  final String? citta;
  final MaestroPalette palette;
  final VoidCallback onCambia;

  static const double altezza = 30;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altezza,
      child: Semantics(
        button: true,
        label: 'Cambia città',
        child: GestureDetector(
          key: const Key('luna_cambia_citta'),
          behavior: HitTestBehavior.opaque,
          onTap: onCambia,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _immagine(IPezziDipinti.segnaposto, height: 22),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(citta ?? 'Scegli dove guardi la Luna',
                      key: const Key('luna_nome_della_citta'),
                      maxLines: 1,
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: coloreSulVelluto)),
                ),
              ),
              const SizedBox(width: 6),
              _immagine(IPezziDipinti.penna, height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// **2. LA FASE.** Il nome in grande, fra le due frecce dipinte che portano
/// il tempo all'inizio della fase precedente e della successiva.
class RigaDellaFase extends StatelessWidget {
  const RigaDellaFase({
    super.key,
    required this.nome,
    required this.palette,
    required this.onPrecedente,
    required this.onSuccessiva,
  });

  final String nome;
  final MaestroPalette palette;
  final VoidCallback onPrecedente;
  final VoidCallback onSuccessiva;

  static const double altezza = 44;

  Widget _freccia(
          String asset, String chiave, String etichetta, VoidCallback onTap) =>
      Semantics(
        button: true,
        label: etichetta,
        child: GestureDetector(
          key: Key(chiave),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 64,
            height: altezza,
            child: Center(child: _immagine(asset, width: 56)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altezza,
      child: Row(
        children: [
          _freccia(IPezziDipinti.frecciaSinistra, 'luna_fase_precedente',
              'Alla fase precedente', onPrecedente),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(nome,
                  key: const Key('luna_nome_della_fase'),
                  maxLines: 1,
                  style: TypographyTokens.titoloSezione()
                      .copyWith(color: Colors.white, shadows: ombraSullaScena)),
            ),
          ),
          _freccia(IPezziDipinti.frecciaDestra, 'luna_fase_successiva',
              'Alla fase successiva', onSuccessiva),
        ],
      ),
    );
  }
}

/// **3. SULLA LUNA VERA**, in testo: il giorno e la data, la percentuale di
/// luce in grande, l'ora del momento guardato. Sta dentro il disco della
/// Luna, che decide la misura: un `FittedBox` lo tiene sempre dentro.
class IlTestoSullaLuna extends StatelessWidget {
  const IlTestoSullaLuna({
    super.key,
    required this.istante,
    required this.percentuale,
  });

  final DateTime istante;
  final double percentuale;

  static const List<String> _giorni = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

  @override
  Widget build(BuildContext context) {
    final l = istante.toLocal();
    final data = '${l.day.toString().padLeft(2, '0')}/'
        '${l.month.toString().padLeft(2, '0')}/'
        '${(l.year % 100).toString().padLeft(2, '0')}';
    TextStyle sulla(TextStyle s) =>
        s.copyWith(color: Colors.white, shadows: ombraSullaScena);
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          key: const Key('luna_testo_sulla_luna'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_giorni[l.weekday - 1],
                style: sulla(TypographyTokens.etichetta())),
            Text(data, style: sulla(TypographyTokens.titoloScheda())),
            Text('${(percentuale * 100).round()}%',
                key: const Key('luna_percentuale'),
                style: sulla(TypographyTokens.cerimonialeGrande())),
            Text(IlTempoDetto.ora(l),
                key: const Key('luna_ora_guardata'),
                style: sulla(TypographyTokens.titoloScheda())),
          ],
        ),
      ),
    );
  }
}

/// **4. IL RIGHELLO DEL TEMPO.** Il righello dipinto sta fermo a tutta
/// larghezza col cursore a falce al centro: il dito trascina il tempo, e
/// sotto scorrono le date e i giorni in testo ("sotto scorrono le date e i
/// giorni in testo", FXA.09). Le sette fasi incise sono decorazione: il
/// cursore scorre sul tempo vero, non su di loro. **Un pezzo solo, non
/// tasselli**: ripetuto, il righello mostrava le sue estremita' a ogni
/// giunta, visto nella prima anteprima.
class IlRighelloDelTempo extends StatelessWidget {
  const IlRighelloDelTempo({
    super.key,
    required this.tempoVisto,
    required this.onTrascina,
  });

  final DateTime tempoVisto;
  final ValueChanged<double> onTrascina;

  /// Quanti punti dello schermo vale un giorno: un giorno intero si vede
  /// sulla larghezza di un telefono stretto, e mezzanotte di ieri e di
  /// domani restano a portata di dito.
  static const double puntiPerGiorno = 240;

  static const double altezzaDelRighello = 30;
  static const double altezza = 100;

  /// Le due estremita' del righello, che non si allungano.
  static const Rect _taglio = Rect.fromLTRB(40, 20, 1744, 141);

  static const List<String> _mesi = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];
  static const List<String> _giorni = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final larghezza = box.maxWidth;
      final centro = larghezza / 2;
      final mezzanotte =
          DateTime(tempoVisto.year, tempoVisto.month, tempoVisto.day);
      final etichette = <Widget>[];
      for (var g = -2; g <= 2; g++) {
        final giorno =
            DateTime(mezzanotte.year, mezzanotte.month, mezzanotte.day + g);
        final x = centro +
            giorno.difference(tempoVisto).inMinutes /
                (24 * 60) *
                puntiPerGiorno;
        if (x < -120 || x > larghezza + 120) continue;
        etichette.add(Positioned(
          left: x - 60,
          width: 120,
          top: 22 + altezzaDelRighello + 6,
          // Col testo ingrandito la data non sta in 120 punti: si
          // rimpicciolisce invece di uscire (preso dalla prova dei puntini).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text('${giorno.day} ${_mesi[giorno.month - 1]} ${giorno.year}',
                    style: TypographyTokens.etichetta().copyWith(
                        color: Colors.white, shadows: ombraSullaScena)),
                Text(_giorni[giorno.weekday - 1],
                    style: TypographyTokens.etichetta().copyWith(
                        color: coloreSulVelluto, shadows: ombraSullaScena)),
              ],
            ),
          ),
        ));
      }
      return Semantics(
        label: 'Righello del tempo: trascina per spostare l\'ora',
        child: GestureDetector(
          key: const Key('luna_righello_del_tempo'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => onTrascina(d.delta.dx),
          child: SizedBox(
            height: altezza,
            width: larghezza,
            child: ClipRect(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: SpacingTokens.sm,
                    right: SpacingTokens.sm,
                    top: 22,
                    height: altezzaDelRighello,
                    child: ImmagineANoveParti(
                      asset: IPezziDipinti.righello,
                      misura: IPezziDipinti.misuraDelRighello,
                      taglio: _taglio,
                      scala: IPezziDipinti.misuraDelRighello.height /
                          altezzaDelRighello,
                    ),
                  ),
                  ...etichette,
                  Positioned(
                    left: centro - 9,
                    top: 0,
                    width: 18,
                    height: 18 *
                        IPezziDipinti.misuraDelCursore.height /
                        IPezziDipinti.misuraDelCursore.width,
                    child: _immagine(IPezziDipinti.cursore,
                        key: const Key('luna_cursore')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Una riga dei dati: il pezzo dipinto a sinistra (se c'e'), l'etichetta e
/// il valore. Il testo va a capo, mai i puntini (FXA.04).
class RigaDelDato extends StatelessWidget {
  const RigaDelDato({
    super.key,
    this.pezzo,
    this.pezzoDopo,
    required this.etichetta,
    required this.valore,
    required this.palette,
  });

  final String? pezzo;

  /// Un sigillo dopo il valore (Superluna, Microluna).
  final String? pezzoDopo;
  final String etichetta;
  final String valore;
  final MaestroPalette palette;

  /// L'altezza minima della striscia: la scala del pezzo dipinto la decide
  /// lei, cosi' gli angoli restano della stessa misura su ogni riga.
  static const double altezzaMinima = 48;

  @override
  Widget build(BuildContext context) {
    const scala = PulsanteDipinto.altezzaDellImmagine / altezzaMinima;
    final angolo = PulsanteDipinto.taglio.left / scala;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xxs),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: altezzaMinima),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ImmagineANoveParti(
                asset: PulsanteDipinto.immagine,
                misura: _misuraDelPulsante,
                taglio: PulsanteDipinto.taglio,
                scala: scala,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: angolo * 0.55, vertical: SpacingTokens.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (pezzo != null) ...[
                    _immagine(pezzo!, width: 30, height: 30),
                    const SizedBox(width: SpacingTokens.sm),
                  ],
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: '$etichetta  ',
                            style: TypographyTokens.etichetta()
                                .copyWith(color: palette.goldSoft)),
                        TextSpan(
                            text: valore,
                            style: TypographyTokens.etichetta()
                                .copyWith(color: coloreSulVelluto)),
                      ]),
                    ),
                  ),
                  if (pezzoDopo != null) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    _immagine(pezzoDopo!, width: 30, height: 30),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **5. I DATI**, ognuno su una riga del pannello dipinto, coi numeri esatti
/// come nella cattura di Dora.
class IDatiDellaLuna extends StatelessWidget {
  const IDatiDellaLuna({
    super.key,
    required this.consultazione,
    required this.palette,
  });

  final LaConsultazioneDellaLuna consultazione;
  final MaestroPalette palette;

  String _evento(EventoDelGiorno e) =>
      '${IlTempoDetto.ora(e.istante)}${e.domani ? ' (+1)' : ''} '
      '(${IlTempoDetto.rispetto(e.istante, consultazione.istante)})';

  String _rigaDelSegno() {
    final c = consultazione;
    final cambio = c.prossimoCambioDiSegno;
    final segno = c.segno.italianName;
    if (cambio == null) return 'in $segno';
    final l = cambio.istante.toLocal();
    final g = c.istante.toLocal();
    final oggi = l.year == g.year && l.month == g.month && l.day == g.day;
    final quando = oggi
        ? 'fino alle ${IlTempoDetto.ora(l)}'
        : 'fino al ${l.day}/${l.month} alle ${IlTempoDetto.ora(l)}';
    return 'in $segno $quando, poi in ${cambio.segno.italianName}';
  }

  @override
  Widget build(BuildContext context) {
    final c = consultazione;
    final vicinanza = c.vicinanza;
    return Column(
      key: const Key('luna_i_dati'),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (c.sorge != null)
          RigaDelDato(
              key: const Key('luna_dato_sorge'),
              pezzo: IPezziDipinti.medaglioneSorge,
              etichetta: 'Sorge',
              valore: _evento(c.sorge!),
              palette: palette),
        if (c.culmina != null)
          RigaDelDato(
              key: const Key('luna_dato_culmina'),
              pezzo: IPezziDipinti.medaglioneCulmina,
              etichetta: 'Culmina',
              valore: _evento(c.culmina!),
              palette: palette),
        if (c.tramonta != null)
          RigaDelDato(
              key: const Key('luna_dato_tramonta'),
              pezzo: IPezziDipinti.medaglioneTramonta,
              etichetta: 'Tramonta',
              valore: _evento(c.tramonta!),
              palette: palette),
        RigaDelDato(
            key: const Key('luna_dato_piena'),
            etichetta: 'Prossima Luna piena',
            valore:
                IlTempoDetto.durata(c.dati.prossimaPiena.difference(c.istante)),
            palette: palette),
        RigaDelDato(
            key: const Key('luna_dato_nuova'),
            etichetta: 'Prossima Luna nuova',
            valore:
                IlTempoDetto.durata(c.dati.prossimaNuova.difference(c.istante)),
            palette: palette),
        RigaDelDato(
            key: const Key('luna_dato_eta'),
            etichetta: 'Età della Luna',
            valore: IlTempoDetto.durata(c.eta),
            palette: palette),
        RigaDelDato(
            key: const Key('luna_dato_distanza'),
            etichetta: 'Distanza',
            valore: IlTempoDetto.chilometri(c.dati.distanzaKm) +
                (vicinanza == VicinanzaDellaLuna.superluna
                    ? ', vicina: Superluna'
                    : vicinanza == VicinanzaDellaLuna.microluna
                        ? ', lontana: Microluna'
                        : ''),
            pezzoDopo: vicinanza == VicinanzaDellaLuna.superluna
                ? IPezziDipinti.sigilloSuperluna
                : vicinanza == VicinanzaDellaLuna.microluna
                    ? IPezziDipinti.sigilloMicroluna
                    : null,
            palette: palette),
        RigaDelDato(
            key: const Key('luna_dato_segno'),
            pezzo: ZodiacArt.emblemPath(c.segno),
            etichetta: 'Luna',
            valore: _rigaDelSegno(),
            palette: palette),
        if (c.fineDelFuoriCorso != null)
          RigaDelDato(
              key: const Key('luna_dato_fuori_corso'),
              pezzo: IPezziDipinti.fuoriCorso,
              etichetta: 'Fuori corso',
              valore: 'fino alle ${IlTempoDetto.ora(c.fineDelFuoriCorso!)}',
              palette: palette),
      ],
    );
  }
}

/// **LA PORTA AL CALENDARIO LUNARE**, in fondo ai dati della Luna: una
/// riga sulla striscia dipinta con l'icona del calendario. Il Calendario e'
/// la funzione dedicata a cercare i giorni del mese (ordine FV); qui c'e'
/// solo la strada per arrivarci.
class RigaDelCalendario extends StatelessWidget {
  const RigaDelCalendario({
    super.key,
    required this.palette,
    required this.onTap,
  });

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Trova il giorno giusto nel mese, nel Calendario Lunare',
      child: GestureDetector(
        key: const Key('respiro_vai_al_calendario'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: RigaDelDato(
          pezzo: IPezziDipinti.iconaCalendario,
          etichetta: 'Trova il giorno giusto nel mese',
          valore: 'nel Calendario Lunare',
          palette: palette,
        ),
      ),
    );
  }
}

/// Le tre voci della barra in basso (FXA.09, punto 6). **Il Calendario non
/// c'e' piu'**: correzione del fondatore del 16 ottobre 2026, "mi chiedevo
/// se l'opzione menù calendario non diventasse un doppione, visto che
/// abbiamo già la funzionalità dedicata". La porta al Calendario Lunare e'
/// una riga dipinta in fondo ai dati ([RigaDelCalendario]).
enum VoceDellaLuna { luna, bussola, respiro }

/// **6. LA BARRA IN BASSO**, dipinta, con tre voci: Luna, Bussola,
/// Respiro. La voce dove si sta e' sul pezzo premuto, che ha
/// l'interno argento e il testo scuro.
class LaBarraDellaLuna extends StatelessWidget {
  const LaBarraDellaLuna({
    super.key,
    required this.voce,
    required this.onVoce,
    this.bussolaChiusa = false,
  });

  final VoceDellaLuna voce;
  final ValueChanged<VoceDellaLuna> onVoce;

  /// La Bussola e' esclusiva di Adepto e Illuminato (FX.10): chi non ce
  /// l'ha la vede col lucchetto scritto, mai nascosta.
  final bool bussolaChiusa;

  static const double altezza = 80;

  /// **LA CORNICE FINE.** Alla scala della sua altezza la cornice del pezzo
  /// dipinto era spessa 23 punti sopra e sotto, e lasciava 22 punti a icona
  /// e nome: le icone salivano sul bordo (il fondatore, sull'anteprima: "Le
  /// icone di luna e respiro si sovrappongono leggermente al bordo
  /// superiore"). La cornice si disegna come per un pezzo alto 48 punti,
  /// spessa 16, e dentro restano 48 punti di velluto.
  static const double _scalaDellaCornice =
      PulsanteDipinto.altezzaDellImmagine / 48;

  /// Il pezzo argento della voce scelta, con la cornice ancora piu' fine,
  /// perche' icona e nome stiano dentro il suo interno.
  static const double _scalaDelPremuto =
      PulsanteDipinto.altezzaDellImmagine / 36;

  static const Map<VoceDellaLuna, (String, String)> _voci = {
    VoceDellaLuna.luna: ('Luna', IPezziDipinti.iconaLuna),
    VoceDellaLuna.bussola: ('Bussola', IPezziDipinti.iconaBussola),
    VoceDellaLuna.respiro: ('Respiro', IPezziDipinti.iconaRespiro),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('luna_barra_in_basso'),
      height: altezza,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ImmagineANoveParti(
              asset: PulsanteDipinto.immagine,
              misura: _misuraDelPulsante,
              taglio: PulsanteDipinto.taglio,
              scala: _scalaDellaCornice,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            child: Row(
              children: [
                for (final v in VoceDellaLuna.values)
                  Expanded(child: _laVoce(v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _laVoce(VoceDellaLuna v) {
    final (testo, icona) = _voci[v]!;
    final qui = v == voce;
    final chiusa = v == VoceDellaLuna.bussola && bussolaChiusa;
    return Semantics(
      button: true,
      selected: qui,
      label: chiusa ? '$testo, esclusiva Adepto e Illuminato' : testo,
      child: GestureDetector(
        key: Key('luna_voce_${v.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onVoce(v),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (qui)
              const Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: ImmagineANoveParti(
                    asset: PulsanteDipinto.immaginePremuta,
                    misura: _misuraDelPulsante,
                    taglio: PulsanteDipinto.taglioPremuto,
                    scala: _scalaDelPremuto,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: chiusa ? 0.55 : 1,
                  child: _immagine(icona, height: 22),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(testo,
                      maxLines: 1,
                      style: TypographyTokens.etichetta().copyWith(
                          color: qui ? coloreSullArgento : coloreSulVelluto)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
