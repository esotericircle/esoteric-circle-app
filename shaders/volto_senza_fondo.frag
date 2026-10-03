// IL VOLTO DI PROTOFACE SENZA IL SUO FONDO BIANCO. Ordine EG voce 05.
//
// Il video di Protoface arriva col fondo bianco, e WebRTC non porta l'alpha.
// Un filtro colore toglieva il bianco pieno ma lasciava un filo chiaro lungo
// tutta la sagoma: i pixel di bordo sono una miscela fra il Maestro e il
// bianco, e per luminosita' non si distinguono da un punto chiaro del viso.
// Il fondatore: "Il contorno bianco intorno all'avatar non va bene".
//
// Due domande per ogni pixel.
//
// C'E' FONDO A UN PASSO? Venticinque campioni a 2, 4 e 6 pixel: il bordo
// sfumato del video, che la compressione allarga di qualche pixel, ha il
// fondo accanto.
//
// C'E' FONDO ANCHE PIU' IN LA'? Sedici campioni a 10 e 14 pixel: un riflesso
// chiaro dentro la figura ha attorno la figura, e resta intero.
//
// E UNA TOPPA. Nel video di Medora ci sono due bianchi chiusi, contati sul
// fotogramma col fondo bianco: lo spiraglio fra l'orecchino e il collo, che
// e' fondo e va tolto, e un buco nel mantello sulla spalla, che nessuna
// regola locale distingue dallo spiraglio. Il buco e' dichiarato a mano in
// [u_toppa], e li' il bianco si riempie col
// colore del mantello attorno. Tre stesure automatiche sono state provate
// prima, e ognuna sbagliava uno dei due.
//
// E UNA ZONA INTATTA. Il cristallo della spilla di Caligo e' bianco e largo,
// e la regola lo prendeva per fondo e lo bucava di nero. In [u_intatto] il
// video si lascia com'e'. Le due zone sono in frazioni della finestra, che e'
// l'immagine che lo shader riceve.

#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform vec4 u_toppa;
uniform vec4 u_intatto;
uniform sampler2D u_video;

out vec4 frag_color;

vec4 campione(vec2 punto) {
  vec2 uv = punto / u_size;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif
  return texture(u_video, uv);
}

// Quanto un colore e' fondo: tutti e tre i canali alti E quasi uguali fra
// loro, cioe' un bianco neutro. Il minimo alto separa il bianco dall'oro; la
// differenza fra i canali lo separa dalla pelle chiara, che resta rosata
// anche nei punti piu' luminosi: col solo minimo, il petto di Medora veniva
// bucato di nero sotto il ciondolo.
float fondo(vec3 c) {
  float minimo = min(c.r, min(c.g, c.b));
  float massimo = max(c.r, max(c.g, c.b));
  return smoothstep(0.86, 0.94, minimo) *
         (1.0 - smoothstep(0.05, 0.11, massimo - minimo));
}

void main() {
  vec2 qui = FlutterFragCoord().xy;
  vec4 colore = campione(qui);
  vec2 uv = qui / u_size;

  bool nellIntatto = uv.x >= u_intatto.x && uv.x <= u_intatto.z &&
                     uv.y >= u_intatto.y && uv.y <= u_intatto.w;
  if (nellIntatto) {
    frag_color = vec4(colore.rgb, 1.0);
    return;
  }

  bool nellaToppa = uv.x >= u_toppa.x && uv.x <= u_toppa.z &&
                    uv.y >= u_toppa.y && uv.y <= u_toppa.w;
  if (nellaToppa) {
    // Il colore del mantello attorno, pesato su quanto non e' bianco.
    vec3 somma = vec3(0.0);
    float peso = 0.0;
    for (int i = 0; i < 8; i++) {
      float angolo = float(i) * 0.785398;
      vec2 verso = vec2(cos(angolo), sin(angolo));
      for (int k = 1; k <= 3; k++) {
        vec3 c = campione(qui + verso * (8.0 * float(k))).rgb;
        float n = 1.0 - fondo(c);
        somma += c * n;
        peso += n;
      }
    }
    vec3 rgb = peso > 0.5
        ? mix(colore.rgb, somma / peso, fondo(colore.rgb))
        : colore.rgb;
    frag_color = vec4(rgb, 1.0);
    return;
  }

  float vicino = fondo(colore.rgb);
  float lontano = 0.0;
  for (int i = 0; i < 8; i++) {
    float angolo = float(i) * 0.785398;
    vec2 verso = vec2(cos(angolo), sin(angolo));
    vicino += fondo(campione(qui + verso * 2.0).rgb);
    vicino += fondo(campione(qui + verso * 4.0).rgb);
    vicino += fondo(campione(qui + verso * 6.0).rgb);
    lontano += fondo(campione(qui + verso * 10.0).rgb);
    lontano += fondo(campione(qui + verso * 14.0).rgb);
  }
  vicino /= 25.0;
  lontano /= 16.0;

  // Il bordo vero ha fondo accanto E piu' in la': sparisce.
  float via = smoothstep(0.06, 0.22, vicino) * smoothstep(0.08, 0.22, lontano);
  float alfa = 1.0 - via;
  frag_color = vec4(colore.rgb * alfa, alfa);
}
