# -*- coding: utf-8 -*-
"""CQ2.13: la guardia del congedo passa dalla maturazione alla scena."""
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


cambia("""/// **IL GRADINO NON MATURA FINCHÉ IL PRECEDENTE NON È STATO CONGEDATO.**
/// Ordine CP voce 01, 3 settembre 2026.""",
       """/// **LA SCENA NON ARRIVA FINCHÉ LA PRECEDENTE NON È STATA CONGEDATA.**
/// Ordine CP voce 01 del 3 settembre 2026, **spostata dalla maturazione alla
/// scena dall'ordine CQ voce 2.13 dello stesso giorno.**
///
/// **Perché si è spostata, e il numero lo dice.** Il freno stava sulla
/// maturazione, e la misura della voce CQ 2.12 ha detto quanto costava: su
/// quattrocento giorni di uso onesto con dodici arti al giorno, **centododici
/// traguardi soddisfatti e TREDICI accesi**, con novantanove gradini già
/// guadagnati che non si accendevano mai. Non era un ritardo, era un muro.
///
/// Parole del fondatore: *il tetto delle feste non deve mai toccare
/// l'accensione del Sigillo né l'accredito degli Eos, solo la scena della
/// festa.* Quindi adesso maturano tutti, si accendono tutti e i loro Eos
/// arrivano tutti; **ciò che resta uno alla volta è la scena**, e questa
/// guardia la misura lì.""")

cambia("""/// **Un posto solo in tutto il Cammino, non uno per sentiero.** La prima
/// regola del fondatore, del 17 agosto 2026, dice *"non deve esserci la
/// possibilita' di raggiungere piu' di un traguardo alla volta"*, e non dice
/// "più di uno per sentiero": con un posto per sentiero un gesto che tocca tre
/// arti ne farebbe maturare tre insieme, che è esattamente ciò che la regola
/// vieta.""",
       """/// **Un posto solo per la scena, e un tetto di tre al giorno.** La prima
/// regola del fondatore, del 17 agosto 2026, dice *"non deve esserci la
/// possibilita' di raggiungere piu' di un traguardo alla volta"*: letta sulla
/// scena, vuol dire che non se ne vede più di una per volta, e che ogni
/// sentiero ne mostra al massimo una al giorno. Il conto del giorno peggiore
/// dell'anno resta quello che il fondatore ha approvato con l'ordine CP,
/// **tre**, ed è misurato in
/// `aprire_e_chiudere_non_e_un_cammino_test.dart`.""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('intestazione riscritta')
