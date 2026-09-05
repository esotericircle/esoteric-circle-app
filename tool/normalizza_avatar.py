# Rigenera i tre avatar dei Maestri su una tela sola, con la stessa altezza di
# figura e i piedi sulla stessa linea.
#
# PERCHE' ESISTE. I tre master arrivavano con la figura a quote diverse dentro
# la tela: nello stesso riquadro Medora sembrava piu' piccola di Caligo non
# perche' fosse disegnata piu' bassa, ma perche' attorno alla sua figura c'era
# piu' aria. Qui l'aria si toglie ritagliando al contenuto, le tre figure si
# portano alla stessa altezza e si posano sulla stessa linea. Il riferimento e'
# Aura, che NON si ridisegna e NON si sposta: si riduce e basta, quindi il suo
# aspetto non cambia e le sue frazioni restano identiche.
#
# Uso:
#   python tool/normalizza_avatar.py <cartella_sorgenti_nuovi>
#
# I sorgenti nuovi di Medora e Caligo NON stanno nel repository: sono i master
# di Mauro. Aura si rigenera dal PNG che e' gia' in brand_assets/avatars/.

import os
import sys

from PIL import Image

# ---- LA TELA, E DA DOVE ESCE IL NUMERO ------------------------------------
# 1700 non e' una misura di comodo. L'altezza a cui l'app disegna davvero un
# avatar e' stata misurata montando le schermate vere: il massimo e' 1633 px
# fisici, il busto centrale del Santuario su uno schermo di 360x900 punti
# logici a rapporto di pixel 4.
#
# **Quel massimo non e' un tetto: e' una retta.** Il busto del Santuario non ha
# una misura fissa, cresce con l'altezza dello schermo. Per questo sopra i 1633
# misurati resta un margine del 4 per cento: 1700 copre uno schermo alto fino a
# 931 punti logici a rapporto 4, oltre qualunque telefono in circolazione.
# Chi abbassa questo numero fa disegnare gli avatar ingranditi sui telefoni
# alti; chi lo alza paga memoria che nessuno vede, perche' una immagine
# decodificata occupa larghezza per altezza per 4 byte in RAM qualunque sia la
# compressione del file.
TELA_H = 1700

# La larghezza NON e' scelta: e' la stessa proporzione della tela di prima
# (2056x3060), cosi' nessun riquadro dell'app cambia larghezza.
# 1700 * 2056 / 3060 = 1142.
TELA_W = 1142

# La stessa qualita' delle sei famiglie esoteriche, in tool/converti_webp.py.
QUALITA_WEBP = 88

SORGENTI_NUOVI = {
    "Medora": "Medora-Scontornata-1.png",
    "Caligo": "Caligo-HD-1-Scontornata.png",
}

MASTER = os.path.join("brand_assets", "avatars")
BUNDLE = os.path.join("assets", "avatars_webp")


def bbox_opaco(im):
    """Il riquadro dei pixel non trasparenti: la figura, senza l'aria."""
    return im.getchannel("A").getbbox()


def salva(im, stem):
    png = os.path.join(MASTER, f"{stem}.png")
    webp = os.path.join(BUNDLE, f"{stem}.webp")
    im.save(png, "PNG", optimize=True)
    im.save(webp, "WEBP", quality=QUALITA_WEBP, method=6)
    print(f"   -> {png} {os.path.getsize(png):,} byte")
    print(f"   -> {webp} {os.path.getsize(webp):,} byte")


def main():
    if len(sys.argv) < 2:
        raise SystemExit("uso: python tool/normalizza_avatar.py <sorgenti>")
    sorgenti = sys.argv[1]

    # 1. AURA, il riferimento. Sola riduzione della tela intera: nessun
    #    ritaglio, nessuno spostamento. Scalando in modo uniforme, ogni sua
    #    frazione resta identica, quindi i suoi facePoints restano validi.
    aura = Image.open(os.path.join(MASTER, "Aura-1.png")).convert("RGBA")
    aura_pic = aura.resize((TELA_W, TELA_H), Image.LANCZOS)
    b = bbox_opaco(aura_pic)
    fig_alt = b[3] - b[1]
    piedi = b[3]
    print(f"AURA ridotta da {aura.size} a {aura_pic.size}: riquadro {b}, "
          f"figura {fig_alt} px, piedi a y={piedi}")
    salva(aura_pic, "Aura-1")

    # 2. MEDORA e CALIGO. Ritaglio al contenuto, scala alla figura di Aura,
    #    piedi sulla stessa linea, centratura orizzontale del riquadro opaco.
    for nome, file_sorgente in SORGENTI_NUOVI.items():
        percorso = os.path.join(sorgenti, file_sorgente)
        src = Image.open(percorso).convert("RGBA")
        rb = bbox_opaco(src)
        ritaglio = src.crop(rb)
        cw, ch = ritaglio.size
        nuova_w = max(1, round(cw * fig_alt / ch))
        if nuova_w > TELA_W:
            raise SystemExit(
                f"{nome}: la figura larga {nuova_w} non entra in {TELA_W}")
        figura = ritaglio.resize((nuova_w, fig_alt), Image.LANCZOS)
        tela = Image.new("RGBA", (TELA_W, TELA_H), (0, 0, 0, 0))
        x = round((TELA_W - nuova_w) / 2)
        y = piedi - fig_alt
        tela.paste(figura, (x, y))
        print(f"{nome.upper()}: sorgente {src.size} riquadro {rb} -> "
              f"ritaglio {ritaglio.size} -> figura {figura.size}, "
              f"posata a ({x},{y}), riquadro finale {bbox_opaco(tela)}")
        salva(tela, f"{nome}-1")


main()
