import 'il_giorno_lunare.dart';

/// **LE UNDICI CATEGORIE E LE LORO ATTIVITA'**, ordine FV voce FV.06, 15
/// ottobre 2026. Il fondatore, sulla lista dell'Architetto: "Approvo".
/// L'ordine dell'elenco e' l'ordine della fila degli emblemi sopra il mese.
enum CategoriaDelLunario {
  capelli('Capelli e unghie', 'emb_capelli'),
  orto('Orto', 'emb_orto'),
  piante('Piante e giardino', 'emb_piante'),
  casa('Casa', 'emb_casa'),
  conserve('Cucina e conserve', 'emb_conserve'),
  vino('Vino e cantina', 'emb_vino'),
  bellezza('Bellezza', 'emb_bellezza'),
  pesca('Pesca', 'emb_pesca'),
  inizi('Inizi e firme', 'emb_inizi'),
  viaggi('Viaggi', 'emb_viaggi'),
  amore('Amore', 'emb_amore');

  const CategoriaDelLunario(this.nome, this.emblemaBase);
  final String nome;
  final String emblemaBase;

  /// L'emblema dipinto della categoria (P2 dell'ordine FV).
  String get emblema => 'assets/img/calendario_lunare/${emblemaBase}_v1.webp';

  /// Vero per le categorie in cui il calendario mostra il tipo di giorno
  /// biodinamico sotto la Luna (FV.05).
  bool get mostraIlBiodinamico =>
      this == CategoriaDelLunario.orto || this == CategoriaDelLunario.piante;

  /// Le attivita' della categoria, nell'ordine dell'ordine FV.
  List<AttivitaDelLunario> get attivita =>
      AttivitaDelLunario.values.where((a) => a.categoria == this).toList();
}

/// Le attivita' di ogni categoria (FV.06). Pesca, Inizi e firme e Viaggi
/// hanno un'attivita' sola, col nome della categoria.
enum AttivitaDelLunario {
  tagliPerCrescere(CategoriaDelLunario.capelli, 'Taglio per farli crescere'),
  tagliPerRinforzare(CategoriaDelLunario.capelli, 'Taglio per rinforzarli'),
  unghie(CategoriaDelLunario.capelli, 'Taglio delle unghie'),
  semina(CategoriaDelLunario.orto, 'Semina'),
  trapianto(CategoriaDelLunario.orto, 'Trapianto'),
  potatura(CategoriaDelLunario.orto, 'Potatura'),
  raccolto(CategoriaDelLunario.orto, 'Raccolto'),
  rinvasi(CategoriaDelLunario.piante, 'Rinvasi'),
  talee(CategoriaDelLunario.piante, 'Talee'),
  fiori(CategoriaDelLunario.piante, 'Fiori'),
  pianteDaAppartamento(CategoriaDelLunario.piante, 'Piante da appartamento'),
  pulizie(CategoriaDelLunario.casa, 'Pulizie'),
  bucato(CategoriaDelLunario.casa, 'Bucato e macchie'),
  traslochi(CategoriaDelLunario.casa, 'Traslochi'),
  lavori(CategoriaDelLunario.casa, 'Lavori'),
  conserve(CategoriaDelLunario.conserve, 'Conserve'),
  pane(CategoriaDelLunario.conserve, 'Pane e lievitati'),
  travasi(CategoriaDelLunario.vino, 'Travasi'),
  imbottigliamento(CategoriaDelLunario.vino, 'Imbottigliamento'),
  depilazione(CategoriaDelLunario.bellezza, 'Depilazione'),
  trattamenti(CategoriaDelLunario.bellezza, 'Trattamenti'),
  pesca(CategoriaDelLunario.pesca, 'Pesca'),
  inizi(CategoriaDelLunario.inizi, 'Inizi e firme'),
  viaggi(CategoriaDelLunario.viaggi, 'Viaggi'),
  primoAppuntamento(CategoriaDelLunario.amore, 'Primo appuntamento'),
  dichiarazione(CategoriaDelLunario.amore, 'Dichiarazione'),
  nozze(CategoriaDelLunario.amore, 'Nozze');

  const AttivitaDelLunario(this.categoria, this.nome);
  final CategoriaDelLunario categoria;
  final String nome;
}

/// Il verdetto di un giorno per un'attivita'.
enum GradoDelGiorno {
  /// Si accende d'oro.
  oro,

  /// Resta com'e'.
  neutro,

  /// Si spegne in opacita'.
  evitare,
}

/// **L'ESITO DI UN GIORNO PER UN'ATTIVITA'**: il grado e il perche' in
/// chiaro, una riga per fattore ("Luna crescente", "in Leone", "fuori corso
/// solo dalle 3 alle 5"), e le fonti delle regole che hanno deciso.
class EsitoDelGiorno {
  const EsitoDelGiorno({
    required this.grado,
    required this.perche,
    required this.fonti,
  });

  final GradoDelGiorno grado;

  /// Il perche' in chiaro, per la persona.
  final List<String> perche;

  /// Le fonti delle regole che hanno deciso (gli id del corpus delle regole).
  final List<String> fonti;
}

/// **LA PORTA DELLE REGOLE**: dato un giorno e un'attivita', l'esito. La
/// riempie il corpus delle regole lunari (`LeRegoleDelLunario`); la schermata
/// la chiede soltanto.
typedef ValutaIlGiorno = EsitoDelGiorno Function(
    AttivitaDelLunario attivita, GiornoLunare giorno);
