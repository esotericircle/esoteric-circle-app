# LE PERLE DEL LOTO: UGUALI E CENTRATE. Ordine AG voce 01.
#
# Le perle spente oggi sono pixel dell'arte e variano per raggio (da 20,0 a
# 37,0 contro la mediana di 27,9) e per posizione sul petalo (fino a 21 pixel
# dall'asse). Questo strumento chiude i due difetti PER COSTRUZIONE:
#
#   1. misura dall'arte l'asse di ogni petalo (componenti principali della
#      regione del petalo, presa per settore angolare attorno all'ancoraggio
#      e connessa alla corona della perla) e calcola il centro coerente, alla
#      STESSA frazione dell'asse per tutte, la mediana misurata;
#   2. toglie le perle dall'arte riempiendo dai pixel del petalo circostante
#      (inpainting di Telea), cosi' il codice potra' disegnarle uguali;
#   3. riscrive i pallini dei mini a RAGGIO UNICO, la mediana misurata, sui
#      centri coerenti; i cinque grandi non si toccano.
#
# Il sorgente docs/preview/journal_loto_nuovo-1.png NON si tocca mai: si parte
# dal derivato brand_assets/sentieri/loto.png e lo si riscrive, come da regola
# degli ordini AE e AF. Se su un petalo la stima dell'asse non converge, CI SI
# FERMA su quella perla e la si riporta con le coordinate, senza inventare.
import math
import pathlib
import re
import sys

import cv2
import numpy as np
from PIL import Image

RADICE = pathlib.Path(__file__).resolve().parent.parent
ARTE = RADICE / 'brand_assets/sentieri/loto.png'
PALLINI = RADICE / 'brand_assets/sentieri/loto_pallini.png'

# La meta' del settore di un petalo: dieci petali per fiore fanno 36 gradi
# l'uno, e si sta un poco dentro per non mordere i vicini.
MEZZO_SETTORE = 16.0
# La stima dell'asse converge se la regione e' davvero allungata: sotto
# questo rapporto fra gli assi la direzione non e' affidabile e ci si ferma.
ALLUNGAMENTO_MINIMO = 1.25
# Il margine del riempimento oltre il raggio misurato della perla. Misurato
# guardando: a 8 pixel l'orlo lucido delle perle piu' grosse spuntava ancora
# (la 47). L'ombra portata NON entra nella maschera: e' petalo scurito, e
# sotto la perla ridisegnata dal codice con la sua ombra si legge come
# ombra. Il tentativo di prenderla per colore (soglie di luminanza 55 e 190
# su un anello di 26) mangiava la trama scura dei petali e le scintille
# dell'oro e spalmava nebbia: guardato e buttato.
MARGINE_RIEMPIMENTO = 10


def ancoraggi_dal_dato():
    testo = (RADICE / 'lib/core/sigilli/ancoraggi_dei_sentieri.dart').read_text(
        encoding='utf-8')
    sezione = testo.split('Sentiero.loto: [')[1].split('],')[0]
    voci = re.findall(
        r'x: ([\d.]+), y: ([\d.]+), gruppo: (\d+), eGrande: (\w+)', sezione)
    return [(float(x), float(y), int(g), e == 'true') for x, y, g, e in voci]


def raggi_dal_dato():
    testo = (RADICE / 'lib/core/sigilli/forme_dei_sentieri.dart').read_text(
        encoding='utf-8')
    sezione = testo.split('Sentiero.loto: [')[1]
    aree = [int(a) for a in re.findall(r'area: (\d+)', sezione)][:55]
    return [math.sqrt(a / math.pi) for a in aree]


def main():
    im = np.array(Image.open(ARTE).convert('RGBA'))
    h, w = im.shape[:2]
    alpha = im[:, :, 3]
    opaco = alpha > 128
    anc = ancoraggi_dal_dato()
    raggi = raggi_dal_dato()
    pal = np.array(Image.open(PALLINI).convert('RGBA'))

    grandi = {g: (x * w, y * h) for x, y, g, e in anc if e}
    mini = [(i, x * w, y * h, g) for i, (x, y, g, e) in enumerate(anc) if not e]
    r_mini = [raggi[i] for i, *_ in mini]
    raggio_unico = round(float(np.median(r_mini)))
    print(f'raggi dei mini: min {min(r_mini):.1f} max {max(r_mini):.1f} '
          f'mediana {np.median(r_mini):.1f} -> RAGGIO UNICO {raggio_unico}')

    # La maschera di TUTTE le perle mini, per escluderle dalla regione del
    # petalo e per il riempimento.
    ys, xs = np.mgrid[0:h, 0:w]
    maschera_perle = np.zeros((h, w), bool)
    for k, (i, px, py, g) in enumerate(mini):
        d2 = (xs - px) ** 2 + (ys - py) ** 2
        maschera_perle |= d2 <= (raggi[i] + MARGINE_RIEMPIMENTO) ** 2

    # Il raggio dell'anello di ogni fiore: la mediana delle distanze delle sue
    # perle dal centro. Serve a dare un tetto alla punta del petalo, perche'
    # il passo lungo il raggio non cammini su un gambo che tocca la punta.
    anello = {}
    for g in grandi:
        anello[g] = float(np.median([
            math.hypot(px - grandi[g][0], py - grandi[g][1])
            for i, px, py, gg in mini if gg == g]))

    def regione_del_petalo(px, py, cxf, cyf, rp, g, mezzo_settore):
        # **IL SETTORE SI RICENTRA PER ITERAZIONE.** Alla prima passata
        # l'angolo e' quello della perla, che e' storto per definizione: e' il
        # difetto che si sta correggendo. Il baricentro della regione trovata
        # da' l'angolo del PETALO, e con due ricentrature la stima si posa.
        #
        # **NIENTE FILTRO SUL COLORE**: un filtro sul verde del petalo cadeva
        # sulla perla 40, il cui petalo e' bronzo scuro (117,78,34). La
        # regione e' l'opaco del settore, e l'oro del fiore che ci entra
        # pesa sul baricentro in dentro ma non di lato, che e' l'unico verso
        # che conti per l'angolo.
        theta = math.atan2(py - cyf, px - cxf)
        d_perla = math.hypot(px - cxf, py - cyf)
        stima = None
        for _ in range(3):
            # La punta lungo l'asse corrente: si cammina dalla perla in
            # fuori fino alla prima trasparenza, col tetto dell'anello (1,8
            # volte il suo raggio). **La punta e' la MEDIANA di undici
            # raggi** a cavallo dell'asse: un raggio solo proseguiva oltre il
            # petalo dove la punta tocca il fogliame dietro (perle 12, 19,
            # 22, 47 e 49, ballo fino a 55 pixel fra i settori), la mediana
            # non segue un contatto stretto.
            tetto = anello[g] * 1.8
            corse = []
            for decimi in range(-5, 6):
                th = theta + math.radians(decimi)
                corsa = d_perla
                passo = 0
                while d_perla + passo < tetto:
                    passo += 2
                    qx = int(cxf + (d_perla + passo) * math.cos(th))
                    qy = int(cyf + (d_perla + passo) * math.sin(th))
                    if not (0 <= qx < w and 0 <= qy < h) or not opaco[qy, qx]:
                        break
                    corsa = d_perla + passo
                corse.append(corsa)
            punta = float(np.median(corse))
            finestra = 300
            x0, x1 = max(0, int(px - finestra)), min(w, int(px + finestra))
            y0, y1 = max(0, int(py - finestra)), min(h, int(py + finestra))
            sy, sx = np.mgrid[y0:y1, x0:x1]
            dxs, dys = sx - cxf, sy - cyf
            dist = np.hypot(dxs, dys)
            ang = np.degrees(np.arctan2(dys, dxs) - theta)
            ang = (ang + 180) % 360 - 180
            m = (np.abs(ang) <= mezzo_settore) & (dist >= 0.5 * d_perla) &                 (dist <= punta + 6) & opaco[y0:y1, x0:x1] &                 ~maschera_perle[y0:y1, x0:x1]
            pxs, pys = sx[m].astype(float), sy[m].astype(float)
            if len(pxs) < 800:
                return None
            cx, cy = pxs.mean(), pys.mean()
            # **L'ASSE E' RADIALE, DALLA PUNTA**: la retta dal centro del
            # fiore alla punta del petalo esiste per ogni forma di petalo,
            # anche corto e largo, dove le componenti principali non
            # convergevano (perle 7, 40 e 49 su petali veri). Le componenti
            # principali restano come CONTROPROVA dove il petalo e' allungato.
            asse = (math.cos(theta), math.sin(theta))
            cov = np.cov(np.vstack([pxs - cx, pys - cy]))
            val, vec = np.linalg.eigh(cov)
            pca = vec[:, int(np.argmax(val))]
            allungamento = math.sqrt(max(val) / max(min(val), 1e-9))
            if pca[0] * asse[0] + pca[1] * asse[1] < 0:
                pca = -pca
            controprova = math.degrees(math.acos(max(-1.0, min(1.0,
                pca[0] * asse[0] + pca[1] * asse[1]))))
            # **LA FRAZIONE E' DELLA CORSA CENTRO-PUNTA.** La base di un
            # petalo non si osserva dall'alfa, perche' il petalo si fonde col
            # fiore senza trasparenza: la corsa dal centro del fiore alla
            # punta invece esiste, e la stessa frazione di quella corsa e' il
            # centro coerente.
            stima = {
                'asse': (float(asse[0]), float(asse[1])),
                'allungamento': allungamento, 'controprova': controprova,
                'cima': punta,
                'frazione': d_perla / punta,
            }
            # La ricentratura: l'angolo del petalo e' quello del baricentro.
            theta = math.atan2(cy - cyf, cx - cxf)
        return stima

    # PRIMA PASSATA: le frazioni correnti, e chi non converge si dichiara.
    # La convergenza si giudica sulla STABILITA': una stima che non produce
    # una regione, o che fra i tre settori balla piu' del triplo del rumore
    # mediano, non e' una stima e ci si ferma su quella perla.
    stime = {}
    ferme = []
    controprove = []
    for i, px, py, g in mini:
        cxf, cyf = grandi[g]
        stima = regione_del_petalo(px, py, cxf, cyf, raggi[i], g, MEZZO_SETTORE)
        if stima is None:
            ferme.append((i, round(px), round(py)))
        else:
            stime[i] = stima
            if stima['allungamento'] >= ALLUNGAMENTO_MINIMO:
                controprove.append(stima['controprova'])
    if ferme:
        print('PETALI SENZA REGIONE, ci si ferma e si riporta:')
        for i, px, py in ferme:
            print(f'  perla {i} a ({px},{py})')
        sys.exit(1)
    print(f'controprova con le componenti principali sui '
          f'{len(controprove)} petali allungati: scarto angolare mediano '
          f'{np.median(controprove):.1f} gradi, massimo '
          f'{max(controprove):.1f}')

    frazioni = [stime[i]['frazione'] for i, *_ in mini]
    frazione_unica = float(np.median(frazioni))
    print(f'frazioni correnti: min {min(frazioni):.3f} max {max(frazioni):.3f}'
          f' -> FRAZIONE UNICA (mediana) {frazione_unica:.3f}')

    # IL RUMORE DELLA STIMA, misurato ripetendo con settori diversi: e' la
    # soglia sotto cui correggere sarebbe inseguire il rumore, e viene da una
    # grandezza diversa da quella giudicata.
    scarti_di_rumore = []
    rumore_per_perla = {}
    for i, px, py, g in mini:
        cxf, cyf = grandi[g]
        punti = []
        for mezzo in (13.0, 16.0, 19.0):
            s = regione_del_petalo(px, py, cxf, cyf, raggi[i], g, mezzo)
            if s is None or s['allungamento'] < ALLUNGAMENTO_MINIMO:
                continue
            ax, ay = s['asse']
            punti.append((cxf + ax * frazione_unica * s['cima'],
                          cyf + ay * frazione_unica * s['cima']))
        if len(punti) >= 2:
            xs_, ys_ = [p[0] for p in punti], [p[1] for p in punti]
            scarti_di_rumore.append(
                math.hypot(max(xs_) - min(xs_), max(ys_) - min(ys_)))
        rumore_per_perla[i] = scarti_di_rumore[-1] if len(punti) >= 2 else None
    soglia = float(np.median(scarti_di_rumore))
    print(f'rumore della stima (mediana su tre settori): {soglia:.1f} px '
          f'-> SOGLIA DI CORREZIONE')
    instabili = {i for i, *_ in mini
                 if rumore_per_perla.get(i) is None
                 or rumore_per_perla[i] > 3 * soglia}
    if instabili:
        print("PETALI CON LA STIMA INSTABILE: su queste perle CI SI FERMA, "
              "l'ancoraggio resta dov'e' e lo si riporta, senza inventare:")
        for i in sorted(instabili):
            px, py = [(px, py) for j, px, py, g in mini if j == i][0]
            r = rumore_per_perla.get(i)
            print(f'  perla {i} a ({round(px)},{round(py)}), ballo '
                  f'{"assente" if r is None else f"{r:.1f} px"}')

    # I CENTRI COERENTI e le correzioni.
    centri = {}
    corretti = 0
    scarto_massimo = 0.0
    residuo_massimo = 0.0
    for i, px, py, g in mini:
        if i in instabili:
            centri[i] = (px, py)
            continue
        s = stime[i]
        cxf, cyf = grandi[g]
        ax, ay = s['asse']
        nx = cxf + ax * frazione_unica * s['cima']
        ny = cyf + ay * frazione_unica * s['cima']
        scarto = math.hypot(nx - px, ny - py)
        scarto_massimo = max(scarto_massimo, scarto)
        if scarto > soglia:
            centri[i] = (nx, ny)
            corretti += 1
        else:
            centri[i] = (px, py)
            residuo_massimo = max(residuo_massimo, scarto)
    print(f'ancoraggi corretti: {corretti} su {len(mini)}, scarto massimo '
          f'{scarto_massimo:.1f} px, residuo massimo sotto soglia '
          f'{residuo_massimo:.1f} px')

    # **LA MODALITA' DELLA FERMATA: SOLO MISURA.** L'ordine AG voce 01 e'
    # FERMATA IN ATTESA DI DECISIONE sul riempimento (cinque tecniche
    # provate, tutte con cicatrici alla risoluzione del telefono): finche'
    # Mauro non ritocca in Photoshop, lo strumento non riscrive i derivati.
    # Scrive invece la mappa del ritocco: in rosso i dischi da pulire, in
    # verde i centri coerenti a raggio unico dove il codice posera' le perle.
    if '--solo-misura' in sys.argv:
        from PIL import ImageDraw
        quadro = Image.new('RGB', (w, h), (20, 24, 40))
        base = Image.open(ARTE).convert('RGBA')
        quadro.paste(base, (0, 0), base)
        quadro = quadro.convert('RGBA')
        velo = Image.new('RGBA', (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(velo)
        for i, px, py, g in mini:
            r = raggi[i] + MARGINE_RIEMPIMENTO
            d.ellipse([px - r, py - r, px + r, py + r],
                      outline=(255, 60, 60, 235), width=4)
            nx, ny = centri[i]
            d.ellipse([nx - raggio_unico, ny - raggio_unico,
                       nx + raggio_unico, ny + raggio_unico],
                      outline=(90, 255, 130, 235), width=4)
        quadro.alpha_composite(velo)
        quadro.convert('RGB').save(
            RADICE / 'docs/preview/loto_ritocco_da_fare.png')
        print('mappa del ritocco scritta, i derivati NON sono stati toccati')
        return

    # IL RIEMPIMENTO E' UN CLONE ROTAZIONALE, non una media. Telea inventava
    # spalmate beige e lo specchio radiale rifletteva dentro i lustrini in
    # trifogli fantasma: tutte e due le cicatrici si vedevano nelle anteprime
    # sui buchi che la correzione dei centri lascia scoperti. I dieci petali
    # di un fiore sono quasi copie ruotate di 36 gradi: ogni pixel del buco
    # si riempie col pixel VERO del petalo gemello, ruotato attorno al centro
    # del fiore, scegliendo per ogni perla il gemello che nel punto sorgente
    # non ha buchi suoi. Telea resta solo dove nessun gemello ha la sorgente
    # sana, e una piuma corta fonde la cucitura.
    rgb = im[:, :, :3].copy()
    nuovo = im.copy()
    resto = np.zeros((h, w), np.uint8)
    passo_petalo = 2 * math.pi / 10
    for i, px, py, g in mini:
        cxf, cyf = grandi[g]
        rm = raggi[i] + MARGINE_RIEMPIMENTO
        x0, x1 = max(0, int(px - rm) - 1), min(w, int(px + rm) + 2)
        y0, y1 = max(0, int(py - rm) - 1), min(h, int(py + rm) + 2)
        sy, sx = np.mgrid[y0:y1, x0:x1]
        dentro = (sx - px) ** 2 + (sy - py) ** 2 <= rm * rm
        if not dentro.any():
            continue
        ty, tx = sy[dentro], sx[dentro]
        # **LA SORGENTE DEV'ESSERE SANA E LISCIA.** La prima passata assiale
        # con la sola pretesa di sanita' copiava dentro i buchi la struttura
        # che trovava (un gallone d'oro, un pezzo di raggiera): guardato a
        # risoluzione piena, che e' quella del telefono, era una cicatrice.
        # Ora i candidati sono tanti (assiali a piu' passi, laterali sul
        # petalo, gemelli ruotati) e il punteggio premia la sorgente PIANA:
        # ogni pixel sano vale uno, ma oro, lustri e bui profondi, cioe' la
        # struttura che non e' carne di petalo, tolgono tre.
        migliore = None
        candidati = []
        s = stime.get(i)
        if s is not None:
            ax, ay = s['asse']
            lx, ly = -ay, ax
            for passo_c in (1.7, 2.1, 2.6, 3.2):
                for segno in (1, -1):
                    candidati.append(('asse', segno * passo_c * rm, ax, ay))
            for segno in (1, -1):
                candidati.append(('asse', segno * 1.5 * rm, lx, ly))
                candidati.append(('asse', segno * 1.9 * rm, lx, ly))
        for k in (1, -1, 2, -2, 3, -3):
            candidati.append(('giro', k, None, None))
        for tipo, par, ax, ay in candidati:
            if tipo == 'asse':
                qx = (tx + ax * par).round().astype(int)
                qy = (ty + ay * par).round().astype(int)
            else:
                rot = par * passo_petalo
                cosr, sinr = math.cos(rot), math.sin(rot)
                dx0, dy0 = tx - cxf, ty - cyf
                qx = (cxf + dx0 * cosr - dy0 * sinr).round().astype(int)
                qy = (cyf + dx0 * sinr + dy0 * cosr).round().astype(int)
            valida = (qx >= 0) & (qx < w) & (qy >= 0) & (qy < h)
            sana = valida.copy()
            sana[valida] = (alpha[qy[valida], qx[valida]] > 128) &                 ~maschera_perle[qy[valida], qx[valida]]
            r_s = rgb[qy[sana], qx[sana], 0].astype(int)
            g_s = rgb[qy[sana], qx[sana], 1].astype(int)
            b_s = rgb[qy[sana], qx[sana], 2].astype(int)
            lum_s = (r_s * 299 + g_s * 587 + b_s * 114) // 1000
            strutturati = int(((r_s - g_s > 25) | (lum_s > 150) |
                               (lum_s < 30)).sum())
            punteggio = int(sana.sum()) - 3 * strutturati
            if migliore is None or punteggio > migliore[0]:
                migliore = (punteggio, qx, qy, sana)
        _, qx, qy, sana = migliore
        nuovo[ty[sana], tx[sana], :3] = rgb[qy[sana], qx[sana]]
        resto[ty[~sana], tx[~sana]] = 255
    resto &= (opaco.astype(np.uint8) * 255)
    if resto.any():
        nuovo[:, :, :3] = cv2.inpaint(nuovo[:, :, :3], resto, 5,
                                      cv2.INPAINT_TELEA)
    # Una piuma leggera solo sulla maschera, per fondere la cucitura del
    # clone senza toccare l'arte attorno.
    sfumato = cv2.GaussianBlur(nuovo[:, :, :3], (0, 0), 1.2)
    m3 = (maschera_perle & opaco)
    nuovo[:, :, :3][m3] = sfumato[m3]
    Image.fromarray(nuovo).save(ARTE)
    print(f'arte riscritta: {int((maschera_perle & opaco).sum())} pixel '
          f'clonati dal petalo gemello su {ARTE.name}, di cui '
          f'{int((resto > 0).sum())} col ripiego di Telea')

    # I PALLINI NUOVI: mini a raggio unico sui centri coerenti, coi colori di
    # gruppo letti dal file vecchio; i grandi si ricopiano tali e quali.
    colori = {}
    for i, px, py, g in mini:
        p = pal[int(py), int(px)]
        if p[3] > 128:
            colori[g] = tuple(int(v) for v in p[:3])
    assert len(colori) == 5, f'colori di gruppo trovati: {len(colori)}'
    nuovi_pallini = np.zeros_like(pal)
    # I grandi: si copiano i pixel del pallini vecchio dentro i loro dischi.
    for g, (gx, gy) in grandi.items():
        d2 = (xs - gx) ** 2 + (ys - gy) ** 2
        m = (d2 <= 60 ** 2) & (pal[:, :, 3] > 128)
        nuovi_pallini[m] = pal[m]
    for i, px, py, g in mini:
        nx, ny = centri[i]
        d2 = (xs - nx) ** 2 + (ys - ny) ** 2
        m = d2 <= raggio_unico ** 2
        nuovi_pallini[m] = (*colori[g], 255)
    Image.fromarray(nuovi_pallini).save(PALLINI)
    print(f'pallini riscritti: 50 mini a raggio {raggio_unico} '
          f'piu\' 5 grandi ricopiati, su {PALLINI.name}')


if __name__ == '__main__':
    main()
