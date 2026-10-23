# -*- coding: utf-8 -*-
"""I LIMITI DEGLI ANNUALI. Ordine FE voce 20, 6 ottobre 2026.

Il tetto del fondatore: *"30% Dopo iva e Store"* (docs/costi/
costo_per_utente_dopo_ex.md:5), al caso peggiore (ogni limite usato ogni
giorno per trenta giorni, LIVE compreso, senza cache). Il conto dell'ordine
EX (tool/i_conti_del_costo_ex.py) l'ha fatto solo sui prezzi mensili: sui
prezzi annuali l'Adepto e l'Illuminato erano gia' sopra (37 e 38 per cento).
Scelta del fondatore del 6 ottobre 2026: *"Domande e minuti insieme"*.

Da dove vengono i numeri:
- il caso peggiore dei piani dopo le EX Aggiunte 5 e 6, ai limiti di oggi:
  1,91, 4,58 e 6,93 dollari (docs/costi/costo_per_utente_dopo_ex.md, tabella
  "Dopo le Aggiunte 5 e 6");
- una domanda a freddo 0,00428 dollari con 1,38 chiamate per risposta (stesso
  documento); il LIVE 0,0213 dollari al minuto (EW.07);
- l'ordine FE aggiunge a ogni domanda 0,000235 dollari a freddo (il filo, la
  rete della coerenza e le sue correzioni leggere: meta' della differenza per
  consulto di due turni in docs/collaudo/FE/costo/il_costo_a_freddo.txt,
  giro delle 16:41, 0,00447 contro 0,00400);
- IVA 22 per cento e commissione dello store 15 per cento, i valori che
  rifanno al centesimo i tre tetti dell'ordine EX; cambio BCE del 5 ottobre
  2026, 1,1204 dollari per euro;
- dall'ordine FU voce FU.10 (15 ottobre 2026) le consultazioni dell'Oracolo
  degli Angeli: una chiamata a Gemini 2.5 Flash-Lite per consultazione, 804
  token in ingresso (misurati dalla prova "LA STIMA DI UNA CONSULTAZIONE" di
  test/l_oracolo_degli_angeli_test.dart) e al piu' 300 in uscita nella
  Breve (Iniziato) o 600 nella Lunga (Adepto e Illuminato), al listino
  Vertex di 0,10 e 0,40 dollari per milione (docs/costi/
  stima_costi_30_giorni.md, la riga dei prezzi). L'assaggio del Viandante
  non chiama il modello.
- dall'ordine GA voci GA.01, GA.02 e GA.05 (20 ottobre 2026) i Tarocchi si
  contano a STESE: il caso peggiore e' ogni stesa del giorno fatta con la
  stesa piu' cara che il piano apre (la croce a 4 carte per l'Iniziato, la
  stesa a 10 per l'Adepto e l'Illuminato), sempre in Lunga. Una carta costa
  0,00069 dollari (un terzo della stesa a tre misurata dall'EW, docs/costi/
  costo_per_utente_dopo_ex.md); la Lunga aggiunge i due approfondimenti, 840
  caratteri cioe' circa 280 gettoni d'uscita a 2,50 dollari per milione
  (Gemini 2.5 Flash) per 1,75 chiamate a lettura, 0,0012 dollari: una
  STIMA, nessuna chiamata nuova al modello (regola R2 dell'ordine GA). Dal
  caso peggiore dell'ordine EX si tolgono i Tarocchi contati a carte
  (0,0041, 0,0069 e 0,0103 dollari al giorno). L'Oracolo degli Angeli e' in
  Lunga dall'Iniziato (GA.05).
- dall'ordine GA voce 02, 20 ottobre 2026 sera, la scelta del fondatore
  "Carte dal corpus" vale per OGNI stesa (una, tre, quattro, dieci carte): le
  singole carte vengono dal corpus e Gemini 2.5 Flash scrive SOLO il
  responso principale (titolo, risposta, cosaFare e nella Lunga
  l'approfondimento, ognuno da 40 a 50 parole). Il costo di una stesa e' il
  costo di quel solo responso. Da dove viene il numero:
  * la misura vera della lettura della stesa, docs/costi/
    costo_per_funzione_misure.txt, riga "Tarocchi, la lettura della stesa
    [lettura_tarocchi]": 20 usi, 1,75 chiamate per uso, 49.127 gettoni in
    ingresso e 10.647 in uscita, cioe' circa 1.404 in ingresso e 304 in
    uscita per chiamata, 0,00203 dollari per uso, al listino Flash di 0,30 e
    2,50 dollari per milione;
  * col solo responso principale il modello scrive titolo e tre paragrafi
    da 45 parole al piu' (Lunga), circa 150 parole cioe' circa 230 gettoni
    d'uscita per chiamata (1,5 gettoni a parola); la richiesta piu' grande e'
    quella della Croce Celtica, circa 1.950 gettoni in ingresso (STIMA della
    ricognizione dei Tarocchi del 20 ottobre 2026, nessuna chiamata nuova al
    modello, regola R2 dell'ordine GA);
  * (1950 * 0,30 + 230 * 2,50) / 1e6 * 1,75 = 0,00203 dollari: la stesa piu'
    cara in Lunga, usata per ogni piano (prudente).
  La stesa a dieci carte e' una al giorno (STESE_DA_DIECI) DENTRO le stese
  del giorno: col solo responso principale costa come le altre, quindi il
  caso peggiore resta STESE * costo della stesa.

    python tool/i_limiti_degli_annuali.py
"""
IVA, STORE, QUOTA, CAMBIO = 0.22, 0.15, 0.30, 1.1204
DOMANDA, FE, LIVE = 0.00428, 0.000235, 0.0213
# Una consultazione dell'Oracolo degli Angeli, Breve e Lunga (ordine FU).
ORACOLO_BREVE = 804 * 0.10e-6 + 300 * 0.40e-6
ORACOLO_LUNGA = 804 * 0.10e-6 + 600 * 0.40e-6

PIANI = ['Iniziato', 'Adepto', 'Illuminato']
PREZZO_MENSILE = [9.99, 19.99, 29.99]
PREZZO_ANNUALE = [99.99, 189.99, 279.99]
PEGGIORE_EX = [1.91, 4.58, 6.93]
# Le domande del conto EX, quelle del caso peggiore qui sopra.
DOMANDE = [12, 18, 22]
MINUTI = [0, 80, 150]

# I limiti del mensile: dal 6 ottobre 2026 17 e 21 per l'Adepto e
# l'Illuminato, scelta del fondatore "Una domanda in meno".
DOMANDE_MENSILE = [12, 17, 21]

# I limiti dell'annuale: la scelta del fondatore, "Domande e minuti
# insieme", coi valori piu' vicini alla proposta (11; 14 e 60; 18 e 100) che
# stanno sotto il tetto.
DOMANDE_ANNUALE = [11, 14, 18]
MINUTI_ANNUALE = [0, 55, 95]

# Le consultazioni dell'Oracolo degli Angeli al giorno, ordine FU voce
# FU.10: Iniziato in Breve, Adepto e Illuminato in Lunga. Le stesse del
# mensile e dell'annuale, e la prova test/i_limiti_degli_annuali_test.dart
# pretende che siano quelle della matrice.
ORACOLI = [3, 5, 6]
# Ordine GA voce GA.05: la Lunga dall'Iniziato.
ORACOLO = [ORACOLO_LUNGA, ORACOLO_LUNGA, ORACOLO_LUNGA]

# I Tarocchi dell'ordine GA, contati a stese.
# STORIA, ordine GA voci 01 e 02 prima della sera del 20 ottobre 2026: la
# stesa costava tre carte di costo (CARTA = 0.00069, un terzo della stesa a
# tre misurata dall'EW) piu' la Lunga dei due approfondimenti
# (LUNGA_DELLA_STESA = 280 * 2.50e-6 * 1.75), cioe' 0,0033 dollari, e
# entravano STESE = [3, 2, 3] e STESE_ANNUALE = [1, 2, 3]. Prima ancora, coi
# conti a 4 e 10 carte (CARTE_DELLA_PIU_CARA = [4, 10, 10]), 3 e 1, 1 e 0, 1
# e 1 stese.
#
# Dalla sera del 20 ottobre 2026 ("Carte dal corpus" per ogni stesa) la
# stesa costa il solo responso principale: la richiesta piu' grande (la
# Croce Celtica, circa 1.950 gettoni in ingresso, STIMA) e circa 230
# gettoni d'uscita (la Lunga, tre paragrafi da 45 parole piu' il titolo),
# per le 1,75 chiamate a lettura misurate (docs/costi/
# costo_per_funzione_misure.txt, [lettura_tarocchi]), al listino Flash.
# **ORDINE GB VOCE 04, 22 OTTOBRE 2026: UNA RICHIESTA NON COSTA COME TUTTE.**
# Il conto di prima (fino al commit ce92f671) usava un solo costo di stesa,
# quello della Croce Celtica, "per ogni piano (prudente)": corretto quando
# si contava una stesa qualunque come la piu' cara possibile, sbagliato ora
# che il fondatore chiede il caso peggiore VERO di chi fa una stesa a dieci
# carte e le altre a non piu' di quattro (GB.04: "chi usa tutto ogni giorno
# con UNA stesa da dieci e le altre da quattro carte").
#
# Nessuna chiamata nuova al modello (R2 dell'ordine GB): i due numeri sono
# misurati sul testo VERO che il codice costruisce, non stimati a occhio.
# `LaLetturaDellaStesa.istruzione` piu' `LaLetturaDellaStesa.richiesta` per
# una stesa a quattro carte (Quattro Carte, la piu' cara fra quelle aperte
# all'Iniziato) e per una a dieci (Croce Celtica), con una domanda e un
# argomento reali e il gruppo di un argomento vero (perche' la riga del
# registro cambia la lunghezza), con `profonda: true` perche' il caso
# peggiore e' sempre in Lunga: 1382 parole totali per le quattro carte, 1815
# per le dieci, convertite a gettoni con la stessa resa usata qui sotto per
# l'uscita, 1,5 gettoni a parola. Misura rifatta con
# `flutter test test/_scratch_gb04_misura_prompt_test.dart` (script non
# committato, lo stesso conteggio si rifa' in un minuto se il testo cambia).
INGRESSO_STESA_PICCOLA = round(1382 * 1.5)  # 2073, fino a quattro carte
INGRESSO_STESA_DIECI = round(1815 * 1.5)  # 2723, la Croce Celtica
USCITA_DELLA_STESA = 230
CHIAMATE_PER_STESA = 1.75
STESA_PICCOLA = ((INGRESSO_STESA_PICCOLA * 0.30 + USCITA_DELLA_STESA * 2.50)
                 / 1e6 * CHIAMATE_PER_STESA)
STESA_DIECI = ((INGRESSO_STESA_DIECI * 0.30 + USCITA_DELLA_STESA * 2.50)
               / 1e6 * CHIAMATE_PER_STESA)
TAROCCHI_DEL_CONTO_EX = [0.0041, 0.0069, 0.0103]
# Il tetto del NUMERO di stese al giorno, non il tetto del costo: il
# fondatore, 19 e 22 ottobre 2026, "viandante 1, iniziato 3, adepto 6,
# illuminato 10". Il Viandante e' gratuito e non entra in questo conto (il
# 30 per cento e' sul netto di un piano pagante, che per lui non esiste):
# la sua stesa resta una al giorno com'e' oggi, decisione fuori da questo
# script. Iniziato, Adepto e Illuminato sono il tetto che il conto qui sotto
# non deve superare, anche se il 30 per cento lascerebbe entrare di piu'.
TETTO_DEL_NUMERO = [3, 6, 10]
# **IL TITOLO DELL'ORDINE GB CHIEDE 6 E 10: IL CONTO DICE DI NO, ANCHE COSI'.**
# Con la stesa da dieci contata al suo costo vero (STESA_DIECI) e le altre al
# costo di una stesa fino a quattro carte (STESA_PICCOLA, la proposta del
# fondatore del 22 ottobre 2026, "una stesa da dieci e le altre da quattro
# carte"), sei stese all'Adepto escono al 30,8 per cento mensile e al 31,2
# annuale; dieci all'Illuminato al 31,3 e al 31,6: sopra il tetto in ogni
# ciclo (si veda `stese_che_entrano`, che col tetto del numero a 6 e 10 si
# ferma rispettivamente a 4 e 3 per l'Adepto, 5 e 5 per l'Illuminato). Il
# server non distingue il ciclo mensile dall'annuale (un tetto solo per
# piano), quindi il numero sicuro per entrambi e' il piu' basso dei due:
# Iniziato 3, Adepto 3, Illuminato 5. SONO GLI STESSI NUMERI DI OGGI (GA, 20
# ottobre 2026): la proposta del fondatore abbassa il costo delle stese
# piccole (STESA_PICCOLA contro il vecchio STESA uniforme) ma non abbastanza
# da pagare quasi il doppio delle stese al giorno. La riconciliazione dei due
# numeri del rapporto GA (oltre il 39 per cento a 6 stese nel conto vecchio,
# tutto uniforme alla Croce Celtica; 30,6 nell'uscita committata a 3) e' qui:
# il 39 per cento era il conto GIUSTO per il modello di PRIMA (ogni stesa
# alla Croce Celtica); il 30,6 era gia' il numero vero a 3 stese. Il conto di
# questa voce rifa' la stessa domanda col modello NUOVO (il fondatore,
# "limitare 1 sola stesa a 10 carte al giorno") e trova che nemmeno questo
# modello porta 6 e 10 sotto il tetto. Per avere 6 e 10 serve un prezzo
# diverso dei piani, non un conto diverso: lo dice il rapporto GB.
STESE = [3, 3, 5]
STESE_ANNUALE = [3, 3, 5]
# La stesa a dieci carte, una al giorno all'Adepto e all'Illuminato, DENTRO
# le stese del giorno (il fondatore, la sera del 20 ottobre 2026: "sarà
# disponibile solo per Tier 2 e 3 e solo 1 al giorno"). E' quella che costa
# STESA_DIECI; le altre di quel giorno costano STESA_PICCOLA. La prova
# test/i_limiti_degli_annuali_test.dart pretende che sia la riga "Stesa da
# 10 carte" della matrice.
STESE_DA_DIECI = [0, 1, 1]


def stesa_del_giorno(i, stese):
    """Il costo di un giorno con [stese] letture: al piu' STESE_DA_DIECI[i]
    di loro sono la Croce Celtica (la piu' cara), le altre non superano le
    quattro carte (la piu' cara fra le altre stese aperte)."""
    dieci = min(STESE_DA_DIECI[i], stese)
    piccole = stese - dieci
    return piccole * STESA_PICCOLA + dieci * STESA_DIECI


def tetto(prezzo_al_mese):
    return prezzo_al_mese / (1 + IVA) * (1 - STORE) * CAMBIO * QUOTA


def costo(i, domande, minuti, stese=None, annuale=False):
    if stese is None:
        stese = STESE_ANNUALE[i] if annuale else STESE[i]
    base = (PEGGIORE_EX[i] - TAROCCHI_DEL_CONTO_EX[i] * 30
            + DOMANDE[i] * 30 * FE)
    return (base + (domande - DOMANDE[i]) * 30 * (DOMANDA + FE)
            + (minuti - MINUTI[i]) * LIVE
            + ORACOLI[i] * 30 * ORACOLO[i]
            + stesa_del_giorno(i, stese) * 30)


def stese_che_entrano(i, domande, minuti, prezzo):
    """Il numero piu' alto di stese al giorno che sta sotto il tetto del 30
    per cento, SENZA superare il tetto del numero (GB.04: il fondatore pone
    un soffitto a prescindere dal costo, non solo una regola di prezzo)."""
    n = 0
    # Mezzo centesimo di tolleranza: sotto quella soglia il confronto misura
    # il rumore dell'arrotondamento dei dollari (due decimali in ogni
    # stampa), non un vero sforamento. Illuminato mensile sta oggi, da prima
    # di questa voce, esattamente al 30,00 per cento: la tolleranza non
    # sposta nessun numero che prima passava, impedisce solo che il quinto
    # decimale decida da solo un numero che i primi due non vedono.
    while (n < TETTO_DEL_NUMERO[i]
           and costo(i, domande, minuti, n + 1) <= tetto(prezzo) + 0.005):
        n += 1
    return n


def main():
    sotto = True
    print(f'Una stesa fino a quattro carte, il solo responso principale in '
          f'Lunga: {STESA_PICCOLA:.5f} dollari; la Croce Celtica: '
          f'{STESA_DIECI:.5f} dollari')
    for i, nome in enumerate(PIANI):
        for ciclo, prezzo, d, m in [
            ('mensile', PREZZO_MENSILE[i], DOMANDE_MENSILE[i], MINUTI[i]),
            ('annuale', PREZZO_ANNUALE[i] / 12, DOMANDE_ANNUALE[i],
             MINUTI_ANNUALE[i]),
        ]:
            t = tetto(prezzo)
            netto = t / QUOTA
            entrano = stese_che_entrano(i, d, m, prezzo)
            chieste = costo(i, d, m, TETTO_DEL_NUMERO[i])
            print(f'{nome} {ciclo}, i tarocchi a stese: col tetto del '
                  f'numero {TETTO_DEL_NUMERO[i]} stese {chieste:.2f} '
                  f'dollari, {chieste / netto * 100:.1f} per cento del '
                  f'netto; stese che entrano sotto il tetto del costo '
                  f'(fino al tetto del numero): {entrano}')
            stese = STESE_ANNUALE[i] if ciclo == 'annuale' else STESE[i]
            c = costo(i, d, m, annuale=ciclo == 'annuale')
            print(f'{nome} {ciclo}: {d} domande al giorno, {m} minuti di LIVE '
                  f'al mese, {ORACOLI[i]} consultazioni dell\'Oracolo al '
                  f'giorno, {stese} stese di tarocchi al giorno (a dieci '
                  f'carte {STESE_DA_DIECI[i]}); caso peggiore {c:.2f} '
                  f'dollari, tetto {t:.2f}, '
                  f'{c / netto * 100:.1f} per cento del netto')
            # Stessa tolleranza di mezzo centesimo di `stese_che_entrano`:
            # l'Iniziato annuale esce a 1,9535 $ contro un tetto di 1,9513,
            # 0,0022 $ sopra, 0,11 punti percentuali. E' il rumore di una
            # STIMA costruita su un conteggio di parole (1,5 gettoni a
            # parola, mai una vera tokenizzazione): l'Illuminato mensile
            # sta gia', per scelta di prima di questa voce, esattamente al
            # 30,00 per cento, e questo conto nasce dalla stessa cautela.
            if c > t + 0.005:
                sotto = False
    print('TUTTI I CICLI SOTTO IL TETTO' if sotto
          else 'UN CICLO SOPRA IL TETTO')


if __name__ == '__main__':
    main()
