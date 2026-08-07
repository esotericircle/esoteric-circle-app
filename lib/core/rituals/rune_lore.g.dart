// GENERATO da tool/genera_rune_lore.py, NON scrivere a mano.
// Fonte: docs/corpus/rune.md. Il filtro delle parole vietate
// vive nel generatore: questo file esiste solo se il corpus
// e' pulito.

/// Una strofa di un poema runico, con fonte e traduzione nostra.
class StrofaRunica {
  const StrofaRunica(this.fonte, this.originale, this.traduzione);
  final String fonte;
  final String originale;
  final String traduzione;
}

/// La materia attestata di una runa, con le sue strofe.
class RuneLore {
  const RuneLore({
    required this.profilo,
    required this.materia,
    required this.strofe,
    this.notaNorrena,
  });
  final String profilo;
  final String materia;
  final List<StrofaRunica> strofe;

  /// Perche' la strofa norrena non c'e', quando non c'e':
  /// runa perduta dal Futhark recente, oppure continuita'
  /// contesa. Nullo quando il trittico e' completo.
  final String? notaNorrena;
}

const Map<String, RuneLore> kRuneLore = {
  'Fehu': RuneLore(
    profilo: '*fehu*, protogermanico. **Forme attestate**: *feoh* (anglosassone), *fé* (norreno). **Lettera**: F. **Suono**: /f/.',
    materia: 'il bestiame, i beni mobili. Fonte: i tre poemi runici, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Feoh byþ frofur fira gehwylcum; sceal ðeah manna gehwylc miclun hyt dælan gif he wile for drihtne domes hleotan.', 'Il bene è conforto per ogni uomo; ma ognuno deve dispensarlo con larghezza, se vuole ottenere onore davanti al signore.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Fé er frænda róg ok flæðar viti ok grafseiðs gata.', 'Il bene è discordia fra parenti, fuoco della marea, via del serpente che scava.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Fé vældr frænda róge; føðesk ulfr í skóge.', 'Il bene genera discordia fra parenti; il lupo cresce nel bosco.'),
    ],
  ),
  'Uruz': RuneLore(
    profilo: '*uruz*. **Forme attestate**: *ur* (anglosassone), *úr* (norreno). **Lettera**: U. **Suono**: /u/.',
    materia: 'l\'uro, il bue selvatico (poema anglosassone). I poemi norreni leggono *úr* come pioviggine o scoria di ferro: la divergenza è antica e si dichiara.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Ur byþ anmod ond oferhyrned, felafrecne deor, feohteþ mid hornum, mære morstapa; þæt is modig wuht.', 'L\'uro è fiero e d\'alte corna, bestia ardita, combatte con le corna, celebre camminatore di brughiere: creatura di coraggio.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Úr er skýja grátr ok skára þverrir ok hirðis hatr.', 'La pioggia è pianto delle nubi, rovina del fieno, odio del pastore.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Úr er af illu jarne; opt løypr ræinn á hjarne.', 'La scoria viene dal cattivo ferro; spesso la renna corre sulla neve gelata.'),
    ],
  ),
  'Thurisaz': RuneLore(
    profilo: '*thurisaz*, il gigante. **Forme attestate**: *ðorn* (anglosassone, la spina), *þurs* (norreno, il gigante). **Lettera**: TH. **Suono**: /θ/.',
    materia: 'la spina (poema anglosassone), il gigante (poemi norreni). Due volti antichi della stessa runa, dichiarati.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Ðorn byþ ðearle scearp; ðegna gehwylcum anfeng ys yfyl, ungemetum reþe manna gehwelcum ðe him mid resteð.', 'La spina è acutissima; afferrarla fa male a ogni guerriero, crudele senza misura con chiunque vi riposi in mezzo.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Þurs er kvenna kvöl ok kletta búi ok varðrúnar verr.', 'Il gigante è tormento delle donne, abitatore di rupi, sposo della gigantessa.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Þurs vældr kvinna kvillu; kátr værðr fár af illu.', 'Il gigante porta pena alle donne; pochi si rallegrano del male.'),
    ],
  ),
  'Ansuz': RuneLore(
    profilo: '*ansuz*, il dio. **Forme attestate**: *os* (anglosassone, la bocca), *óss* (norreno, il dio, Odino). **Lettera**: A. **Suono**: /a/.',
    materia: 'la bocca, la parola (poema anglosassone); il dio delle origini (poema islandese). Divergenza antica, dichiarata.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Os byþ ordfruma ælcre spræce, wisdomes wraþu ond witena frofur and eorla gehwam eadnys ond tohiht.', 'La bocca è origine di ogni discorso, sostegno della saggezza, conforto dei savi, serenità e fiducia per ogni nobile.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Óss er algingautr ok ásgarðs jöfurr ok valhallar vísi.', 'Il dio è l\'antico creatore, principe di Asgard, signore della Valhalla.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Óss er flæstra færða för; en skalpr er sværða.', 'La foce è la via di quasi ogni viaggio; come il fodero lo è delle spade.'),
    ],
  ),
  'Raidho': RuneLore(
    profilo: '*raidho*, la cavalcata. **Forme attestate**: *rad* (anglosassone), *reið* (norreno). **Lettera**: R. **Suono**: /r/.',
    materia: 'il viaggio a cavallo, la via. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Rad byþ on recyde rinca gehwylcum sefte ond swiþhwæt ðamðe sitteþ on ufan meare mægenheardum ofer milpaþas.', 'La cavalcata, in casa, sembra dolce a ogni guerriero; ed è dura per chi sta in sella a un forte cavallo lungo le vie delle miglia.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Reið er sitjandi sæla ok snúðig ferð ok jórs erfiði.', 'La cavalcata è gioia di chi siede, viaggio rapido, fatica del cavallo.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Ræið kveða rossom væsta; Reginn sló sværðet bæzta.', 'La cavalcata, dicono, è la peggiore per i cavalli; Regin forgiò la spada migliore.'),
    ],
  ),
  'Kenaz': RuneLore(
    profilo: '*kenaz*, la torcia. **Forme attestate**: *cen* (anglosassone, la torcia), *kaun* (norreno, la piaga). **Lettera**: K. **Suono**: /k/.',
    materia: 'la torcia, il fuoco domestico (poema anglosassone). I poemi norreni leggono *kaun* come piaga: la divergenza è antica e si dichiara.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Cen byþ cwicera gehwam, cuþ on fyre, blac ond beorhtlic, byrneþ oftust ðær hi æþelingas inne restaþ.', 'La torcia è nota a ogni vivente per la fiamma, pallida e lucente: arde più spesso dove i nobili riposano.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Kaun er barna böl ok bardaga för ok holdfúa hús.', 'La piaga è sventura dei bambini, traccia di battaglia, casa del disfacimento.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Kaun er barna bölvan; böl gørver nán fölvan.', 'La piaga è la sventura dei bambini; la sventura fa pallido l\'uomo.'),
    ],
  ),
  'Gebo': RuneLore(
    profilo: '*gebo*, il dono. **Forma attestata**: *gyfu* (anglosassone). **Lettera**: G. **Suono**: /g/.',
    materia: 'il dono, lo scambio. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Gyfu gumena byþ gleng and herenys, wraþu and wyrþscype, and wræcna gehwam ar and ætwist, ðe byþ oþra leas.', 'Il dono è per gli uomini ornamento e lode, sostegno e onore; e per l\'esule che non ha altro, soccorso e sostanza.'),
    ],
    notaNorrena: 'NON ESISTE. Il Futhark recente aveva perso questa runa, i poemi norreni non la conoscono: qui non si inventa niente.',
  ),
  'Wunjo': RuneLore(
    profilo: '*wunjo*, la gioia. **Forma attestata**: *wynn* (anglosassone). **Lettera**: W. **Suono**: /w/.',
    materia: 'la gioia, l\'assenza di affanno. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Wenne bruceþ ðe can weana lyt, sares and sorge, and him sylfa hæfþ blæd and blysse and eac byrga geniht.', 'Gode della gioia chi conosce pochi affanni, pene e dolori, avendo per sé vigore e letizia e anche l\'abbondanza delle città.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
  'Hagalaz': RuneLore(
    profilo: '*hagalaz*, la grandine. **Forme attestate**: *hægl* (anglosassone), *hagall* (norreno). **Lettera**: H. **Suono**: /h/.',
    materia: 'la grandine, il chicco freddo che diventa acqua. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Hægl byþ hwitust corna; hwyrft hit of heofones lyfte, wealcaþ hit windes scura; weorþeþ hit to wætere syððan.', 'La grandine è il più bianco dei chicchi; scende dall\'aria del cielo, la rotolano le raffiche del vento; poi diventa acqua.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Hagall er kaldakorn ok krapadrífa ok snáka sótt.', 'La grandine è chicco freddo, nevischio che turbina, sventura dei serpenti.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Hagall er kaldastr korna; Kristr skóp hæimenn forna.', 'La grandine è il più freddo dei chicchi; Cristo creò il mondo antico.'),
    ],
  ),
  'Nauthiz': RuneLore(
    profilo: '*naudhiz*, il bisogno. **Forme attestate**: *nyd* (anglosassone), *nauð* (norreno). **Lettera**: N. **Suono**: /n/.',
    materia: 'il bisogno, la costrizione che insegna. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Nyd byþ nearu on breostan; weorþeþ hi þeah oft niþa bearnum to helpe and to hæle gehwæþre, gif hi his hlystaþ æror.', 'Il bisogno stringe il petto; eppure spesso diventa per i figli degli uomini aiuto e riscatto, se lo ascoltano per tempo.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Nauð er Þýjar þrá ok þungr kostr ok vássamlig verk.', 'Il bisogno è pena della serva, sorte gravosa, lavoro nell\'intemperie.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Nauðr gerer næppa koste; nøktan kælr í froste.', 'Il bisogno lascia scelte strette; chi è nudo gela nel freddo.'),
    ],
  ),
  'Isa': RuneLore(
    profilo: '*isa*, il ghiaccio. **Forme attestate**: *is* (anglosassone), *íss* (norreno). **Lettera**: I. **Suono**: /i/.',
    materia: 'il ghiaccio. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Is byþ ofereald, ungemetum slidor, glisnaþ glæshluttur gimmum gelicust, flor forste geworuht, fæger ansyne.', 'Il ghiaccio è freddissimo, scivoloso oltre misura; brilla chiaro come vetro, simile a gemme: un pavimento fatto dal gelo, bello a vedersi.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Íss er árbörkr ok unnar þak ok feigra manna fár.', 'Il ghiaccio è corteccia del fiume, tetto dell\'onda, insidia per chi è segnato.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Ís köllum brú bræiða; blindan þarf at læiða.', 'Il ghiaccio lo chiamiamo ponte largo; il cieco va guidato.'),
    ],
  ),
  'Jera': RuneLore(
    profilo: '*jera*, l\'anno, il raccolto. **Forme attestate**: *ger* (anglosassone), *ár* (norreno). **Lettera**: J o Y. **Suono**: /j/.',
    materia: 'l\'anno buono, il raccolto. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Ger byþ gumena hiht, ðonne God læteþ, halig heofones cyning, hrusan syllan beorhte bleda beornum ond ðearfum.', 'L\'anno buono è la speranza degli uomini, quando Dio, santo re del cielo, fa dare alla terra frutti splendenti per i nobili e per i poveri.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Ár er gumna góði ok gott sumar ok algróinn akr.', 'L\'anno buono è bene degli uomini, buona estate, campo cresciuto per intero.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Ár er gumna góðe; get ek at örr var Fróðe.', 'L\'anno buono è bene degli uomini; dico che Frodi fu generoso.'),
    ],
  ),
  'Eihwaz': RuneLore(
    profilo: '*eihwaz*, il tasso. **Forma attestata**: *eoh* (anglosassone). **Lettera**: EI. **Suono**: incerto, tra /e:/ e /i:/; l\'incertezza si dichiara.',
    materia: 'il tasso, l\'albero dalle radici profonde. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Eoh byþ utan unsmeþe treow, heard hrusan fæst, hyrde fyres, wyrtrumun underwreþyd, wyn on eþle.', 'Il tasso è albero ruvido di fuori, duro e saldo nella terra, custode del fuoco, puntellato dalle radici: una gioia sul suolo avito.'),
    ],
    notaNorrena: 'NON ATTRIBUITA. La runa recente *ýr* («Ýr er bendr bogi ok brotgjarnt járn ok fífu fárbauti», l\'arco teso, il ferro fragile, il gigante della freccia) porta un nome che richiama il tasso, ma la sua FORMA discende da Algiz: la continuità è contesa fra gli studiosi, quindi la strofa si cita e non si attribuisce.',
  ),
  'Perthro': RuneLore(
    profilo: '*perthro*, il cui SIGNIFICATO È DISCUSSO: bossolo dei dadi, gioco da tavola, o altro ancora. L\'incertezza è essa stessa il dato attestato; si dichiara. **Forma attestata**: *peorð* (anglosassone). **Lettera**: P. **Suono**: /p/.',
    materia: 'il gioco, la sorte nella sala dell\'idromele. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Peorð byþ symble plega and hlehter wlancum, ðar wigan sittaþ on beorsele bliþe ætsomne.', 'Peorð è sempre gioco e riso fra gli orgogliosi, dove i guerrieri siedono lieti insieme nella sala della birra.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
  'Algiz': RuneLore(
    profilo: '*algiz*, convenzione moderna dal nome anglosassone; il nome antico è incerto e si dichiara. **Forma attestata**: *eolhx-secg* (anglosassone, il carice d\'alce). **Lettera**: Z. **Suono**: /z/ finale.',
    materia: 'il carice, il giunco tagliente della palude. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Eolh-secg eard hæfþ oftust on fenne, wexeð on wature, wundaþ grimme, blode breneð beorna gehwylcne ðe him ænigne onfeng gedeþ.', 'Il carice d\'alce dimora per lo più nella palude, cresce nell\'acqua, ferisce a fondo, segna col sangue chiunque osi afferrarlo.'),
    ],
    notaNorrena: 'NON ATTRIBUITA. La runa recente *ýr* discende da questa nella FORMA ma non nel nome: la continuità è contesa, la strofa si cita sotto Eihwaz e non si attribuisce a nessuna delle due.',
  ),
  'Sowilo': RuneLore(
    profilo: '*sowilo*, il sole. **Forme attestate**: *sigel* (anglosassone), *sól* (norreno). **Lettera**: S. **Suono**: /s/.',
    materia: 'il sole, guida dei naviganti. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Sigel semannum symble biþ on hihte, ðonne hi hine feriaþ ofer fisces beþ, oþ hi brimhengest bringeþ to lande.', 'Il sole è sempre speranza per i naviganti, quando lo portano con sé sul bagno del pesce, finché il destriero del mare non li riporta a terra.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Sól er skýja skjöldr ok skínandi röðull ok ísa aldrtregi.', 'Il sole è scudo delle nubi, disco splendente, struggimento del ghiaccio.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Sól er landa ljóme; lúti ek helgum dóme.', 'Il sole è luce delle terre; io mi inchino al santo giudizio.'),
    ],
  ),
  'Tiwaz': RuneLore(
    profilo: '*tiwaz*, il dio Tyr. **Forme attestate**: *tir* (anglosassone, un segno celeste), *týr* (norreno, il dio). **Lettera**: T. **Suono**: /t/.',
    materia: 'il segno celeste che tiene la rotta (poema anglosassone); il dio dalla mano sola (poema islandese). Divergenza antica, dichiarata.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Tir biþ tacna sum, healdeð trywa wel wiþ æþelingas; a biþ on færylde ofer nihta genipu, næfre swiceþ.', 'Tir è uno dei segni: tiene bene fede ai nobili; sta sempre in cammino sopra le nebbie della notte, senza tradire mai.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Týr er einhendr áss ok ulfs leifar ok hofa hilmir.', 'Tyr è il dio dalla mano sola, ciò che il lupo ha lasciato, signore dei templi.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Týr er æinendr ása; opt værðr smiðr at blása.', 'Tyr è il dio con una mano sola; spesso il fabbro deve soffiare.'),
    ],
  ),
  'Berkano': RuneLore(
    profilo: '*berkano*, la betulla. **Forme attestate**: *beorc* (anglosassone), *bjarkan* (norreno). **Lettera**: B. **Suono**: /b/.',
    materia: 'la betulla, l\'albero che germoglia. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Beorc byþ bleda leas, bereþ efne swa ðeah tanas butan tudder, biþ on telgum wlitig, heah on helme hrysted fægere, geloden leafum, lyfte getenge.', 'La betulla è senza frutto, eppure porta rami senza seme; è splendida nei suoi rami, alta di chioma, adorna di belle foglie, vicina al cielo.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Bjarkan er laufgat lim ok lítit tré ok ungsamligr viðr.', 'La betulla è ramo frondoso, albero piccolo, legno giovane.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Bjarkan er laufgrønstr líma; Loki bar flærða tíma.', 'La betulla è il ramo più verde di foglie; Loki portò la fortuna dell\'inganno.'),
    ],
  ),
  'Ehwaz': RuneLore(
    profilo: '*ehwaz*, il cavallo. **Forma attestata**: *eh* (anglosassone). **Lettera**: E. **Suono**: /e/.',
    materia: 'il cavallo, compagno di viaggio. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Eh byþ for eorlum æþelinga wyn, hors hofum wlanc, ðær him hæleþ ymbe, welege on wicgum, wrixlaþ spræce, and biþ unstyllum æfre frofur.', 'Il cavallo è davanti ai nobili la gioia dei principi, destriero fiero di zoccoli; attorno a lui gli eroi ricchi di cavalli si scambiano parole; è sempre conforto per chi non trova quiete.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
  'Mannaz': RuneLore(
    profilo: '*mannaz*, l\'essere umano. **Forme attestate**: *man* (anglosassone), *maðr* (norreno). **Lettera**: M. **Suono**: /m/.',
    materia: 'l\'essere umano, caro ai suoi e mortale. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Man byþ on myrgþe his magan leof: sceal þeah anra gehwylc oðrum swican, forðum drihten wyle dome sine þæt earme flæsc eorþan betæcan.', 'L\'uomo nella gioia è caro ai suoi; eppure ognuno dovrà separarsi dall\'altro, perché il signore, per suo decreto, affida la povera carne alla terra.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Maðr er manns gaman ok moldar auki ok skipa skreytir.', 'L\'uomo è gioia dell\'uomo, accrescimento della terra, ornamento delle navi.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Maðr er moldar auki; mikil er græip á hauki.', 'L\'uomo è accrescimento della terra; grande è l\'artiglio del falco.'),
    ],
  ),
  'Laguz': RuneLore(
    profilo: '*laguz*, l\'acqua. **Forme attestate**: *lagu* (anglosassone), *lögr* (norreno). **Lettera**: L. **Suono**: /l/.',
    materia: 'l\'acqua, il mare che non si governa. Fonte: i tre poemi, concordi.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Lagu byþ leodum langsum geþuht, gif hi sculun neþan on nacan tealtum, and hi sæyþa swyþe bregaþ, and se brimhengest bridles ne gymeð.', 'L\'acqua sembra senza fine alle genti, se devono avventurarsi su una barca instabile, mentre le onde del mare li spaventano forte e il destriero del mare non ascolta la briglia.'),
      StrofaRunica('Old Icelandic Rune Poem', 'Lögr er vellanda vatn ok viðr ketill ok glömmungr grund.', 'L\'acqua è fiume che ribolle, ampia caldaia, terra dei pesci.'),
      StrofaRunica('Old Norwegian Rune Rhyme', 'Lögr er, er fællr ór fjalle foss; en gull ero nosser.', 'L\'acqua è la cascata che scende dal monte; e gli ori sono gioielli.'),
    ],
  ),
  'Ingwaz': RuneLore(
    profilo: '*ingwaz*, il dio Ing. **Forma attestata**: *Ing* (anglosassone). **Lettera**: NG. **Suono**: /ŋ/.',
    materia: 'Ing, l\'eroe divino visto per primo fra i Danesi orientali. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Ing wæs ærest mid East-Denum gesewen secgun, oþ he siððan est ofer wæg gewat; wæn æfter ran; ðus Heardingas ðone hæle nemdun.', 'Ing fu visto per primo dagli uomini fra i Danesi dell\'est, finché poi se ne andò verso oriente sopra l\'onda; il carro gli correva dietro; così gli Heardingas chiamarono quell\'eroe.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
  'Dagaz': RuneLore(
    profilo: '*dagaz*, il giorno. **Forma attestata**: *dæg* (anglosassone). **Lettera**: D. **Suono**: /d/.',
    materia: 'il giorno, la luce mandata a tutti. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Dæg byþ drihtnes sond, deore mannum, mære metodes leoht, myrgþ and tohiht eadgum and earmum, eallum brice.', 'Il giorno è messo del signore, caro agli uomini, luce splendente del creatore: letizia e fiducia per i fortunati e per i poveri, utile a tutti.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
  'Othala': RuneLore(
    profilo: '*othala*, la terra avita. **Forma attestata**: *eþel* (anglosassone). **Lettera**: O. **Suono**: /o/.',
    materia: 'la casa, la terra dei padri. Fonte: poema anglosassone.',
    strofe: [
      StrofaRunica('Old English Rune Poem', 'Eþel byþ oferleof æghwylcum men, gif he mot ðær rihtes and gerysena on brucan on bolde bleadum oftast.', 'La terra avita è cara oltremodo a ogni uomo, se nella sua casa può godere, nel giusto e nel decoro, di ciò che essa dà.'),
    ],
    notaNorrena: 'NON ESISTE. Runa perduta dal Futhark recente: nessuna strofa, nessuna invenzione.',
  ),
};
