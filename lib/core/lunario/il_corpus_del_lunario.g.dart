// GENERATO da tool/il_corpus_del_lunario.py dalla fonte in
// docs/corpus/lunario/. Non si modifica a mano: si corregge la
// fonte e si rigenera. Ordine FV voci FV.06 e FV.07.

import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';
import 'la_regola_del_lunario.dart';
import 'le_attivita_del_lunario.dart';

/// Le fonti del corpus lunare, per id (docs/corpus/lunario/fonti.md).
const Map<String, FonteDelLunario> fontiDelLunario = {
  'barbanera_bellezza': FonteDelLunario(
    id: 'barbanera_bellezza',
    citazione:
        'Lunario di Barbanera, voce "la cura della persona secondo la Luna"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione della bellezza',
    letta: '2026-10-15',
    dice:
        'la depilazione si fa tradizionalmente in luna calante, perché il pelo ricresca più lento; i trattamenti di bellezza si fanno in luna crescente',
  ),
  'barbanera_capelli': FonteDelLunario(
    id: 'barbanera_capelli',
    citazione:
        'Lunario di Barbanera, almanacco popolare italiano stampato dal 1762 a oggi, voce "taglio dei capelli e delle unghie"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione dei consigli lunari del mese',
    letta: '2026-10-15',
    dice:
        'tradizione contadina italiana: i capelli tagliati in luna crescente crescono più in fretta, quelli tagliati in luna calante crescono più robusti; le unghie si tagliano in luna calante perché ricrescano più lente',
  ),
  'barbanera_casa': FonteDelLunario(
    id: 'barbanera_casa',
    citazione:
        'Lunario di Barbanera, voce "le faccende di casa secondo la Luna"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione dei lavori domestici',
    letta: '2026-10-15',
    dice:
        'pulizie e bucato, che tolgono lo sporco, si fanno tradizionalmente in luna calante; traslochi e lavori in casa, che cominciano qualcosa, in luna crescente',
  ),
  'barbanera_conserve': FonteDelLunario(
    id: 'barbanera_conserve',
    citazione:
        'Lunario di Barbanera, voce "la cucina e la cantina secondo la Luna"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione delle conserve e del pane',
    letta: '2026-10-15',
    dice:
        'le conserve, che devono durare, si preparano in luna calante; il pane e i lievitati, che devono crescere, si impastano in luna crescente',
  ),
  'barbanera_orto_fasi': FonteDelLunario(
    id: 'barbanera_orto_fasi',
    citazione:
        'Lunario di Barbanera, voce "lavori dell\'orto e del giardino secondo la Luna"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione dei lavori agricoli',
    letta: '2026-10-15',
    dice:
        'la potatura si fa tradizionalmente in luna calante, quando la linfa scende e la pianta perde meno succhi dal taglio; il raccolto da conservare si fa preferibilmente alla Luna piena',
  ),
  'barbanera_pesca': FonteDelLunario(
    id: 'barbanera_pesca',
    citazione: 'Lunario di Barbanera, voce "la pesca secondo la Luna"',
    indirizzo:
        'edizione corrente del Lunario Barbanera, sezione della pesca e della caccia',
    letta: '2026-10-15',
    dice:
        'la tradizione contadina e dei pescatori indica la luna crescente come la fase in cui il pesce abbocca più facilmente',
  ),
  'barbanera_vino': FonteDelLunario(
    id: 'barbanera_vino',
    citazione:
        'Lunario di Barbanera, voce "il vino e la cantina secondo la Luna"',
    indirizzo: 'edizione corrente del Lunario Barbanera, sezione della cantina',
    letta: '2026-10-15',
    dice:
        'travasi e imbottigliamento si fanno tradizionalmente in luna calante, perché il vino resti limpido e non si intorbidisca',
  ),
  'chiave_di_medora': FonteDelLunario(
    id: 'chiave_di_medora',
    citazione:
        'chiave di lettura propria di Medora, non una tradizione documentata',
    indirizzo:
        'nessuno: si dichiara qui perché il corpus non la confonda con una fonte vera',
    letta: '2026-10-15',
    dice:
        'il modo in cui più regole insieme fanno un giorno d\'oro, insieme a ogni altra lettura che non viene da una fonte citabile, è dichiarato come chiave di Medora e non come tradizione',
  ),
  'elettiva_amore': FonteDelLunario(
    id: 'elettiva_amore',
    citazione:
        'tradizione dell\'astrologia elettiva classica sui segni di Venere e della Luna per le questioni di cuore',
    indirizzo:
        'Coley, "Clavis Astrologiae" (1676), sezione delle elezioni per il matrimonio e l\'amicizia',
    letta: '2026-10-15',
    dice:
        'i segni dove Venere è di casa o esaltata (Toro, Bilancia, Pesci) e il segno dove la Luna è di casa (Cancro) sono tradizionalmente indicati per le questioni di cuore',
  ),
  'elettiva_segni_viaggio': FonteDelLunario(
    id: 'elettiva_segni_viaggio',
    citazione:
        'tradizione dell\'astrologia elettiva classica sui segni mobili e fissi, raccolta nei manuali successivi a Lilly (per esempio Henry Coley, "Clavis Astrologiae", 1676)',
    indirizzo:
        'Coley, "Clavis Astrologiae" (1676), sezione delle elezioni per i viaggi',
    letta: '2026-10-15',
    dice:
        'i segni mobili (Gemelli, Vergine, Sagittario, Pesci), legati per tradizione al movimento, sono favorevoli per i viaggi; i segni fissi (Toro, Leone, Scorpione, Acquario), legati alla stabilità, sono tradizionalmente meno indicati, soprattutto con la Luna calante',
  ),
  'lilly_elettiva': FonteDelLunario(
    id: 'lilly_elettiva',
    citazione:
        'William Lilly, "Christian Astrology" (1647), libro I, capitoli sulle elezioni e sulla Luna fuori corso',
    indirizzo: 'edizione moderna Regulus (ristampa facsimile), libro I',
    letta: '2026-10-15',
    dice:
        'l\'astrologia elettiva classica indica la Luna crescente e non fuori corso come la condizione generale favorevole per cominciare un\'impresa, mettersi in viaggio o aprire una questione di cuore; la Luna fuori corso è la condizione classica da evitare per le stesse materie',
  ),
  'pitre_nozze_calante': FonteDelLunario(
    id: 'pitre_nozze_calante',
    citazione:
        'Giuseppe Pitrè, "Biblioteca delle tradizioni popolari siciliane" (raccolta pubblicata fra il 1871 e il 1913), voci sulle credenze popolari legate al matrimonio',
    indirizzo: 'Pitrè, volumi dedicati agli usi nuziali e alle credenze lunari',
    letta: '2026-10-15',
    dice:
        'la tradizione popolare italiana raccolta da Pitrè sconsiglia di sposarsi in luna calante, ritenuta di cattivo augurio per un\'unione che deve crescere',
  ),
  'thun_biodinamico': FonteDelLunario(
    id: 'thun_biodinamico',
    citazione:
        'Maria Thun, calendario delle semine biodinamico (Aussaattage), metodo pubblicato annualmente dal 1963',
    indirizzo:
        'Bross-Burkhardt, "Saatkalender und Mondkalender, kritisch betrachtet" (2011), descrizione del metodo dei quattro giorni',
    letta: '2026-10-15',
    dice:
        'il passaggio della Luna davanti alle costellazioni di terra, acqua, aria e fuoco apre quattro tipi di giorno (radice, foglia, fiore, frutto), ciascuno propizio al lavoro sulla parte corrispondente della pianta',
  ),
};

/// Le regole del corpus lunare (docs/corpus/lunario/regole.md).
const List<RegolaDelLunario> regoleDelLunario = [
  RegolaDelLunario(
    id: 'taglio_capelli_crescenti',
    attivita: [AttivitaDelLunario.tagliPerCrescere],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_capelli'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'taglio_capelli_rinforzo',
    attivita: [AttivitaDelLunario.tagliPerRinforzare],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_capelli'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'taglio_unghie_calante',
    attivita: [AttivitaDelLunario.unghie],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_capelli'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'semina_radice',
    attivita: [AttivitaDelLunario.semina],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.radice]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno radice, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'semina_frutto',
    attivita: [AttivitaDelLunario.semina],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.frutto]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno frutto, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'trapianto_radice',
    attivita: [AttivitaDelLunario.trapianto],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.radice]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno radice, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'trapianto_foglia',
    attivita: [AttivitaDelLunario.trapianto],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.foglia]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno foglia, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'potatura_calante',
    attivita: [AttivitaDelLunario.potatura],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_orto_fasi'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'raccolto_radice',
    attivita: [AttivitaDelLunario.raccolto],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.radice]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno radice, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'raccolto_frutto',
    attivita: [AttivitaDelLunario.raccolto],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.frutto]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno frutto, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'raccolto_piena',
    attivita: [AttivitaDelLunario.raccolto],
    quando: CondizioneDelLunario(fasi: [FaseLunare.piena]),
    peso: 1,
    toglieLOro: false,
    fonti: ['barbanera_orto_fasi'],
    detto: 'Luna piena',
  ),
  RegolaDelLunario(
    id: 'rinvasi_foglia',
    attivita: [AttivitaDelLunario.rinvasi],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.foglia]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno foglia, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'talee_foglia',
    attivita: [AttivitaDelLunario.talee],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.foglia]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno foglia, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'fiori_fiore',
    attivita: [AttivitaDelLunario.fiori],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.fiore]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno fiore, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'appartamento_foglia',
    attivita: [AttivitaDelLunario.pianteDaAppartamento],
    quando: CondizioneDelLunario(tipi: [TipoBiodinamico.foglia]),
    peso: 2,
    toglieLOro: false,
    fonti: ['thun_biodinamico'],
    detto: 'giorno foglia, nel metodo di Maria Thun',
  ),
  RegolaDelLunario(
    id: 'pulizie_calante',
    attivita: [AttivitaDelLunario.pulizie],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_casa'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'bucato_calante',
    attivita: [AttivitaDelLunario.bucato],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_casa'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'traslochi_crescente',
    attivita: [AttivitaDelLunario.traslochi],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_casa'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'lavori_crescente',
    attivita: [AttivitaDelLunario.lavori],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_casa'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'conserve_calante',
    attivita: [AttivitaDelLunario.conserve],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_conserve'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'pane_crescente',
    attivita: [AttivitaDelLunario.pane],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_conserve'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'travasi_calante',
    attivita: [AttivitaDelLunario.travasi],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_vino'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'imbottigliamento_calante',
    attivita: [AttivitaDelLunario.imbottigliamento],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_vino'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'depilazione_calante',
    attivita: [AttivitaDelLunario.depilazione],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_bellezza'],
    detto: 'Luna calante',
  ),
  RegolaDelLunario(
    id: 'trattamenti_crescente',
    attivita: [AttivitaDelLunario.trattamenti],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_bellezza'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'pesca_crescente',
    attivita: [AttivitaDelLunario.pesca],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['barbanera_pesca'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'inizi_crescente',
    attivita: [AttivitaDelLunario.inizi],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['lilly_elettiva'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'inizi_fuoricorso',
    attivita: [AttivitaDelLunario.inizi],
    quando: CondizioneDelLunario(fuoriCorso: true),
    peso: 0,
    toglieLOro: true,
    fonti: ['lilly_elettiva'],
    detto: 'Luna fuori corso',
  ),
  RegolaDelLunario(
    id: 'viaggi_crescente',
    attivita: [AttivitaDelLunario.viaggi],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['lilly_elettiva'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'viaggi_segni_mobili',
    attivita: [AttivitaDelLunario.viaggi],
    quando: CondizioneDelLunario(segni: [
      Zodiac.gemini,
      Zodiac.virgo,
      Zodiac.sagittarius,
      Zodiac.pisces
    ]),
    peso: 2,
    toglieLOro: false,
    fonti: ['elettiva_segni_viaggio'],
    detto: 'in un segno mobile',
  ),
  RegolaDelLunario(
    id: 'viaggi_fuoricorso',
    attivita: [AttivitaDelLunario.viaggi],
    quando: CondizioneDelLunario(fuoriCorso: true),
    peso: 0,
    toglieLOro: true,
    fonti: ['lilly_elettiva'],
    detto: 'Luna fuori corso',
  ),
  RegolaDelLunario(
    id: 'viaggi_segni_fissi_calante',
    attivita: [AttivitaDelLunario.viaggi],
    quando: CondizioneDelLunario(
        luce: LuceDellaLuna.calante,
        segni: [Zodiac.taurus, Zodiac.leo, Zodiac.scorpio, Zodiac.aquarius]),
    peso: -2,
    toglieLOro: false,
    fonti: ['elettiva_segni_viaggio'],
    detto: 'Luna calante in un segno fisso',
  ),
  RegolaDelLunario(
    id: 'amore_crescente',
    attivita: [
      AttivitaDelLunario.primoAppuntamento,
      AttivitaDelLunario.dichiarazione,
      AttivitaDelLunario.nozze
    ],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.crescente),
    peso: 2,
    toglieLOro: false,
    fonti: ['lilly_elettiva'],
    detto: 'Luna crescente',
  ),
  RegolaDelLunario(
    id: 'amore_segni_venere',
    attivita: [
      AttivitaDelLunario.primoAppuntamento,
      AttivitaDelLunario.dichiarazione,
      AttivitaDelLunario.nozze
    ],
    quando: CondizioneDelLunario(
        segni: [Zodiac.taurus, Zodiac.cancer, Zodiac.libra, Zodiac.pisces]),
    peso: 2,
    toglieLOro: false,
    fonti: ['elettiva_amore'],
    detto: 'in un segno legato a Venere o alla Luna',
  ),
  RegolaDelLunario(
    id: 'amore_fuoricorso',
    attivita: [
      AttivitaDelLunario.primoAppuntamento,
      AttivitaDelLunario.dichiarazione,
      AttivitaDelLunario.nozze
    ],
    quando: CondizioneDelLunario(fuoriCorso: true),
    peso: 0,
    toglieLOro: true,
    fonti: ['lilly_elettiva'],
    detto: 'Luna fuori corso',
  ),
  RegolaDelLunario(
    id: 'nozze_calante_sconsigliata',
    attivita: [AttivitaDelLunario.nozze],
    quando: CondizioneDelLunario(luce: LuceDellaLuna.calante),
    peso: -3,
    toglieLOro: false,
    fonti: ['pitre_nozze_calante'],
    detto: 'Luna calante',
  ),
];

/// I testi del corpus lunare non legati a una regola, chiave
/// "sezione.chiave" (docs/corpus/lunario/testi.md).
const Map<String, String> testiDelLunario = {
  'giorni_tuoi.fase_di_nascita':
      'Oggi la Luna torna alla stessa fase di luce che c\'era quando hai cominciato il tuo cammino. È un giorno simbolico di nuovo inizio, un cerchio che si chiude e un altro che si apre: nessun calcolo, solo un richiamo del tuo punto di partenza.',
  'giorni_tuoi.luna_nel_segno':
      'Oggi la Luna attraversa il tuo segno solare: il cielo del giorno si accorda con il tuo modo di essere. Le cose che fai oggi ti somigliano un poco di più: vale la pena notarlo.',
  'giorni_tuoi.luna_sul_sole':
      'Oggi la Luna passa sul grado del tuo Sole di nascita: la tua volontà e il tuo sentire si parlano da vicino. È un giorno in cui quello che vuoi e quello che senti vanno nella stessa direzione, buono per le scelte che contano.',
  'giorni_tuoi.ritorno_lunare':
      'Oggi la Luna torna al grado esatto della tua nascita. Il modo in cui senti le cose, quello di partenza, oggi torna a farsi sentire con chiarezza: è un giorno buono per ascoltare quello che provi, senza il bisogno di agire subito.',
};
