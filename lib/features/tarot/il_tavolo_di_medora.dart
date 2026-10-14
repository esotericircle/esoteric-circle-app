import 'dart:math' as math;
import '../scene/la_scena_in_video.dart';

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_spread.dart';
import '../../core/tarot/tarot_spread_type.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'il_tavolo_della_stesa.dart';
import 'la_scena_della_stesa_in_video.dart';
import 'stesa_fan.dart';
import 'tarot_card_art.dart';

/// **IL TAVOLO DI MEDORA.** Ordine FL, 12 ottobre 2026.
///
/// Il fondatore: *"SFONDO NUOVO con sovrapposta Medora tagliata alla vita
/// come se fosse dietro il tavolo"*, *"Le carte scelte si stendono sul tavolo
/// mantenendo la stessa prospettiva del tavolo"*, e *"dopo l'animazione di
/// riflessione, le carte si girano sul tavolo una alla volta e dopo un
/// secondo dall'ultima girata, si mettono in verticale ingrandendosi"*.
///
/// **COME E' FATTO.** Lo sfondo e' `assets/img/tavolo/tavolo_medora_v2.webp`,
/// il tappetino blu di Medora che il fondatore ha rigenerato il 12 ottobre
/// 2026 al posto del rosso della v1, con la stessa geometria al pixel (il
/// bordo ricamato, il medaglione e i bordi del velluto stanno dove stavano),
/// tagliato in alto e in basso ([GeometriaDelTavolo]); Medora e' una delle
/// due pose del video della scena (ordine FS aggiunta, vedi
/// [ScenaDellaStesaInVideo]), tagliata alla vita, con la vita posata sul
/// bordo lontano del velluto, cosi' il tavolo le passa davanti. Le
/// carte stanno su un piano piatto, disposte ai posti che la stesa dichiara
/// (`PostoSulTavolo`, letti da `TavoloDellaStesa.disponi`), e il piano e'
/// proiettato sul trapezio del velluto con un'omografia: le carte sono
/// inclinate come il tavolo, non frontali.
class GeometriaDelTavolo {
  const GeometriaDelTavolo._();

  static const String sfondo = 'assets/img/tavolo/tavolo_medora_v2.webp';

  /// **LE DUE POSE DI MEDORA, ordine FS aggiunta voce FS.A1, 14 ottobre
  /// 2026.** LAPIDE: `busto`, `medora_busto_v1.webp` (1142 per 977), la Medora
  /// ferma dell'ordine FL. Adesso la scena e' il video del vortice, e le due
  /// pose sono il suo primo e il suo ultimo fotogramma, consegnate dal
  /// fondatore su bianco e scontornate con
  /// `tool/scontorna_le_pose_di_medora.py`: col mazzo chiuso, finche' il
  /// video non comincia; nell'invito, quando la scena e' ferma (Riduci
  /// Movimento, o un video che non si carica). Misurate, stanno sul
  /// fotogramma del video a due decimi di pixel
  /// (`docs/collaudo/FS/aggiunta_video/a2_allineamento.txt`).
  static const String posaDelMazzo = 'assets/img/tavolo/medora_mazzo_v1.webp';
  static const String posaDellInvito =
      'assets/img/tavolo/medora_invito_v1.webp';

  /// Le misure delle immagini, in pixel: lo sfondo e le due pose.
  static const Size immagine = Size(688, 1536);
  static const Size immagineDiMedora = Size(1120, 958);

  /// **IL TAGLIO IN ALTO E IN BASSO**, in pixel dell'immagine. In alto si
  /// toglie la volta dell'arco finche' la testa di Medora sfiora la barra del
  /// titolo, senza esserne tagliata (il fondatore, guardando le anteprime del
  /// 12 ottobre 2026: "Devi alzare tutto fino a quando la testa di Medora
  /// sfiora il riquadro alto del titolo della schermata"): a 360 punti la
  /// testa comincia quattro punti sotto l'inizio della scena. In basso la
  /// scena finisce sotto il drappo del tavolo, dove comincia il pavimento.
  static const double taglioInAlto = 418;
  static const double taglioInBasso = 1370;

  /// **IL BORDO LONTANO DEL VELLUTO**, in pixel: la vita di Medora ci sta
  /// sopra, e il tavolo le passa davanti.
  static const double bordoLontano = 887;

  /// **IL BORDO DAVANTI DEL TAVOLO**, in pixel: la scena e' alta fino a qui,
  /// e il drappo scende sotto il selettore sfumando (ordine FL voce 02).
  static const double bordoDavanti = 1205;

  /// **IL TAVOLO SFUMA NEL COSMO, ordine FS, 13 ottobre 2026.** LAPIDE: "IL
  /// SUO DRAPPO SFUMA NELLA PAGINA", una fascia scura opaca (0xFF151118) sul
  /// dodici per cento basso della scena, fatta per un fondo piatto di quel
  /// colore (ordine FL voce 01). Col cosmo tornato sotto la stesa (ordine FR)
  /// quella fascia era una banda scura sopra le stelle, e il drappo restava
  /// sotto il pannello "Scegli la tua stesa": il fondatore, sulla 2308, ha
  /// chiesto che l'immagine sfumi verso il basso e riveli il cosmo, e che il
  /// pannello non stia piu' sopra il tavolo. Adesso e' l'immagine stessa a
  /// diventare trasparente fra questi due pixel, e la scena nello schermo e'
  /// alta fino a [fineDellaSfumatura]: il pannello comincia dove il tavolo e'
  /// gia' sparito.
  ///
  /// La scena cresce di soli cinquanta pixel oltre il bordo davanti (circa
  /// ventotto punti a 390): con novanta il ventaglio, dopo la seconda carta,
  /// scendeva a 854 punti su uno schermo di 844 e usciva di portata
  /// (`stesa_coreografia_test.dart`, "il ventaglio resta a portata").
  ///
  /// **IL PANNELLO SFIORA IL BORDO BASSO DEL TAVOLO, 14 ottobre 2026.** Il
  /// fondatore, sulla 2310: *"Devi far salire la bolla 'scegli la tua stesa'
  /// fino a sfiorare il bordo basso del tavolo e tutto quello che sta sotto
  /// alla bolla deve risalire con essa"*. LAPIDE: la sfumatura dal pixel
  /// 1145 (bordo davanti meno sessanta) al 1255 (piu' cinquanta), con il
  /// pannello dopo: fra la cornice d'oro e il pannello restavano circa
  /// quarantatre punti di drappo che sfumava. Adesso la scena finisce al
  /// [bordoBassoDelPiano] con un taglio netto, che e' il bordo vero del
  /// tavolo, dritto e a tutta larghezza; il pannello, velato al 45 per cento,
  /// comincia subito sotto e non ha piu' niente del tavolo dietro di se'.
  static const double inizioDellaSfumatura = bordoBassoDelPiano;
  static const double fineDellaSfumatura = bordoBassoDelPiano;

  /// **IL BORDO BASSO DEL PIANO**, in pixel dell'immagine: la riga dopo il
  /// bordino chiaro della cornice davanti (righe da 1206 a 1214, misurate
  /// riga per riga); dal 1216 comincia il drappo scuro.
  static const double bordoBassoDelPiano = 1215;

  /// In alto l'immagine entra nel cosmo per i primi pixel, cosi' passando
  /// sotto la barra semitrasparente non mostra un bordo netto.
  ///
  /// **SEI PIXEL, COL FILMATO E SENZA, e la scena comincia sotto la barra
  /// proprio di tanto (`StesaTreCarteScreen`).** Il fondatore, sulla 2309 e
  /// di nuovo sulla 2310: *"sopra la testa di Medora c'e' una barra azzurra
  /// piena da eliminare. Sopra c'e' la giusta barra del titolo
  /// semitrasparente"*. Era il cosmo, senza il velo della barra, nel margine
  /// di otto punti fra la barra e la scena (misurato sul Realme: dal pixel
  /// 392 al 417, `docs/collaudo/FS/aggiunta_video/a6_la_fascia_sotto_la_
  /// barra.txt`). LAPIDE: quaranta pixel con la scena ferma, sei col
  /// filmato (`ScenaDellaStesaInVideo.sfumaturaInAlto`): con la scena che
  /// sale sotto il velo per tutta la sfumatura, quaranta avrebbero spostato
  /// la scena di diciotto punti quando il filmato parte, o lasciato il cosmo
  /// chiaro sotto la barra finche' non parte. Sei pixel sono quelli che i
  /// capelli di Medora nel filmato permettono (la testa comincia otto pixel e
  /// mezzo sotto il taglio).
  static const double sfumaturaInAlto = 6;

  /// **IL CAMPO DEL VELLUTO DENTRO IL BORDO RICAMATO**, i quattro angoli in
  /// pixel, misurati sull'immagine: in fondo a sinistra, in fondo a destra,
  /// davanti a destra, davanti a sinistra.
  static const List<Offset> campo = [
    Offset(150, 930),
    Offset(512, 930),
    Offset(606, 1162),
    Offset(60, 1162),
  ];

  /// **LA PROFONDITA' VERA DEL CAMPO**, rispetto alla sua larghezza: il
  /// medaglione al centro, che e' un cerchio, si vede schiacciato a 0,475, e
  /// da li' il campo e' circa 1,1 volte piu' profondo che largo.
  static const double profondita = 1.1;

  /// La larghezza di Medora, rispetto allo schermo: le carte che le girano
  /// intorno restano fra la lanterna a sinistra e la candela a destra.
  static const double larghezzaDiMedora = 0.8;

  /// Il punto della posa dove comincia la testa, in pixel della posa
  /// (misurata: la prima riga piena e' la 21 in tutte e due).
  static const double cimaDellaTesta = 21;

  /// L'altezza del taglio, in pixel dell'immagine.
  static const double altoDelTaglio = taglioInBasso - taglioInAlto;

  /// La scala: punti logici per pixel dell'immagine, a larghezza [w].
  static double scala(double w) => w / immagine.width;

  /// L'altezza della scena a larghezza [w].
  static double altezza(double w) => (taglioInBasso - taglioInAlto) * scala(w);

  /// Un punto dell'immagine nelle coordinate della scena.
  static Offset nellaScena(Offset px, double w) =>
      Offset(px.dx * scala(w), (px.dy - taglioInAlto) * scala(w));

  /// Il rettangolo di Medora nella scena.
  static Rect medora(double w) {
    final larga = w * larghezzaDiMedora;
    final alta = larga * immagineDiMedora.height / immagineDiMedora.width;
    final vita = (bordoLontano - taglioInAlto) * scala(w);
    return Rect.fromLTWH((w - larga) / 2, vita - alta, larga, alta);
  }

  /// Dove comincia la testa di Medora, nella scena.
  static double testaDiMedora(double w) {
    final m = medora(w);
    return m.top + cimaDellaTesta * m.width / immagineDiMedora.width;
  }

  /// Il piano piatto su cui si dispongono le carte, in punti logici.
  static Size piano(double w) {
    final c = [for (final p in campo) nellaScena(p, w)];
    final largo = c[2].dx - c[3].dx;
    return Size(largo, largo * profondita);
  }

  /// **L'OMOGRAFIA dal piano piatto al trapezio del velluto**, come matrice
  /// da dare a un `Transform`.
  static Matrix4 omografia(double w) {
    final p = piano(w);
    final da = [
      Offset.zero,
      Offset(p.width, 0),
      Offset(p.width, p.height),
      Offset(0, p.height),
    ];
    final a = [for (final q in campo) nellaScena(q, w)];
    return omografiaFra(da, a);
  }

  /// Un punto del piano piatto nella scena.
  static Offset proietta(Offset sulPiano, double w) =>
      MatrixUtils.transformPoint(omografia(w), sulPiano);

  /// **L'OMOGRAFIA FRA DUE QUADRILATERI**, risolta coi quattro angoli (il
  /// sistema di otto equazioni del metodo diretto).
  static Matrix4 omografiaFra(List<Offset> da, List<Offset> a) {
    final m = List.generate(8, (_) => List<double>.filled(9, 0));
    for (var i = 0; i < 4; i++) {
      final x = da[i].dx, y = da[i].dy, u = a[i].dx, v = a[i].dy;
      m[2 * i] = [x, y, 1, 0, 0, 0, -u * x, -u * y, u];
      m[2 * i + 1] = [0, 0, 0, x, y, 1, -v * x, -v * y, v];
    }
    for (var c = 0; c < 8; c++) {
      var r = c;
      for (var k = c + 1; k < 8; k++) {
        if (m[k][c].abs() > m[r][c].abs()) r = k;
      }
      final t = m[c];
      m[c] = m[r];
      m[r] = t;
      for (var k = 0; k < 8; k++) {
        if (k == c) continue;
        final f = m[k][c] / m[c][c];
        for (var j = c; j < 9; j++) {
          m[k][j] -= f * m[c][j];
        }
      }
    }
    final h = [for (var i = 0; i < 8; i++) m[i][8] / m[i][i]];
    // x' = (h0 x + h1 y + h2) / (h6 x + h7 y + 1), y' = (h3 x + h4 y + h5) / (...)
    return Matrix4(
        h[0], h[3], 0, h[6], h[1], h[4], 0, h[7], 0, 0, 1, 0, h[2], h[5], 0, 1);
  }

  /// **IL CENTRO DELLA FILA IN PIEDI**, in pixel dell'immagine: le carte si
  /// alzano davanti al tavolo, un po' sopra il centro del velluto.
  static const double centroDellaFila = 1010;

  /// Le carte in piedi della stesa coi [posti] dati, su una scena larga [w].
  static FilaAlzata fila(List<PostoSulTavolo> posti, double w) =>
      FilaAlzata.per(
          posti, w, nellaScena(const Offset(0, centroDellaFila), w).dy);

  /// La disposizione delle carte sul piano piatto, ai posti della stesa, e
  /// lo scarto verticale che la centra sul piano.
  static ({double larghezza, List<Offset> angoli}) carteSulPiano(
      List<PostoSulTavolo> posti, double w) {
    final p = piano(w);
    // **IL MARGINE DEL CAMPO, STRETTO.** Il fondatore, 12 ottobre 2026:
    // "anche quando le carte sono posizionate appoggiate sul tavolo, cerca
    // di ingrandirle in modo da occupare quasi tutta la superficie del
    // tavolo". Il tetto a 0,34 volte il piano teneva la carta sola a un
    // terzo del tavolo anche con tutto il campo libero: tolto, il tetto e'
    // il piano stesso (vedi larghezzaMassima sotto). Il vero limite, per le
    // stese su piu' righe logiche, resta l'altezza del campo: a 0,97 il
    // margine rimasto fra la carta piu' vicina al bordo e il bordo ricamato
    // e' di oltre quattro punti, cercato a mano fra 0,86 (il margine di
    // prima) e 0,99 (docs/collaudo/FM/aggiunta_1/a1_margine_del_tavolo.txt).
    final utile = Size(p.width * 0.97, p.height * 0.97);
    final d = TavoloDellaStesa.disponi(
        posti, utile.width, (l) => l / kAspettoDellaCarta,
        larghezzaMassima: p.width, altezzaMassima: utile.height);
    final dx = (p.width - utile.width) / 2;
    final dy = (p.height - d.misura.height) / 2;
    return (
      larghezza: d.larghezza,
      angoli: [for (final a in d.angoli) a + Offset(dx, dy)],
    );
  }
}

/// La proporzione della carta, larghezza su altezza.
const double kAspettoDellaCarta = 2 / 3;

/// **LA SCENA**: lo sfondo tagliato, Medora dietro il tavolo, le carte sul
/// piano e, quando si alzano, la fila delle carte in piedi.
class TavoloDiMedora extends StatelessWidget {
  const TavoloDiMedora({
    super.key,
    required this.posti,
    required this.carte,
    required this.palette,
    this.girata,
    this.alzata = 0,
    this.chiave,
    this.filaAlzata,
    this.chiaveDelPiano,
    this.faccia,
    this.posa = GeometriaDelTavolo.posaDellInvito,
    this.filmato,
    this.filmatoSaltato = false,
  });

  final List<PostoSulTavolo> posti;

  /// **LA POSA DI MEDORA quando la scena e' ferma**, una delle due di
  /// [GeometriaDelTavolo]. Ordine FS aggiunta.
  final String posa;

  /// **IL VIDEO DELLA SCENA**, quando e' cominciato: prende il posto dello
  /// sfondo e di Medora ferma, nel riquadro di
  /// [ScenaDellaStesaInVideo.nellaScena], e resta sull'ultimo fotogramma.
  /// Nullo, la scena ferma. Ordine FS aggiunta, voce FS.A2.
  final Widget? filmato;

  /// **IL VIDEO SALTATO COL TOCCO**, ordine FU voce FU.15: il filmato sfuma
  /// e la posa ferma appare al suo posto, in dissolvenza incrociata.
  final bool filmatoSaltato;

  /// Le carte, una per posto; nulla dove la carta non e' ancora scelta.
  final List<DrawnCard?> carte;
  final MaestroPalette palette;

  /// Quanto e' girata la carta del posto (da 0 coperta a 1 scoperta).
  final double Function(int posto)? girata;

  /// Quanto le carte si sono alzate, da 0 sul tavolo a 1 in piedi.
  final double alzata;

  /// Il posto della carta chiave, che si illumina da sotto.
  final int? chiave;

  /// La fila delle carte in piedi, data dalla schermata: a [alzata] uguale a
  /// 1 prende il posto delle carte che si alzano.
  final Widget Function(BuildContext context, FilaAlzata fila)? filaAlzata;

  /// La chiave del piano, per sapere dove sta un posto sullo schermo.
  final GlobalKey? chiaveDelPiano;

  /// La faccia della carta nel mazzo scelto, data dalla schermata. Senza,
  /// il Rider-Waite di casa: nel primo giro dell'ordine FL il tavolo
  /// disegnava sempre quello, anche a chi aveva scelto Marsiglia.
  final Widget Function(DrawnCard carta)? faccia;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final s = GeometriaDelTavolo.scala(w);
      final alta = GeometriaDelTavolo.altezza(w);
      final medora = GeometriaDelTavolo.medora(w);
      final piano = GeometriaDelTavolo.piano(w);
      final h = GeometriaDelTavolo.omografia(w);
      final sulPiano = GeometriaDelTavolo.carteSulPiano(posti, w);
      final fila = GeometriaDelTavolo.fila(posti, w);
      return SizedBox(
        width: w,
        height: alta,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // LO SFONDO, tagliato in alto e in basso: sotto il drappo il
            // pavimento e la gamba del tavolo non si vedono.
            Positioned(
              left: 0,
              top: 0,
              width: w,
              height: alta,
              child: ShaderMask(
                key: const Key('tavolo_sfumatura'),
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [
                    0,
                    GeometriaDelTavolo.sfumaturaInAlto /
                        GeometriaDelTavolo.altoDelTaglio,
                    (GeometriaDelTavolo.inizioDellaSfumatura -
                            GeometriaDelTavolo.taglioInAlto) /
                        GeometriaDelTavolo.altoDelTaglio,
                    (GeometriaDelTavolo.fineDellaSfumatura -
                            GeometriaDelTavolo.taglioInAlto) /
                        GeometriaDelTavolo.altoDelTaglio,
                  ],
                ).createShader(r),
                child: ClipRect(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: w,
                          maxWidth: w,
                          minHeight: GeometriaDelTavolo.immagine.height * s,
                          maxHeight: GeometriaDelTavolo.immagine.height * s,
                          child: Transform.translate(
                            offset:
                                Offset(0, -GeometriaDelTavolo.taglioInAlto * s),
                            child: Image.asset(GeometriaDelTavolo.sfondo,
                                key: const Key('tavolo_sfondo'),
                                fit: BoxFit.fill,
                                filterQuality: FilterQuality.medium),
                          ),
                        ),
                      ),
                      // IL VIDEO DELLA SCENA, sopra lo sfondo e dentro la
                      // stessa sfumatura: il velluto del filmato sfuma nel
                      // cosmo come quello fermo. Ordine FS aggiunta.
                      //
                      // **STESSA TECNICA DELLO SFONDO, non un `Positioned`
                      // col top negativo.** Ordine del 14 ottobre 2026, dal
                      // telefono vero: appena sotto la barra del titolo si
                      // vedeva una banda piatta, sospettata del contatto fra
                      // il texture del video (reso dalla GPU vera, non dal
                      // software di una prova) e il bordo del `ClipRect` che
                      // lo ritaglia quando parte gia' spostato in alto di un
                      // top negativo. Lo sfondo ha sempre usato
                      // `OverflowBox` piu' `Transform.translate` (uno
                      // spostamento di disegno, non un posizionamento
                      // fuori dal riquadro) e non ha mai mostrato questo
                      // difetto: il video segue la stessa strada. La chiave
                      // resta sul riquadro del filmato, dentro lo
                      // spostamento: la sua posizione misurata resta la
                      // stessa di prima (`docs/collaudo/FS/aggiunta_video/`).
                      if (filmato != null)
                        Positioned.fill(
                          child: OverflowBox(
                            alignment: Alignment.topLeft,
                            minWidth: w,
                            maxWidth: w,
                            minHeight: (ScenaDellaStesaInVideo.sotto -
                                    ScenaDellaStesaInVideo.sopra) *
                                s,
                            maxHeight: (ScenaDellaStesaInVideo.sotto -
                                    ScenaDellaStesaInVideo.sopra) *
                                s,
                            child: Transform.translate(
                              offset: Offset(
                                  0,
                                  (ScenaDellaStesaInVideo.sopra -
                                          GeometriaDelTavolo.taglioInAlto) *
                                      s),
                              child: SizedBox(
                                key: const Key('tavolo_filmato'),
                                width: w,
                                height: (ScenaDellaStesaInVideo.sotto -
                                        ScenaDellaStesaInVideo.sopra) *
                                    s,
                                child: IlFilmatoCheSfuma(
                                    saltato: filmatoSaltato, child: filmato!),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // MEDORA FERMA, con la vita sul bordo lontano del velluto. Col
            // filmato in scena Medora e' nel filmato.
            if (filmato == null || filmatoSaltato)
              Positioned.fromRect(
                rect: medora,
                child: LaScenaFermaCheAppare(
                  appare: filmatoSaltato,
                  child: Image.asset(posa,
                      key: const Key('tavolo_medora'),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium),
                ),
              ),
            // LAPIDE: "IL SUO DRAPPO SFUMA NELLA PAGINA", la fascia scura
            // opaca; adesso sfuma l'immagine stessa, vedi
            // `GeometriaDelTavolo.inizioDellaSfumatura` (ordine FS).
            // LE CARTE SUL PIANO, finche' non si sono alzate del tutto.
            if (alzata < 1)
              Positioned(
                left: 0,
                top: 0,
                width: piano.width,
                height: piano.height,
                child: Transform(
                  key: chiaveDelPiano,
                  transform: h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (var i = 0; i < carte.length; i++)
                        if (carte[i] != null && alzata == 0)
                          Positioned(
                            key: ValueKey('tavolo_carta_$i'),
                            left: sulPiano.angoli[i].dx,
                            top: sulPiano.angoli[i].dy,
                            width: sulPiano.larghezza,
                            height: sulPiano.larghezza / kAspettoDellaCarta,
                            child: _CartaSulTavolo(
                              carta: carte[i]!,
                              girata: girata?.call(i) ?? 0,
                              luce: chiave == i,
                              diTraverso: posti[i].diTraverso,
                              palette: palette,
                              faccia: faccia,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            // LE CARTE CHE SI ALZANO: dal piano alla fila in piedi.
            if (alzata > 0 && alzata < 1)
              for (var i = 0; i < carte.length; i++)
                if (carte[i] != null)
                  Positioned(
                    key: ValueKey('tavolo_carta_che_si_alza_$i'),
                    left: 0,
                    top: 0,
                    width: fila.larghezza,
                    height: fila.larghezza / kAspettoDellaCarta,
                    child: Transform(
                      transform: _fraIDue(
                        h.clone()
                          ..translateByDouble(sulPiano.angoli[i].dx,
                              sulPiano.angoli[i].dy, 0, 1)
                          ..scaleByDouble(sulPiano.larghezza / fila.larghezza,
                              sulPiano.larghezza / fila.larghezza, 1, 1),
                        Matrix4.translationValues(
                            fila.carte[i].left, fila.carte[i].top, 0),
                        Curves.easeInOutCubic.transform(alzata),
                      ),
                      child: _CartaSulTavolo(
                        carta: carte[i]!,
                        girata: 1,
                        luce: chiave == i,
                        diTraverso: false,
                        palette: palette,
                        faccia: faccia,
                      ),
                    ),
                  ),
            // LA FILA IN PIEDI, che la schermata disegna con le sue scritte.
            if (alzata >= 1 && filaAlzata != null)
              Positioned(
                key: const Key('tavolo_fila_alzata'),
                left: fila.zona.left,
                top: fila.zona.top - fila.testa,
                width: fila.zona.width,
                child: filaAlzata!(context, fila),
              ),
          ],
        ),
      );
    });
  }

  /// Fra due matrici, a [t]: le carte passano dal piano inclinato alla fila.
  static Matrix4 _fraIDue(Matrix4 a, Matrix4 b, double t) {
    final r = Matrix4.zero();
    for (var i = 0; i < 16; i++) {
      r.storage[i] = a.storage[i] + (b.storage[i] - a.storage[i]) * t;
    }
    return r;
  }
}

/// **LA FILA DELLE CARTE IN PIEDI**, affiancate e ingrandite, davanti al
/// tavolo. Ogni carta ha il suo rettangolo nella scena (solo la carta, senza
/// le scritte), e la fila intera sta in [zona].
class FilaAlzata {
  const FilaAlzata({
    required this.larghezza,
    required this.carte,
    required this.zona,
    required this.distanza,
    required this.testa,
    this.perRiga = 0,
    this.righeDichiarate = 0,
  });

  final double larghezza;
  final List<Rect> carte;
  final Rect zona;
  final double distanza;

  /// Quante carte in una riga: zero vuol dire tutte in una.
  final int perRiga;

  /// **QUANTE RIGHE, dichiarate.** Con righe di misura diversa (la Croce
  /// Celtica fa 4+3+3, non 5+5) il numero non si ricava piu' da [perRiga];
  /// lo dice [per].
  final int righeDichiarate;

  int get righe => righeDichiarate > 0
      ? righeDichiarate
      : (perRiga <= 0 ? 1 : (carte.length + perRiga - 1) ~/ perRiga);

  /// **LE CARTE PER RIGA, al piu' quattro.** Il fondatore, 12 ottobre 2026:
  /// prima "in 2 righe da 5 carte", poi di nuovo guardando le anteprime,
  /// *"in verticale punta alla visibilita' di carte e didascalia o testo.
  /// Puoi disporle in verticale anche in 2 file da 3 carte e una da 4
  /// carte"*: dieci carte su cinque per riga restavano strette e le
  /// didascalie lunghe si leggevano a fatica. Le righe sono bilanciate, non
  /// tutte della stessa misura: per dieci carte, 4+3+3.
  static const int carteInUnaRiga = 4;

  /// Lo spazio sotto ogni carta in piedi per la sua scritta, quando la
  /// scritta va su quattro righe (le stese con piu' righe di carte): la
  /// distanza carta-scritta (quattro punti) piu' quattro righe
  /// d'etichetta a diciannove punti l'una, con un margine. Ricalcolato il
  /// 12 ottobre 2026 quando la distanza e' scesa da sedici a quattro punti
  /// e le righe della scritta da due a quattro.
  ///
  /// **QUARANTOTTO, non ottantaquattro. Ordine FS, 14 ottobre 2026.** Il
  /// fondatore: "diminuire lo spazio tra le righe" della Croce Celtica. Le
  /// didascalie adesso stanno in due righe al piu', tutte della stessa
  /// misura (`_scalaDelleEtichette` nella schermata): quattro punti di
  /// distanza, due righe da diciannove, e cinque di margine.
  static const double sottoLaCartaInDueRighe = 48;

  /// Lo stesso spazio quando la scritta sta su una riga sola: la distanza
  /// piu' una riga d'etichetta, con un margine.
  static const double sottoLaCartaInUnaRiga = 28;

  /// Lo spazio sopra le carte per la scritta della carta chiave.
  final double testa;

  /// Lo spazio sopra la carta per la scritta "Carta Chiave": quello della
  /// schermata (`_Slot.spazioDelleParole`), che con le carte della stessa
  /// misura vale sempre 32 punti.
  static double testaPer(double l) => 32;

  /// La fila di [quante] carte su una scena larga [w], centrata in verticale
  /// sul punto [centro] della scena.
  /// Lo spazio fra due carte in piedi, in punti.
  static const double distanzaFraLeCarte = 8;

  /// **LE CARTE IN PIEDI, nella forma della stesa.** Il fondatore, 12
  /// ottobre 2026: *"Nella croce a 4, le carte si sollevano mantenendo la
  /// disposizione a croce"*; poi, guardando le anteprime della Croce
  /// Celtica: *"in verticale punta alla visibilita' di carte e didascalia o
  /// testo. Puoi disporle in verticale anche in 2 file da 3 carte e una da 4
  /// carte"*. La croce a quattro resta croce, col suo centro vuoto; oltre
  /// [carteInUnaRiga] carte, righe bilanciate (dieci carte, 4+3+3); le
  /// altre una riga sola.
  static FilaAlzata per(List<PostoSulTavolo> posti, double w, double centro) {
    const margine = 16.0;
    const distanza = distanzaFraLeCarte;
    final n = math.max(1, posti.length);
    if (eUnaCroce(posti)) return _aCroce(posti, w, centro);
    if (n <= carteInUnaRiga) return _unaRiga(n, w, centro);
    // **RIGHE BILANCIATE, non tutte della stessa misura.** Il numero di
    // righe e' il minimo che tiene ogni riga entro carteInUnaRiga; le carte
    // in piu' del multiplo esatto vanno nelle prime righe (dieci carte, al
    // piu' quattro per riga: tre righe, 4+3+3, non 4+4+2).
    final righe = (n + carteInUnaRiga - 1) ~/ carteInUnaRiga;
    final base = n ~/ righe;
    final resto = n % righe;
    final dimensioniRighe = [
      for (var r = 0; r < righe; r++) base + (r < resto ? 1 : 0),
    ];
    final perRiga = dimensioniRighe.reduce(math.max);
    final larga = math.min(
        (w - 2 * margine - (perRiga - 1) * distanza) / perRiga, w * 0.42);
    final alta = larga / kAspettoDellaCarta;
    final testa = testaPer(larga);
    // Da una riga alla successiva: la carta, la sua scritta sotto e la
    // testa della riga dopo, dove sta "Carta Chiave".
    final passo = alta + sottoLaCartaInDueRighe + testa;
    final altaTutta = alta + (righe - 1) * passo;
    final cima = centro - altaTutta / 2;
    final carte = <Rect>[];
    for (var r = 0; r < righe; r++) {
      final contaRiga = dimensioniRighe[r];
      final totaleRiga = contaRiga * larga + (contaRiga - 1) * distanza;
      final sinistraRiga = (w - totaleRiga) / 2;
      for (var c = 0; c < contaRiga; c++) {
        carte.add(Rect.fromLTWH(sinistraRiga + c * (larga + distanza),
            cima + r * passo, larga, alta));
      }
    }
    final largaDellaZona =
        dimensioniRighe.first * larga + (dimensioniRighe.first - 1) * distanza;
    return FilaAlzata(
      larghezza: larga,
      distanza: distanza,
      testa: testa,
      perRiga: perRiga,
      righeDichiarate: righe,
      carte: carte,
      zona: Rect.fromLTWH(
          (w - largaDellaZona) / 2, cima, largaDellaZona, altaTutta),
    );
  }

  /// Una riga sola, centrata: fino a [carteInUnaRiga] carte.
  static FilaAlzata _unaRiga(int n, double w, double centro) {
    const margine = 16.0;
    const distanza = distanzaFraLeCarte;
    final larga =
        math.min((w - 2 * margine - (n - 1) * distanza) / n, w * 0.42);
    final alta = larga / kAspettoDellaCarta;
    final testa = testaPer(larga);
    final totale = n * larga + (n - 1) * distanza;
    final sinistra = (w - totale) / 2;
    final cima = centro - alta / 2;
    return FilaAlzata(
      larghezza: larga,
      distanza: distanza,
      testa: testa,
      carte: [
        for (var i = 0; i < n; i++)
          Rect.fromLTWH(sinistra + i * (larga + distanza), cima, larga, alta),
      ],
      zona: Rect.fromLTWH(sinistra, cima, totale, alta),
    );
  }

  /// Quattro posti a croce: due sull'asse verticale, uno a sinistra e uno a
  /// destra dell'asse.
  static bool eUnaCroce(List<PostoSulTavolo> posti) =>
      posti.length == 4 &&
      posti.where((p) => p.x == 0 && p.y != 0).length == 2 &&
      posti.where((p) => p.x < 0 && p.y == 0).length == 1 &&
      posti.where((p) => p.x > 0 && p.y == 0).length == 1;

  /// **LA CROCE IN PIEDI.** Tre colonne, le carte piu' grandi che ci
  /// stanno: in alto e in basso sulla colonna di mezzo, a sinistra e a
  /// destra a meta' altezza fra le due. Fra la carta in alto e quella in
  /// basso la scritta della prima e la testa della seconda.
  static FilaAlzata _aCroce(
      List<PostoSulTavolo> posti, double w, double centro) {
    const margine = 16.0;
    const distanza = distanzaFraLeCarte;
    final larga = (w - 2 * margine - 2 * distanza) / 3;
    final alta = larga / kAspettoDellaCarta;
    final testa = testaPer(larga);
    final passo = alta + sottoLaCartaInUnaRiga + testa;
    final altaTutta = alta + passo;
    final totale = 3 * larga + 2 * distanza;
    final sinistra = (w - totale) / 2;
    final cima = centro - altaTutta / 2;
    Rect posto(PostoSulTavolo p) {
      final colonna = p.x < 0 ? 0 : (p.x > 0 ? 2 : 1);
      final y = p.x != 0 ? cima + passo / 2 : (p.y < 0 ? cima : cima + passo);
      return Rect.fromLTWH(
          sinistra + colonna * (larga + distanza), y, larga, alta);
    }

    return FilaAlzata(
      larghezza: larga,
      distanza: distanza,
      testa: testa,
      carte: [for (final p in posti) posto(p)],
      zona: Rect.fromLTWH(sinistra, cima, totale, altaTutta),
    );
  }
}

/// Una carta posata sul tavolo: coperta, o girata a meta', o scoperta; la
/// chiave con la sua luce sul velluto.
class _CartaSulTavolo extends StatelessWidget {
  const _CartaSulTavolo({
    required this.carta,
    required this.girata,
    required this.luce,
    required this.diTraverso,
    required this.palette,
    this.faccia,
  });

  final DrawnCard carta;
  final Widget Function(DrawnCard carta)? faccia;
  final double girata;
  final bool luce;
  final bool diTraverso;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final g = girata.clamp(0.0, 1.0);
    final scoperta = g >= 0.5;
    final angolo = scoperta ? math.pi * (g - 1) : math.pi * g;
    Widget faccia = scoperta
        ? this.faccia?.call(carta) ??
            TarotCardArt(
              card: carta.card,
              palette: palette,
              reversed: carta.reversed,
              showCartigli: false,
            )
        : CardBack(palette: palette);
    faccia = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(angolo),
      child: faccia,
    );
    if (diTraverso) {
      faccia = Transform.rotate(angle: math.pi / 2, child: faccia);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // LA LUCE DA SOTTO, sul velluto intorno alla carta chiave.
        if (luce && scoperta)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 1.7,
                child: DecoratedBox(
                  key: const Key('tavolo_luce_della_chiave'),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        palette.goldSoft.withValues(alpha: 0.75),
                        palette.gold.withValues(alpha: 0.25),
                        palette.gold.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(child: faccia),
      ],
    );
  }
}
