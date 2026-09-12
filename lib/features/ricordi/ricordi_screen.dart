/// I RICORDI DEL CERCHIO. Ordine CG voci 01, 02, 04, 05 e 07.
///
/// **Il nome viene dal fondatore**, 31 agosto 2026: "in effetti chiamerei la
/// funzione Ricordi del Cerchio o libro dei ricordi".
///
/// **Due viste dentro la stessa schermata, e non due schermate.** IL CAMMINO
/// e' la mappa dei tre sentieri come sta oggi, senza modifiche; I RICORDI sono
/// la lettura nel tempo. Le due viste leggono la STESSA fonte: dalla mappa,
/// toccando un traguardo acceso, si arriva al giorno in cui e' successo; dal
/// giorno, toccando il traguardo, si torna sulla mappa. Non nasce nessun
/// secondo conteggio di niente.
///
/// **Una rotta sola, e tre porte che ci arrivano.** Il menu' utente sotto il
/// nome, un rimando dal Passaporto accanto ai traguardi, una riga in cima a
/// ogni chat. Una prova enumera i punti di `lib/` che aprono i Ricordi e
/// pretende che portino tutti qui: due schermate che mostrano le stesse cose
/// sono la famiglia di difetti piu' numerosa di questo progetto.
///
/// **Il livello visivo prima del testo**, che e' la regola di casa: l'anno e'
/// dodici caselle col loro peso e il loro colore, e non un elenco di numeri.
/// Nessun testo da leggere per capire dove hai camminato.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/tier.dart';
import '../../core/ricordi/lettura_del_mese.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/ricordi/arti_con_responso.dart';
import '../../core/ricordi/artwork_del_ricordo.dart';
import '../../design_system/components/miniatura_intera.dart';
import '../tarot/tarot_card_art.dart';
import '../../core/ricordi/conti_delle_arti.dart';
import '../../core/ricordi/registro_dei_ricordi.dart';
import '../../core/ricordi/riassunti_del_tempo.dart';
import '../../core/ricordi/ricordo_custodito.dart';
import '../../core/ricordi/scrigno_dei_custoditi.dart';
import '../../core/ricordi/vista_dei_ricordi.dart';
import '../../core/ricordi/voce_del_ricordo.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../sigilli/segno_del_sentiero.dart';
import '../sigilli/sentiero_screen.dart';

/// Quale delle due viste e' davanti.
enum VistaDelJournal { cammino, ricordi }

class RicordiScreen extends StatefulWidget {
  const RicordiScreen({
    super.key,
    this.vistaIniziale = VistaDelJournal.ricordi,
    this.maestroIniziale,
    this.orologio,
  });

  /// Con quale vista si apre. Dal Passaporto si arriva sul Cammino, dal menu'
  /// utente e dalla chat sui Ricordi: la porta dice cosa si stava cercando.
  final VistaDelJournal vistaIniziale;

  /// Il Maestro su cui filtrare all'apertura, quando si arriva dalla sua chat.
  final Maestro? maestroIniziale;

  final DateTime Function()? orologio;

  /// **LA ROTTA E' UNA SOLA**, ed e' il punto che la guardia enumera.
  static Route<void> route({
    VistaDelJournal vista = VistaDelJournal.ricordi,
    Maestro? maestro,
  }) =>
      PassaggioDelCerchio.rotta<void>(
        (_) => MaestroScope(
          child: RicordiScreen(
            vistaIniziale: vista,
            maestroIniziale: maestro,
          ),
        ),
      );

  @override
  State<RicordiScreen> createState() => _RicordiScreenState();
}

class _RicordiScreenState extends State<RicordiScreen> {
  VistaDelJournal _vista = VistaDelJournal.cammino;
  VistaDeiRicordi? _timeline;
  final TextEditingController _ricerca = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vista = widget.vistaIniziale;
  }

  @override
  void dispose() {
    _ricerca.dispose();
    _timeline?.dispose();
    super.dispose();
  }

  VistaDeiRicordi _laTimeline(BuildContext context) {
    final gia = _timeline;
    if (gia != null) return gia;
    final nuova = VistaDeiRicordi(
      registro: context.read<RegistroDeiRicordi>(),
      gestiDeiDoni: ContiDelleArti.gestiDeiDoni.values.toSet(),
      orologio: widget.orologio ?? DateTime.now,
    );
    final maestro = widget.maestroIniziale;
    if (maestro != null) {
      // Si arriva dalla chat di un Maestro: le sue voci per prime, che e'
      // quello che la riga "i giorni prima" promette.
      nuova.alterna(switch (maestro) {
        Maestro.medora => FiltroDeiRicordi.medora,
        Maestro.aura => FiltroDeiRicordi.aura,
        Maestro.caligo => FiltroDeiRicordi.caligo,
      });
    }
    _timeline = nuova;
    return nuova;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        title: Text('Cosmic Journal',
            key: const Key('ricordi_titolo'),
            style: TypographyTokens.titoloScheda()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _LevettaDelleViste(
              vista: _vista,
              onCambia: (v) => setState(() => _vista = v),
              palette: palette,
            ),
            Expanded(
              child: _vista == VistaDelJournal.cammino
                  ? const _IlCammino(key: Key('ricordi_vista_cammino'))
                  : _IRicordi(
                      key: const Key('ricordi_vista_ricordi'),
                      vista: _laTimeline(context),
                      ricerca: _ricerca,
                      palette: palette,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La levetta in cima, con le due viste.
class _LevettaDelleViste extends StatelessWidget {
  const _LevettaDelleViste({
    required this.vista,
    required this.onCambia,
    required this.palette,
  });

  final VistaDelJournal vista;
  final ValueChanged<VistaDelJournal> onCambia;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: SegmentedButton<VistaDelJournal>(
        key: const Key('ricordi_levetta'),
        segments: const [
          ButtonSegment(
            value: VistaDelJournal.cammino,
            label: Text('Il Cammino'),
            icon: Icon(Icons.route_rounded),
          ),
          ButtonSegment(
            value: VistaDelJournal.ricordi,
            label: Text('I Ricordi'),
            icon: Icon(Icons.auto_stories_rounded),
          ),
        ],
        selected: {vista},
        onSelectionChanged: (s) => onCambia(s.first),
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: palette.primary,
          selectedForegroundColor: palette.onPrimary,
          foregroundColor: palette.goldSoft,
        ),
      ),
    );
  }
}

/// LA VISTA DEL CAMMINO: la mappa dei tre sentieri, come sta oggi.
///
/// **Senza modifiche, come l'ordine chiede.** Le tre righe portano alle stesse
/// schermate dei sentieri che il Passaporto gia' apre: non nasce una seconda
/// mappa, si mostra quella che c'e' da un secondo posto.
class _IlCammino extends StatelessWidget {
  const _IlCammino({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      children: [
        for (final sentiero in Sentieri.tutti)
          ListTile(
            key: Key('ricordi_sentiero_${sentiero.name}'),
            leading: SegnoDelSentiero(
              sentiero: sentiero,
              colore: ColorTokens.goldLight,
              misura: 24,
            ),
            title:
                Text(sentiero.titolo, style: TypographyTokens.titoloScheda()),
            subtitle: Text(sentiero.promessa,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary)),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: ColorTokens.goldLight),
            onTap: () =>
                Navigator.of(context).push(SentieroScreen.route(sentiero)),
          ),
        const SizedBox(height: SpacingTokens.xxxl),
      ],
    );
  }
}

/// LA VISTA DEI RICORDI: la ricerca, le pastiglie e i quattro livelli.
class _IRicordi extends StatelessWidget {
  const _IRicordi({
    super.key,
    required this.vista,
    required this.ricerca,
    required this.palette,
  });

  final VistaDeiRicordi vista;
  final TextEditingController ricerca;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vista,
      builder: (context, _) {
        return Column(
          children: [
            _CampoDellaRicerca(
                vista: vista, controllore: ricerca, palette: palette),
            _LePastiglie(vista: vista, palette: palette),
            Expanded(
              // **LE TUE CARTE SONO UNA PASTIGLIA, non una schermata,
              // ordine CG voce 07.** Due magazzini che contengono le stesse
              // cose sono la famiglia di difetti piu' numerosa di questo
              // progetto: qui e' la stessa fonte, guardata a griglia perche'
              // i custoditi sono oggetti visivi e non righe di testo.
              child: vista.cercato.isNotEmpty
                  ? _IRisultati(vista: vista, palette: palette)
                  : (vista.filtri.contains(FiltroDeiRicordi.custoditi)
                      ? _LeTueCarte(vista: vista, palette: palette)
                      : _ILivelli(vista: vista, palette: palette)),
            ),
          ],
        );
      },
    );
  }
}

class _CampoDellaRicerca extends StatelessWidget {
  const _CampoDellaRicerca({
    required this.vista,
    required this.controllore,
    required this.palette,
  });

  final VistaDeiRicordi vista;
  final TextEditingController controllore;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: TextField(
        key: const Key('ricordi_ricerca'),
        controller: controllore,
        onChanged: vista.cerca,
        style: TypographyTokens.corpo(),
        decoration: InputDecoration(
          hintText: 'Cerca fra le tue domande',
          prefixIcon: Icon(Icons.search_rounded, color: palette.goldSoft),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// LE PASTIGLIE: sono FILTRI che si sommano, non sezioni che aprono schermate.
class _LePastiglie extends StatelessWidget {
  const _LePastiglie({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  static const Map<FiltroDeiRicordi, String> _nomi = {
    FiltroDeiRicordi.medora: 'Medora',
    FiltroDeiRicordi.aura: 'Aura',
    FiltroDeiRicordi.caligo: 'Caligo',
    FiltroDeiRicordi.arti: 'Le arti',
    FiltroDeiRicordi.conversazioni: 'Conversazioni',
    FiltroDeiRicordi.custoditi: 'Le tue card',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          for (final voce in _nomi.entries) ...[
            FilterChip(
              key: Key('ricordi_pastiglia_${voce.key.name}'),
              label: Text(voce.value),
              selected: vista.filtri.contains(voce.key),
              onSelected: (_) => vista.alterna(voce.key),
              selectedColor: palette.primary,
            ),
            const SizedBox(width: SpacingTokens.sm),
          ],
        ],
      ),
    );
  }
}

/// I QUATTRO LIVELLI: anno, mese, settimana, giorno. Si scende toccando.
class _ILivelli extends StatelessWidget {
  const _ILivelli({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return switch (vista.livello) {
      LivelloDeiRicordi.anno => _LAnno(vista: vista, palette: palette),
      LivelloDeiRicordi.mese => _IlMese(vista: vista, palette: palette),
      LivelloDeiRicordi.settimana =>
        _LaSettimana(vista: vista, palette: palette),
      LivelloDeiRicordi.giorno => _IlGiorno(vista: vista, palette: palette),
    };
  }
}

/// L'ANNO: dodici caselle, ognuna col suo peso e col suo colore dominante.
///
/// **Nessun testo da leggere per capire dove hai camminato**, che e' la regola
/// del progetto sul livello visivo. Il numero c'e', ma sotto la casella.
class _LAnno extends StatelessWidget {
  const _LAnno({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  static const List<String> _mesi = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    final mesi = vista.iDodiciMesi;
    final massimo =
        mesi.fold<int>(0, (m, r) => r.quanteVoci > m ? r.quanteVoci : m);
    return GridView.count(
      key: const Key('ricordi_anno'),
      crossAxisCount: 3,
      padding: const EdgeInsets.all(SpacingTokens.md),
      mainAxisSpacing: SpacingTokens.sm,
      crossAxisSpacing: SpacingTokens.sm,
      children: [
        for (var i = 0; i < 12; i++)
          _CasellaDelMese(
            key: Key('ricordi_mese_${i + 1}'),
            nome: _mesi[i],
            riassunto: mesi[i],
            peso: mesi[i].pesoContro(massimo),
            palette: palette,
            onTap: mesi[i].vuoto
                ? null
                : () => vista.scendiA(LivelloDeiRicordi.mese,
                    quando: DateTime(vista.dove.year, i + 1, 1)),
          ),
      ],
    );
  }
}

class _CasellaDelMese extends StatelessWidget {
  const _CasellaDelMese({
    super.key,
    required this.nome,
    required this.riassunto,
    required this.peso,
    required this.palette,
    this.onTap,
  });

  final String nome;
  final RiassuntoDelTempo riassunto;
  final double peso;
  final MaestroPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dominante = riassunto.maestroDominante;
    final colore = _coloreDi(dominante) ?? palette.gold;
    // **UN MESE VUOTO NON SI VESTE COME UN MESE IN PAREGGIO.** Trovato
    // guardando l'anteprima: l'oro voleva dire due cose diverse, "in questo
    // mese hai usato due Maestri alla pari" e "in questo mese non hai fatto
    // niente", e a colpo d'occhio erano la stessa casella. Adesso il vuoto e'
    // spento e senza bordo acceso: si legge che li' non c'e' niente prima di
    // leggere lo zero.
    final vuoto = riassunto.vuoto;
    return InkWell(
      enableFeedback: false,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: vuoto
              ? Colors.transparent
              : colore.withValues(alpha: 0.12 + 0.5 * peso),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(
              color: vuoto
                  ? ColorTokens.textSecondary.withValues(alpha: 0.15)
                  : colore.withValues(alpha: 0.4)),
        ),
        padding: const EdgeInsets.all(SpacingTokens.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **SI SPEGNE LA CASELLA, NON LE PAROLE.** Il primo tentativo
            // sbiadiva anche il nome del mese e il suo zero, e la guardia dei
            // grigi lo ha bocciato a 3,87 contro il 4,5 che la legge chiede:
            // un mese vuoto resta un mese, e il suo nome si deve leggere. La
            // differenza fra vuoto e pieno la fa il riquadro, che e' il
            // livello visivo, non il testo.
            Text(nome,
                style: TypographyTokens.etichetta()
                    .copyWith(color: vuoto ? ColorTokens.textSecondary : null)),
            const SizedBox(height: SpacingTokens.xs),
            Text('${riassunto.quanteVoci}',
                style: TypographyTokens.titoloScheda().copyWith(
                    color: vuoto
                        ? ColorTokens.textSecondary
                        : ColorTokens.textPrimary)),
          ],
        ),
      ),
    );
  }

  static Color? _coloreDi(String? maestro) => switch (maestro) {
        'medora' => MaestroPalette.medora.primary,
        'aura' => MaestroPalette.aura.primary,
        'caligo' => MaestroPalette.caligo.primary,
        _ => null,
      };
}

/// IL MESE: le settimane in fila, ognuna con la sua riga di sintesi.
class _IlMese extends StatelessWidget {
  const _IlMese({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final settimane = vista.leSettimaneDelMese;
    return ListView(
      key: const Key('ricordi_mese'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: [
        _RigaDelRitorno(
          etichetta: 'Torna all\'anno',
          onTap: () => vista.scendiA(LivelloDeiRicordi.anno),
        ),
        // **LA LETTURA DEL MESE, ordine CG voce 11.** E' l'unica prosa
        // generata di tutta la funzione, e sta IN CIMA al livello mese: chi
        // apre il mese legge prima cosa quel mese ha significato, poi i
        // numeri delle settimane.
        _LaLetturaDelMese(vista: vista, palette: palette),
        for (final s in settimane)
          _RigaDiSintesi(
            key: Key('ricordi_settimana_${s.chiave}'),
            titolo: _titoloDellaSettimana(s.chiave),
            riassunto: s,
            palette: palette,
            onTap: s.vuoto
                ? null
                : () => vista.scendiA(LivelloDeiRicordi.settimana,
                    quando: _primoGiornoDi(s.chiave)),
          ),
      ],
    );
  }

  static DateTime _primoGiornoDi(String chiave) {
    final pezzi = chiave.split('..').first.split('-');
    return DateTime(
        int.parse(pezzi[0]), int.parse(pezzi[1]), int.parse(pezzi[2]));
  }

  static String _titoloDellaSettimana(String chiave) {
    final da = _primoGiornoDi(chiave);
    final a = da.add(const Duration(days: 6));
    return 'Dal ${da.day} al ${a.day}';
  }
}

/// LA SETTIMANA: i giorni in fila, con la stessa forma di riga del mese.
class _LaSettimana extends StatelessWidget {
  const _LaSettimana({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  static const List<String> _giorni = [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica',
  ];

  @override
  Widget build(BuildContext context) {
    final giorni = vista.iGiorniDellaSettimana;
    final lunedi = RiassuntiDelTempo.lunediDi(vista.dove);
    return ListView(
      key: const Key('ricordi_settimana'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: [
        _RigaDelRitorno(
          etichetta: 'Torna al mese',
          onTap: () => vista.scendiA(LivelloDeiRicordi.mese),
        ),
        for (var i = 0; i < giorni.length; i++)
          _RigaDiSintesi(
            key: Key('ricordi_giorno_${giorni[i].chiave}'),
            titolo: '${_giorni[i]} ${lunedi.add(Duration(days: i)).day}',
            riassunto: giorni[i],
            palette: palette,
            onTap: giorni[i].vuoto
                ? null
                : () => vista.scendiA(LivelloDeiRicordi.giorno,
                    quando: lunedi.add(Duration(days: i))),
          ),
      ],
    );
  }
}

/// IL GIORNO: il riepilogo in una riga, e sotto le voci raggruppate.
class _IlGiorno extends StatelessWidget {
  const _IlGiorno({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final giorno = vista.ilGiorno;
    final gruppi = vista.iGruppiDelGiorno;
    return ListView(
      key: const Key('ricordi_giorno'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: [
        _RigaDelRitorno(
          etichetta: 'Torna alla settimana',
          onTap: () => vista.scendiA(LivelloDeiRicordi.settimana),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          // **LA PORTA DEL RUOLO LETTURA, non un Text nudo.** Regola di
          // casa: da un Text diretto torna il muro di testo, ed e' la
          // famiglia delle due porte.
          child: ParagrafiDiLettura(
            testo: _riepilogo(giorno),
            key: const Key('ricordi_riepilogo_del_giorno'),
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
        ),
        for (final g in gruppi)
          _RigaDelGruppo(
            key: Key('ricordi_gruppo_${g.arte}_'
                '${g.voci.first.quando.millisecondsSinceEpoch}'),
            gruppo: g,
            palette: palette,
          ),
        const SizedBox(height: SpacingTokens.xxxl),
      ],
    );
  }

  /// **IL RIEPILOGO E' UN CONTO, non una frase generata.**
  static String _riepilogo(RiassuntoDelTempo r) {
    if (r.vuoto) return 'Quel giorno il Cerchio è rimasto in silenzio.';
    final pezzi = <String>[
      '${r.quanteVoci} ${r.quanteVoci == 1 ? "momento" : "momenti"}',
      // **UNO SI DICE DONO, non Doni.** Trovato guardando l'anteprima: la
      // riga diceva "1 Doni su 5". E' la stessa famiglia dei "I tuoi Stella"
      // che l'ordine P voce 38 aveva gia' chiuso altrove.
      '${r.quantiDoni} ${r.quantiDoni == 1 ? "Dono" : "Doni"} su '
          '${ContiDelleArti.gestiDeiDoni.length}',
      if (r.quantiTraguardi > 0)
        '${r.quantiTraguardi} ${r.quantiTraguardi == 1 ? "traguardo" : "traguardi"}',
    ];
    final dominante = r.maestroDominante;
    final coda =
        dominante == null ? '' : ', soprattutto con ${_nome(dominante)}';
    return '${pezzi.join(", ")}$coda.';
  }

  static String _nome(String maestro) => switch (maestro) {
        'medora' => 'Medora',
        'aura' => 'Aura',
        'caligo' => 'Caligo',
        _ => maestro,
      };
}

/// Una riga di sintesi, la stessa forma per la settimana e per il giorno.
class _RigaDiSintesi extends StatelessWidget {
  const _RigaDiSintesi({
    super.key,
    required this.titolo,
    required this.riassunto,
    required this.palette,
    this.onTap,
  });

  final String titolo;
  final RiassuntoDelTempo riassunto;
  final MaestroPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(titolo, style: TypographyTokens.titoloScheda()),
      subtitle: Text(
        riassunto.vuoto
            ? 'Niente'
            : '${riassunto.quanteVoci} momenti, '
                '${riassunto.quantiTraguardi} traguardi',
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary),
      ),
      trailing: riassunto.vuoto
          ? null
          : const Icon(Icons.chevron_right_rounded,
              color: ColorTokens.goldLight),
    );
  }
}

/// Una riga del giorno: una voce sola, oppure un gruppo che si apre.
class _RigaDelGruppo extends StatefulWidget {
  const _RigaDelGruppo(
      {super.key, required this.gruppo, required this.palette});

  final GruppoDelGiorno gruppo;
  final MaestroPalette palette;

  @override
  State<_RigaDelGruppo> createState() => _RigaDelGruppoState();
}

class _RigaDelGruppoState extends State<_RigaDelGruppo> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.gruppo;
    if (!g.chiuso) {
      return _RigaDellaVoce(voce: g.voci.first, palette: widget.palette);
    }
    final titolo = ArtiConResponso.di(g.arte)?.titolo ?? g.arte;
    return Column(
      children: [
        ListTile(
          key: Key('ricordi_gruppo_chiuso_${g.arte}'),
          // **IL TOCCO STA PRIMA DELLA FRECCIA, e non e' un vezzo.** La
          // guardia delle frecce in giu' guarda le righe SOPRA per trovare il
          // gesto: con l'onTap piu' in basso la freccia risultava decorazione.
          // Scritto cosi' si legge anche meglio: prima che la riga si tocca,
          // poi il segno che lo dice.
          onTap: () => setState(() => _aperto = !_aperto),
          title: Text('$titolo, ${g.quante} volte',
              style: TypographyTokens.titoloScheda()),
          trailing: Icon(
              _aperto ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: ColorTokens.goldLight),
        ),
        if (_aperto)
          for (final v in g.voci)
            Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.lg),
              child: _RigaDellaVoce(voce: v, palette: widget.palette),
            ),
      ],
    );
  }
}

class _RigaDellaVoce extends StatelessWidget {
  const _RigaDellaVoce({required this.voce, required this.palette});

  final VoceDelRicordo voce;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('ricordi_voce_${voce.chiave}'),
      leading: Icon(Icons.circle, size: 10, color: _colore(voce.maestro)),
      title: Text(voce.titolo, style: TypographyTokens.corpo()),
      subtitle: Text(
        '${voce.quando.hour.toString().padLeft(2, '0')}:'
        '${voce.quando.minute.toString().padLeft(2, '0')}',
        style: TypographyTokens.didascalia()
            .copyWith(color: ColorTokens.textSecondary),
      ),
      onTap:
          voce.riferimento == null ? null : () => _apriIlRicordo(context, voce),
    );
  }

  static Color _colore(String maestro) => switch (maestro) {
        'medora' => MaestroPalette.medora.primary,
        'aura' => MaestroPalette.aura.primary,
        'caligo' => MaestroPalette.caligo.primary,
        _ => ColorTokens.goldLight,
      };

  /// **IL RICORDO SI RIAPRE COM'ERA, ordine CG voce 04.**
  static void _apriIlRicordo(BuildContext context, VoceDelRicordo voce) {
    if (voce.tipo == TipoDelRicordo.responso) {
      final scrigno = context.read<ScrignoDeiCustoditi>();
      final custodito = scrigno.di(voce.riferimento!);
      if (custodito != null) {
        Navigator.of(context).push(RicordoApertoScreen.route(custodito));
      }
      return;
    }
    // Le conversazioni si riaprono AL PUNTO del turno: la chat ci arriva col
    // suo identificativo, non con una posizione.
    Navigator.of(context).push(RicordoApertoScreen.rottaDelTurno(voce));
  }
}

class _RigaDelRitorno extends StatelessWidget {
  const _RigaDelRitorno({required this.etichetta, required this.onTap});

  final String etichetta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('ricordi_torna_su'),
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: Text(etichetta),
    );
  }
}

/// I RISULTATI DELLA RICERCA, che non dipendono dal livello.
class _IRisultati extends StatelessWidget {
  const _IRisultati({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final trovate = vista.risultati;
    if (trovate.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(
            'Nessun ricordo con queste parole. La ricerca guarda le tue '
            'domande e i titoli dei responsi.',
            key: const Key('ricordi_nessun_risultato'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
        ),
      );
    }
    return ListView(
      key: const Key('ricordi_risultati'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: [
        for (final v in trovate) _RigaDellaVoce(voce: v, palette: palette),
      ],
    );
  }
}

/// IL RICORDO APERTO. Ordine CG voce 04.
///
/// **Un responso custodito torna nella sua forma originale**, col suo segno
/// grafico e col suo pulsante di condivisione.
class RicordoApertoScreen extends StatelessWidget {
  const RicordoApertoScreen({super.key, required this.custodito});

  final RicordoCustodito custodito;

  static Route<void> route(RicordoCustodito custodito) =>
      PassaggioDelCerchio.rotta<void>(
        (_) => MaestroScope(child: RicordoApertoScreen(custodito: custodito)),
      );

  /// **LA CONVERSAZIONE SI RIAPRE AL PUNTO DEL TURNO, non in cima.**
  ///
  /// La rotta porta l'identificativo del turno e non la sua posizione: aprire
  /// per posizione vorrebbe dire mostrare un turno diverso appena la
  /// cronologia cambia di una riga.
  static Route<void> rottaDelTurno(VoceDelRicordo voce) =>
      PassaggioDelCerchio.rotta<void>(
        (_) => MaestroScope(child: _ConversazioneRiaperta(voce: voce)),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        title: Text(custodito.titolo,
            key: const Key('ricordo_aperto_titolo'),
            style: TypographyTokens.titoloScheda()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          children: [
            // **L'ARTE PRIMA DEL TESTO**, che e' la regola di casa
            // sull'anatomia di un responso: colpo d'occhio visivo, poi la
            // sintesi, poi il racconto. Qui il colpo d'occhio e' la carta
            // stessa, ridisegnata dai dati custoditi.
            //
            // **Una stesa ne mostra tre**, affiancate e nell'ordine in cui
            // sono uscite, perche' una stesa a tre carte letta con una carta
            // sola non e' quella stesa.
            if (ArtworkDelRicordo.di(custodito).isNotEmpty)
              _ArteDelRicordoAperto(custodito: custodito, palette: palette),
            Text(
              '${custodito.quando.day}/${custodito.quando.month}/'
              '${custodito.quando.year}',
              key: const Key('ricordo_aperto_quando'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            // Un responso custodito e' testo da leggere per intero: passa
            // dalla porta comune, come ogni altro responso dell'app.
            ParagrafiDiLettura(
                testo: custodito.testo,
                key: const Key('ricordo_aperto_testo'),
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
          ],
        ),
      ),
    );
  }
}

/// La conversazione riaperta al punto del turno toccato.
class _ConversazioneRiaperta extends StatelessWidget {
  const _ConversazioneRiaperta({required this.voce});

  final VoceDelRicordo voce;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        title: Text('Quel giorno', style: TypographyTokens.titoloScheda()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          children: [
            ParagrafiDiLettura(
                testo: voce.titolo,
                key: const Key('turno_riaperto_titolo'),
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Turno ${voce.riferimento}',
              key: const Key('turno_riaperto_riferimento'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// LE TUE CARTE. Ordine CG voce 07.
///
/// **Parole del fondatore**: "potra' avere anche una funzione, un menu, una
/// schermata dedicata alla ricerca delle card generate e condivise, una specie
/// di menu le tue carte".
///
/// **Non e' una schermata separata dai Ricordi: e' una loro pastiglia.** La
/// ragione, che vale piu' della scelta: due magazzini che contengono le stesse
/// cose sono la famiglia di difetti piu' numerosa di questo progetto. Qui il
/// magazzino e' quello dello scrigno, lo stesso che riempie la timeline.
///
/// **Si vede a griglia, con le carte disegnate e non con righe di testo**,
/// perche' sono oggetti visivi: e' la regola di casa sul livello visivo prima
/// del testo.
class _LeTueCarte extends StatelessWidget {
  const _LeTueCarte({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final scrigno = context.watch<ScrignoDeiCustoditi>();
    final carte = scrigno.tutti;
    if (carte.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(
            'Non hai ancora custodito niente. Sotto ogni responso trovi '
            'Custodisci: quello che tieni resta qui per sempre.',
            key: const Key('ricordi_carte_vuote'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
          ),
        ),
      );
    }
    return GridView.count(
      key: const Key('ricordi_le_tue_carte'),
      crossAxisCount: 2,
      // **IL RIQUADRO E' ALTO QUANTO UNA CARTA PIU' IL SUO NOME.** A 0.7 la
      // carta usciva alta un terzo del riquadro e sembrava una figurina
      // appoggiata in mezzo al vuoto: l'anteprima lo ha mostrato subito. Una
      // carta sta due a tre, e sopra ci vanno due righe di titolo e la data.
      childAspectRatio: 0.50,
      padding: const EdgeInsets.all(SpacingTokens.md),
      mainAxisSpacing: SpacingTokens.md,
      crossAxisSpacing: SpacingTokens.md,
      children: [
        for (final c in carte) _CartaCustodita(custodito: c, palette: palette),
      ],
    );
  }
}

/// L'ARTWORK DI UN RICORDO, disegnato dalla porta giusta.
///
/// **Due porte, non una, e la ragione e' nei cartigli.** Gli artwork dei
/// tarocchi hanno il cartiglio del nome e quello del numero VUOTI: il testo si
/// sovrappone a runtime, per questo un solo mazzo vale per tutte le lingue.
/// Disegnare un tarocco col percorso nudo darebbe una carta senza nome. Per
/// tutte le altre famiglie il file e' gia' completo, e passa da
/// `MiniaturaIntera`, che non ritaglia mai il soggetto.
class _ArtworkDiUnRicordo extends StatelessWidget {
  const _ArtworkDiUnRicordo({
    super.key,
    required this.immagine,
    required this.palette,
    required this.larghezza,
    this.piena = false,
  });

  final ImmagineDelRicordo immagine;
  final MaestroPalette palette;
  final double larghezza;

  /// Vero nel ricordo aperto, dove si mostra il file grande.
  final bool piena;

  /// **QUANTO E' LARGA RISPETTO A QUANT'E' ALTA**, e la sa questo pezzo.
  ///
  /// Chi le fa spazio deve sapere che forma avranno, altrimenti calcola la
  /// misura su una proporzione sbagliata e lascia un vuoto o taglia. Un
  /// tarocco sta due a tre; una pietra, un emblema e un totem stanno nel
  /// quadrato, e dentro il quadrato ci entrano interi.
  static double proporzioneDi(ImmagineDelRicordo immagine) =>
      immagine.carta != null
          ? MiniaturaIntera.proporzioneCarta
          : MiniaturaIntera.proporzioneQuadrata;

  @override
  Widget build(BuildContext context) {
    final carta = immagine.carta;
    if (carta != null) {
      return SizedBox(
        width: larghezza,
        height: larghezza / MiniaturaIntera.proporzioneCarta,
        // Sotto una certa misura i cartigli non si leggono, ed e' la stessa
        // soglia che il mazzo usa altrove: meglio nessuna scritta che una
        // scritta illeggibile sopra il disegno.
        child: TarotCardArt(
            card: carta, palette: palette, showCartigli: larghezza >= 96),
      );
    }
    final figura = MiniaturaIntera(
      path: piena ? immagine.piena : immagine.miniatura,
      ripiego: Icons.auto_awesome,
      palette: palette,
      larghezza: larghezza,
    );
    // **LA RUNA IN OMBRA SI GUARDA CAPOVOLTA**, come nel Rito del Tramonto e
    // nell'Estrazione: e' il verso che ne cambia il presagio, non un vezzo
    // grafico, e mostrarla dritta direbbe un'altra cosa.
    if (!immagine.rovesciata) return figura;
    return Transform.rotate(angle: math.pi, child: figura);
  }
}

/// UNA CARTA CUSTODITA NELLA GRIGLIA.
///
/// **Dal 31 agosto 2026 il riquadro mostra l'arte, non un estratto di testo.**
/// Prima disegnava data, titolo e le prime righe del responso: le parole
/// dell'ordine erano "la ricerca delle card generate e condivise", e una card
/// generata e' un'immagine. Il fondatore lo ha detto guardando la schermata.
///
/// **Le cinque arti senza artwork tengono il riquadro di prima**, e non e' un
/// ripiego trascurato: un Rito dell'Alba consegna una parola, e la parola si
/// legge. Il motivo di ognuna sta scritto in `ArtworkDelRicordo.senzaArtwork`.
class _CartaCustodita extends StatelessWidget {
  const _CartaCustodita({required this.custodito, required this.palette});

  final RicordoCustodito custodito;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final colore = switch (custodito.maestro) {
      'medora' => MaestroPalette.medora.primary,
      'aura' => MaestroPalette.aura.primary,
      'caligo' => MaestroPalette.caligo.primary,
      _ => palette.primary,
    };
    final immagini = ArtworkDelRicordo.di(custodito);
    return InkWell(
      enableFeedback: false,
      key: Key('ricordi_carta_${custodito.chiave}'),
      onTap: () =>
          Navigator.of(context).push(RicordoApertoScreen.route(custodito)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colore.withValues(alpha: 0.35),
              ColorTokens.neutralDeepest,
            ],
          ),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **CON L'ARTE, L'ARTE VA IN CIMA E PRENDE QUASI TUTTO.** E' la
            // regola di casa del livello visivo prima del testo, ed e' anche
            // cio' che rende questa una galleria invece di un elenco. Senza
            // arte resta l'ordine di prima, data e titolo in testa, perche'
            // li' il testo e' l'unica cosa che c'e'.
            if (immagini.isNotEmpty) ...[
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, vincoli) {
                      // **LA MISURA SI RICAVA DALLA PROPORZIONE VERA della
                      // figura, non da una fissa.** Prima si calcolava tutto
                      // come se fosse un tarocco: una pietra quadrata usciva
                      // larga due terzi dello spazio che aveva, cioe' piccola
                      // in mezzo al vuoto.
                      final proporzione =
                          _ArtworkDiUnRicordo.proporzioneDi(immagini.first);
                      final daAltezza = vincoli.maxHeight * proporzione;
                      final larghezza = daAltezza < vincoli.maxWidth
                          ? daAltezza
                          : vincoli.maxWidth;
                      return _ArtworkDiUnRicordo(
                        key: Key('ricordi_arte_${custodito.chiave}'),
                        immagine: immagini.first,
                        palette: palette,
                        larghezza: larghezza,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              // **TRE RIGHE, non due.** A due righe il titolo si chiudeva
              // sui puntini proprio dove dice la cosa utile: "La tua
              // gettata: l...". Il pezzo informativo di questi titoli sta
              // in fondo, sempre, perche' cominciano tutti con "La tua".
              Text(custodito.titolo,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.titoloScheda()),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                '${custodito.quando.day}/${custodito.quando.month}/'
                '${custodito.quando.year}',
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ] else ...[
              Text(
                '${custodito.quando.day}/${custodito.quando.month}/'
                '${custodito.quando.year}',
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(custodito.titolo,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.titoloScheda()),
              const SizedBox(height: SpacingTokens.sm),
              // **IL TESTO SI CHIUDE COI PUNTINI, non a meta' parola.** Trovato
              // guardando l'anteprima: dentro un `Expanded` il taglio lo fa
              // l'ALTEZZA disponibile, e `maxLines` quell'altezza non la
              // conosce, quindi l'ellissi non scattava mai e l'ultima riga
              // usciva mozzata a meta' lettera. **Un ritaglio non e' una
              // chiusura**: chi legge non sa se il testo finisce li' o se
              // continua.
              //
              // Le righe si contano dall'altezza vera, e i puntini tornano a
              // essere i puntini.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, vincoli) {
                    final stile = TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary);
                    final altezzaDiUnaRiga =
                        (stile.fontSize ?? 16) * (stile.height ?? 1.3);
                    final quante =
                        (vincoli.maxHeight / altezzaDiUnaRiga).floor();
                    return Text(
                      custodito.testo,
                      maxLines: quante < 1 ? 1 : quante,
                      overflow: TextOverflow.ellipsis,
                      style: stile,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// L'ARTE IN CIMA AL RICORDO APERTO.
///
/// **Perche' e' un pezzo suo e non tre righe dentro la schermata.** Il ricordo
/// aperto e' una lista che scorre, e un'immagine dentro una lista che scorre
/// ha bisogno di una misura sua: senza, prende tutta l'altezza che trova e
/// spinge il testo fuori dallo schermo. Qui la misura si ricava dalla
/// larghezza vera, una volta sola.
class _ArteDelRicordoAperto extends StatelessWidget {
  const _ArteDelRicordoAperto({required this.custodito, required this.palette});

  final RicordoCustodito custodito;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final immagini = ArtworkDelRicordo.di(custodito);
    if (immagini.isEmpty) return const SizedBox.shrink();
    return Padding(
      key: Key('ricordo_aperto_arte_${custodito.arte}'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.lg),
      child: LayoutBuilder(
        builder: (context, vincoli) {
          // Con piu' immagini si divide la larghezza fra loro, tenendo lo
          // spazio che le separa: tre carte affiancate che si toccano
          // sembrerebbero un'immagine sola.
          final quante = immagini.length;
          final spazi = SpacingTokens.sm * (quante - 1);
          var larghezza = (vincoli.maxWidth - spazi) / quante;
          // **UNA FIGURA SOLA NON SI ALLARGA A TUTTO LO SCHERMO.** Un tarocco
          // solo, largo quanto la pagina, sarebbe alto una volta e mezza e
          // spingerebbe il testo sotto la piega: si apre un ricordo per
          // rileggerlo, non per vedere solo la copertina.
          final proporzione = _ArtworkDiUnRicordo.proporzioneDi(immagini.first);
          final massima = quante == 1 ? vincoli.maxWidth * 0.62 : larghezza;
          if (larghezza > massima) larghezza = massima;
          // Il nome sotto la figura vuole la sua riga: si tiene conto anche
          // dell'altezza, cosi' una figura alta non mangia mezza schermata.
          final daAltezza = 320 * proporzione;
          if (larghezza > daAltezza) larghezza = daAltezza;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < quante; i++) ...[
                if (i > 0) const SizedBox(width: SpacingTokens.sm),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ArtworkDiUnRicordo(
                      immagine: immagini[i],
                      palette: palette,
                      larghezza: larghezza,
                      piena: true,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    // Il nome sotto la figura: negli artwork il cartiglio e'
                    // vuoto per costruzione, e per le famiglie che non sono
                    // tarocchi nessuno lo riempie.
                    if (immagini[i].carta == null)
                      Text(immagini[i].nome,
                          textAlign: TextAlign.center,
                          style: TypographyTokens.didascalia()
                              .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// LA LETTURA DEL MESE, oppure l'invito. Ordine CG voce 11.
///
/// **Per chi non paga la riga non compare in grigio e non ha un lucchetto
/// sopra il testo.** Compare al suo posto un invito che dichiara cosa
/// otterrebbe, secondo le regole di casa sugli inviti: mostrare a meta' cio'
/// che manca e' peggio che non mostrarlo.
class _LaLetturaDelMese extends StatefulWidget {
  const _LaLetturaDelMese({required this.vista, required this.palette});

  final VistaDeiRicordi vista;
  final MaestroPalette palette;

  @override
  State<_LaLetturaDelMese> createState() => _LaLetturaDelMeseState();
}

class _LaLetturaDelMeseState extends State<_LaLetturaDelMese> {
  String? _scritta;
  bool _chiesta = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chiedi();
  }

  Future<void> _chiedi() async {
    if (_chiesta) return;
    _chiesta = true;
    final LetturaDelMese lettura;
    final Tier tier;
    try {
      lettura = context.read<LetturaDelMese>();
      tier = context.read<EntitlementService>().tier;
    } catch (errore) {
      // Un provider assente non spegne la schermata: la riga semplicemente
      // non compare, che e' cio' che succede anche a chi non ha il piano.
      debugPrint('Lettura del mese: i provider non ci sono. $errore');
      return;
    }
    if (!LetturaDelMese.laVede(tier)) return;
    final mese = VoceDelRicordo.chiaveDelMese(widget.vista.dove);
    final fuori = await lettura.per(
      mese: mese,
      tier: tier,
      riassunto: _riassuntoDelMese(),
      settimane: widget.vista.leSettimaneDelMese,
    );
    if (!mounted) return;
    setState(() => _scritta = fuori);
  }

  RiassuntoDelTempo _riassuntoDelMese() {
    final mese = VoceDelRicordo.chiaveDelMese(widget.vista.dove);
    for (final r in widget.vista.iDodiciMesi) {
      if (r.chiave == mese) return r;
    }
    return RiassuntiDelTempo.di(mese, const []);
  }

  @override
  Widget build(BuildContext context) {
    final Tier tier;
    try {
      tier = context.watch<EntitlementService>().tier;
    } catch (errore) {
      return const SizedBox.shrink();
    }
    if (!LetturaDelMese.laVede(tier)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Text(
          LetturaDelMese.invito,
          key: const Key('ricordi_invito_alla_lettura'),
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
      );
    }
    final scritta = _scritta;
    if (scritta == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      // La lettura del mese e' l'unica prosa generata della funzione, ed e'
      // testo da leggere per intero: passa dalla porta comune.
      child: ParagrafiDiLettura(
        testo: scritta,
        key: const Key('ricordi_lettura_del_mese'),
        stile:
            TypographyTokens.lettura().copyWith(color: ColorTokens.textPrimary),
      ),
    );
  }
}
