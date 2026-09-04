# -*- coding: utf-8 -*-
"""CQ2.13: le tre pretese del congedo misurano la scena."""
NL = chr(10)
CR = chr(13)
P = 'test/il_gradino_aspetta_il_congedo_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:70])
    s = s.replace(vecchio, nuovo)


cambia("""  test('a strada libera matura uno solo, e il posto si occupa', () async {
    final d = await diarioPulito();
    expect(d.laStradaELibera, isTrue,
        reason: 'un Cammino appena nato ha il posto gia occupato');

    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    expect(primi.length, 1,
        reason: 'con uno stato che soddisfa molti gradini ne maturano '
            '${primi.length} insieme: la prima regola del fondatore dice che '
            'non se ne puo raggiungere piu di uno alla volta');
    await d.accendi(primi.first.id);
    expect(d.inAttesaDiCongedo, primi.first.id,
        reason: 'il gradino acceso non ha occupato il posto del congedo');
    expect(d.laStradaELibera, isFalse);
  });""",
       """  test('a strada libera UNA SOLA scena, e il posto si occupa', () async {
    final d = await diarioPulito();
    expect(d.laStradaELibera, isTrue,
        reason: 'un Cammino appena nato ha il posto gia occupato');

    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    // **MATURANO TUTTI. Ordine CQ voce 2.13**: il tetto non tocca
    // l'accensione. Cio' che resta uno solo e' la scena.
    final conLaScena = primi.where(d.meritaLaScena).toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: con lo stato generoso maturano '
        '${primi.length} gradini, e di scene ne meritano ${conLaScena.length}');
    expect(primi.length, greaterThan(1),
        reason: 'con uno stato che soddisfa quasi tutto il corpus ne maturano '
            '${primi.length}: il tetto e tornato sulla maturazione, ed e il '
            'muro che la voce CQ 2.12 ha misurato');
    expect(conLaScena.length, 1,
        reason: 'a strada libera le scene sono ${conLaScena.length}: la prima '
            'regola del fondatore dice che non se ne vede piu di una alla '
            'volta');
    await d.accendi(conLaScena.first.id);
    expect(d.inAttesaDiCongedo, conLaScena.first.id,
        reason: 'il gradino acceso non ha occupato il posto del congedo');
    expect(d.laStradaELibera, isFalse);
  });""")

cambia("""    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);

    // **OTTO GIRI, che sono le otto feste viste dal fondatore.** Ogni giro
    // rappresenta un gesto in piu': prima ognuno drenava un gradino
    // dall'arretrato dei soddisfatti, e otto gesti facevano otto feste.
    var maturati = 0;
    for (var i = 0; i < 8; i++) {
      maturati += (await d.quelliCheSiAccendono(statoGeneroso())).length;
    }
    expect(maturati, 0,
        reason: 'col gradino precedente ancora da congedare ne sono maturati '
            'altri $maturati: sono $maturati feste in piu, ed e esattamente '
            'cio che il fondatore ha visto sul telefono');
  });""",
       """    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);

    // **OTTO GIRI, che sono le otto feste viste dal fondatore.** Ogni giro
    // rappresenta un gesto in piu'. **Si contano le SCENE**, ordine CQ voce
    // 2.13: le accensioni non si frenano piu', e frenarle era il muro che la
    // voce 2.12 ha misurato.
    var scene = 0;
    for (var i = 0; i < 8; i++) {
      scene += (await d.quelliCheSiAccendono(statoGeneroso()))
          .where(d.meritaLaScena)
          .length;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: col posto occupato, otto gesti portano '
        '$scene scene');
    expect(scene, 0,
        reason: 'col gradino precedente ancora da congedare si sono viste '
            'altre $scene feste, ed e esattamente cio che il fondatore ha '
            'visto sul telefono');
  });""")

cambia("""    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    await d.accendi(primi.first.id);
    await d.congeda(primi.first.id);
    expect(d.laStradaELibera, isTrue,
        reason: 'il congedo non ha liberato il posto: il Cammino resterebbe '
            'fermo per sempre');
    final dopo = await d.quelliCheSiAccendono(statoGeneroso());
    expect(dopo.length, 1,
        reason: 'congedato il precedente non matura piu niente: il freno e '
            'diventato un muro');
    expect(dopo.first.id, isNot(primi.first.id));
  });""",
       """    final primi = await d.quelliCheSiAccendono(statoGeneroso());
    final primaScena = primi.firstWhere(d.meritaLaScena);
    await d.accendi(primaScena.id);
    // La scena e' stata mostrata: e' cosi' che il tetto del giorno la conta.
    d.laScenaEStataMostrata(primaScena);
    await d.congeda(primaScena.id);
    expect(d.laStradaELibera, isTrue,
        reason: 'il congedo non ha liberato il posto: il Cammino resterebbe '
            'fermo per sempre');
    final dopo = await d.quelliCheSiAccendono(statoGeneroso());
    final scenaDopo = dopo.where(d.meritaLaScena).toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.13: congedata la prima scena, i gradini maturi '
        'sono ${dopo.length} e le scene ${scenaDopo.length}');
    expect(dopo, isNotEmpty,
        reason: 'congedato il precedente non matura piu niente: il freno e '
            'diventato un muro');
    // **E LA SCENA VA A UN ALTRO SENTIERO**, perche' quello di prima ha gia'
    // avuto la sua per oggi: e' il tetto di tre al giorno, uno per Maestro.
    expect(scenaDopo.length, 1,
        reason: 'dopo il congedo le scene sono ${scenaDopo.length}: il tetto '
            'di una per sentiero al giorno non tiene');
    expect(scenaDopo.first.id, isNot(primaScena.id));
  });""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('tre pretese riscritte')
