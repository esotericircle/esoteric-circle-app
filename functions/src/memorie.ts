/**
 * **LE MEMORIE CHE TORNANO COL TUO ACCOUNT.** Ordine EV, il fondatore il 1
 * ottobre 2026, dopo una reinstallazione: "non mi ha riaccreditato [...] gli
 * storici del dono "runa del tramonto". Avevo già accumulato 5 [...] e adesso
 * devo ricominciare da 1 [...] Se c'è una tipologia di problema,
 * probabilmente c'è lo stesso problema con altre funzionalità, per logica."
 *
 * Il Cerchio custodiva il cammino, i Sigilli, l'Alba e il Viaggio, ognuno con
 * la sua porta scritta a mano; ogni altra memoria della persona viveva solo
 * sul telefono. Qui c'e' **una porta sola per tutte le altre**: il telefono
 * manda le sue chiavi, famiglia per famiglia, e il Cerchio le fonde con quelle
 * che custodisce **senza perdere niente**:
 *
 * - due liste di testi: l'unione, prima l'ordine del telefono;
 * - due numeri: il piu' alto;
 * - due vero o falso: vero se uno dei due e' vero;
 * - due testi che sono JSON: l'unione profonda (oggetti chiave per chiave,
 *   liste per elemento), a parita' il telefono;
 * - due testi qualunque: il telefono, che e' quello vivo.
 *
 * Un telefono reinstallato da zero manda poco o niente: l'unione non puo'
 * togliere al Cerchio quello che custodisce, ed e' il caso che ha fatto
 * nascere questo file.
 *
 * **La forma, per Firestore**: ogni chiave e' {t, v}, con t "s" (testo), "i"
 * (intero), "d" (decimale), "b" (vero o falso), "l" (lista di testi). Le liste
 * restano di un livello solo: Firestore non accetta una lista dentro una
 * lista, e un JSON resta un testo.
 */

/** Una chiave come la scrive il telefono. */
export interface ValoreDiMemoria {
  t: "s" | "i" | "d" | "b" | "l";
  v: string | number | boolean | string[];
}

/** Le memorie: famiglia -> chiave -> valore. */
export type Memorie = Record<string, Record<string, ValoreDiMemoria>>;

/** Quanto puo' pesare una famiglia, scritta: oltre si tiene quella di prima. */
export const PESO_MASSIMO_DI_UNA_FAMIGLIA = 60000;

/** Quante famiglie al massimo, e quante chiavi per famiglia. */
export const FAMIGLIE_MASSIME = 40;
export const CHIAVI_MASSIME = 400;

function valore(grezzo: unknown): ValoreDiMemoria | undefined {
  if (!grezzo || typeof grezzo !== "object") return undefined;
  const g = grezzo as Record<string, unknown>;
  const t = g.t;
  const v = g.v;
  if (t === "s" && typeof v === "string") return {t, v};
  if ((t === "i" || t === "d") && typeof v === "number" && Number.isFinite(v)) {
    return {t, v};
  }
  if (t === "b" && typeof v === "boolean") return {t, v};
  if (t === "l" && Array.isArray(v) && v.every((x) => typeof x === "string")) {
    return {t, v: v as string[]};
  }
  return undefined;
}

/** Legge le memorie arrivate, tenendo solo cio' che ha la forma giusta. */
export function leggiMemorie(grezzo: unknown): Memorie | undefined {
  if (!grezzo || typeof grezzo !== "object" || Array.isArray(grezzo)) {
    return undefined;
  }
  const fuori: Memorie = {};
  let famiglie = 0;
  for (const [famiglia, chiavi] of Object.entries(grezzo)) {
    if (famiglie >= FAMIGLIE_MASSIME) break;
    if (!/^[a-z_][a-z0-9_.]{0,63}$/.test(famiglia)) continue;
    if (!chiavi || typeof chiavi !== "object" || Array.isArray(chiavi)) {
      continue;
    }
    const dentro: Record<string, ValoreDiMemoria> = {};
    let quante = 0;
    for (const [chiave, v] of Object.entries(chiavi)) {
      if (quante >= CHIAVI_MASSIME) break;
      if (chiave.length === 0 || chiave.length > 200) continue;
      if (chiave.startsWith("__")) continue;
      const letto = valore(v);
      if (letto) {
        dentro[chiave] = letto;
        quante++;
      }
    }
    if (quante === 0) continue;
    if (JSON.stringify(dentro).length > PESO_MASSIMO_DI_UNA_FAMIGLIA) continue;
    fuori[famiglia] = dentro;
    famiglie++;
  }
  return Object.keys(fuori).length > 0 ? fuori : undefined;
}

/**
 * **CHI E' UN ELEMENTO DI UNA LISTA.** Un oggetto con un id, una chiave, un
 * giorno o un istante e' quello, anche se e' cambiato: un sigillo passato da
 * vivo a lasciato, una sera del Tramonto riscritta. Senza, l'unione terrebbe
 * le due versioni. Un testo che e' un oggetto JSON si legge allo stesso modo
 * (lo storico dell'Archetipo e' una lista di testi JSON). Il resto e' se
 * stesso.
 */
function identita(x: unknown): string {
  let o: unknown = x;
  if (typeof x === "string" && x.trim().startsWith("{")) {
    try {
      o = JSON.parse(x);
    } catch {
      o = x;
    }
  }
  if (o && typeof o === "object" && !Array.isArray(o)) {
    const r = o as Record<string, unknown>;
    for (const k of ["id", "chiave", "giorno", "quando", "nome"]) {
      const v = r[k];
      if (typeof v === "string" || typeof v === "number") return `${k}:${v}`;
    }
  }
  return JSON.stringify(x);
}

function unioneDiListe(telefono: unknown[], server: unknown[]): unknown[] {
  const visti = new Set<string>();
  const fuori: unknown[] = [];
  // Prima il telefono: a parita' d'identita' vince la sua versione.
  for (const x of [...telefono, ...server]) {
    const firma = identita(x);
    if (visti.has(firma)) continue;
    visti.add(firma);
    fuori.push(x);
  }
  return fuori;
}

/** L'unione profonda di due valori JSON, a parita' il telefono. */
export function unioneProfonda(telefono: unknown, server: unknown): unknown {
  if (telefono === undefined) return server;
  if (server === undefined) return telefono;
  if (Array.isArray(telefono) && Array.isArray(server)) {
    return unioneDiListe(telefono, server);
  }
  if (
    telefono && server &&
    typeof telefono === "object" && typeof server === "object" &&
    !Array.isArray(telefono) && !Array.isArray(server)
  ) {
    const t = telefono as Record<string, unknown>;
    const s = server as Record<string, unknown>;
    const fuori: Record<string, unknown> = {...s};
    for (const [k, v] of Object.entries(t)) {
      fuori[k] = unioneProfonda(v, s[k]);
    }
    return fuori;
  }
  if (typeof telefono === "number" && typeof server === "number") {
    return Math.max(telefono, server);
  }
  if (typeof telefono === "boolean" && typeof server === "boolean") {
    return telefono || server;
  }
  return telefono;
}

function json(testo: string): unknown {
  const t = testo.trim();
  if (!(t.startsWith("{") || t.startsWith("["))) return undefined;
  try {
    return JSON.parse(t);
  } catch {
    return undefined;
  }
}

/** Fonde una chiave del telefono con quella del Cerchio. */
export function fondiUnValore(
  telefono: ValoreDiMemoria | undefined,
  server: ValoreDiMemoria | undefined
): ValoreDiMemoria | undefined {
  if (!telefono) return server;
  if (!server) return telefono;
  if (telefono.t !== server.t) return telefono;
  switch (telefono.t) {
  case "l":
    return {
      t: "l",
      v: unioneDiListe(telefono.v as string[], server.v as string[]) as string[],
    };
  case "i":
  case "d":
    return {
      t: telefono.t,
      v: Math.max(telefono.v as number, server.v as number),
    };
  case "b":
    return {t: "b", v: (telefono.v as boolean) || (server.v as boolean)};
  case "s": {
    const a = json(telefono.v as string);
    const b = json(server.v as string);
    if (a !== undefined && b !== undefined) {
      return {t: "s", v: JSON.stringify(unioneProfonda(a, b))};
    }
    return telefono;
  }
  }
  return telefono;
}

/** Fonde le memorie del telefono con quelle del Cerchio, famiglia per famiglia. */
export function fondiMemorie(
  server: Memorie | undefined,
  telefono: Memorie | undefined
): Memorie | undefined {
  if (!server) return telefono;
  if (!telefono) return server;
  const fuori: Memorie = {};
  const famiglie = new Set([...Object.keys(server), ...Object.keys(telefono)]);
  for (const famiglia of famiglie) {
    const s = server[famiglia] ?? {};
    const t = telefono[famiglia] ?? {};
    const dentro: Record<string, ValoreDiMemoria> = {};
    for (const chiave of new Set([...Object.keys(s), ...Object.keys(t)])) {
      const v = fondiUnValore(t[chiave], s[chiave]);
      if (v) dentro[chiave] = v;
    }
    // Una famiglia che, fusa, supera il peso torna quella del Cerchio: non
    // si perde niente di cio' che c'era, e il telefono ritenta al prossimo
    // giro.
    fuori[famiglia] =
      JSON.stringify(dentro).length > PESO_MASSIMO_DI_UNA_FAMIGLIA ?
        s : dentro;
  }
  return fuori;
}
