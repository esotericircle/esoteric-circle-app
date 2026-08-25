/// LA STRISCIA "SCOPRI ALTRE ARTI DEL CERCHIO", UN PUNTO SOLO.
///
/// Viveva dentro il dominio, e Mauro la vuole ANCHE in fondo alla home:
/// portarla fuori invece di copiarla e' l'unica strada che non apre la
/// ventesima occorrenza della famiglia delle due porte. Ordine 2161, voce 4.
/// Legge dal catalogo delle arti, l'unico elenco: il criterio sta su
/// [artiDaScoprire], come dato e non come lista scritta a mano.
library;

import '../../../core/tempo/confine_del_giorno.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/arts/art_catalog.dart';
import '../../../core/arts/arti_preferite.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/components/section_title.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../art_navigation.dart';
import '../maestro_screen.dart' show CircleArtTile;

/// Di chi e' un'arte, dal catalogo.
Maestro maestroDellArte(ArtEntry a) {
  for (final m in Maestro.values) {
    if (ArtCatalog.activeOf(m).any((x) => x.id == a.id)) return m;
  }
  return Maestro.medora;
}

/// IL CRITERIO DELLA STRISCIA, come dato e non come lista scritta a mano.
///
/// **Perche' la lista e' sparita.** `_curatedArts` era una seconda fonte di
/// verita' accanto a `ArtCatalog`, e le due erano gia' divergenti: "Respiro
/// guidato" non esisteva nel catalogo, "Oracolo del Giorno" e "Runa del
/// Tramonto" non erano id del catalogo, e la Sinastria VIP apriva una schermata
/// dal catalogo e un'altra dalla striscia. Due elenchi che descrivono le stesse
/// arti divergono sempre: il secondo non viene aggiornato quando cambia il
/// primo, perche' nessuno si ricorda che esiste.
///
/// Adesso la striscia LEGGE IL CATALOGO e applica queste regole, che sono il
/// criterio e non un elenco:
/// - solo arti attive, mai quelle in arrivo;
/// - mai arti del Maestro il cui dominio si sta guardando;
/// - mai due voci sulla stessa rotta, che sarebbero due nomi per la stessa
///   schermata;
/// - mai arti gia' presenti nello scaffale personale;
/// - al massimo una per Maestro;
/// - ordine che ruota col giorno, cosi' la striscia non e' sempre uguale.
List<ArtEntry> artiDaScoprire(
  Maestro? corrente, {
  required Set<String> gia,
  required DateTime giorno,
}) {
  // **IN HOME LA FILA E' IL COMPLEMENTO PURO, ordine AK voce 02.** Sotto
  // "Le arti preferite" stanno TUTTE le arti attive del catalogo che non
  // sono nello scaffale della persona, nell'ordine del catalogo: un'arte
  // non compare mai in due posti della stessa schermata, e se la persona
  // cambia le preferite la fila mostra il resto da sola. Il tetto di una
  // per Maestro e la rotazione col giorno restano la regola del DOMINIO,
  // dove la fila e' una vetrina e non l'inventario.
  if (corrente == null) {
    final rotteViste = <String>{};
    final complemento = <ArtEntry>[];
    for (final m in Maestro.values) {
      for (final a in ArtCatalog.activeOf(m)) {
        if (gia.contains(a.id)) continue;
        if (!rotteViste.add(a.id)) continue;
        complemento.add(a);
      }
    }
    return complemento;
  }
  final altri = Maestro.values.where((m) => m != corrente).toList();
  // La rotazione col giorno: da quale Maestro si comincia.
  // ORDINE BL: si conta dalla porta unica, e la BASE resta il 2026. Si
  // cambia il modo di contare, mai il numero di partenza: spostare
  // l'origine vorrebbe dire spostare rotazioni gia' viste dalle persone.
  final salto =
      ConfineDelGiorno.giorniDa(DateTime(2026), giorno) % altri.length;
  final ordinati = [
    ...altri.sublist(salto),
    ...altri.sublist(0, salto),
  ];

  final rotteViste = <String>{};
  final fuori = <ArtEntry>[];
  for (final m in ordinati) {
    final vive = ArtCatalog.activeOf(m).where((a) => !gia.contains(a.id));
    for (final a in vive) {
      // Due voci sulla stessa rotta sono due nomi per la stessa schermata, che
      // e' la bugia da cui e' nata questa voce: Meditazione e Respiro guidato
      // erano la stessa cosa con due nomi e due icone.
      final rotta = rottaDiProva(a.id);
      if (rotta == null || !rotteViste.add(rotta)) continue;
      fuori.add(a);
      break; // al massimo una per Maestro
    }
  }
  return fuori;
}

/// L'identita' della rotta di un'arte, per non mettere due voci sullo stesso
/// posto.
///
/// In esercizio si usa l'id: costruire il widget della rotta per confrontarne
/// il tipo funziona in prova e non qui, perche' alcune rotte leggono il
/// contesto nel proprio builder e un contesto finto le fa cadere. I doppioni
/// veri, cioe' due id che aprono la STESSA schermata, li smaschera una prova
/// che le costruisce in un albero vero.
String? rottaDiProva(String id) => artRouteFor(id) == null ? null : id;



/// La striscia orizzontale "Scopri altre arti del Cerchio": le arti degli altri
/// Maestri, ciascuna tessera nel COLORE del Maestro a cui l'arte appartiene,
/// cosi' si vede da subito di chi e'. Scorre in orizzontale, con un accenno di
/// contenuto oltre il bordo.
class StrisciaAltreArti extends StatelessWidget {
  const StrisciaAltreArti({super.key, this.corrente});

  /// Il Maestro il cui dominio si sta guardando. NULLO IN HOME: la home non
  /// esclude nessun Maestro, esclude solo cio' che sta gia' nello scaffale
  /// delle tue arti, e la differenza di regola e' dichiarata qui perche' e'
  /// una differenza di luogo, non di criterio.
  final Maestro? corrente;

  @override
  Widget build(BuildContext context) {
    final gia = context.watch<ArtiPreferiteController?>()?.ids.toSet() ??
        const <String>{};
    final arts =
        artiDaScoprire(corrente, gia: gia, giorno: DateTime.now());
    // **A FILA VUOTA LA SEZIONE SPARISCE INTERA, senza lasciare aria**:
    // ordine AK voce 02. Un titolo sopra il niente sarebbe una promessa.
    if (arts.isEmpty) return const SizedBox.shrink();

    return Column(
      key: const Key('other_arts_strip'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          // In home il titolo e' quello dettato da Mauro (ordine AK voce
          // 02) e la fila e' l'inventario del resto; nel dominio resta
          // l'invito a scoprire di sempre.
          child: corrente == null
              ? const SectionTitle(
                  title: 'Le altre arti del Cerchio',
                  subtitle: 'Quelle che non hai messo fra le preferite.',
                )
              : const SectionTitle(
                  title: 'Scopri altre arti del Cerchio',
                  subtitle: 'Le arti degli altri Maestri, oltre il tuo dominio.',
                ),
        ),
        const SizedBox(height: SpacingTokens.md),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            itemCount: arts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: SpacingTokens.sm),
            itemBuilder: (context, i) => CircleArtTile(
              art: arts[i],
              maestro: maestroDellArte(arts[i]),
              // Il colore del Maestro di quell'arte, non un neutro.
              palette:
                  MaestroPalette.forKey(ThemeKey.of(maestroDellArte(arts[i]))),
            ),
          ),
        ),
      ],
    );
  }
}

