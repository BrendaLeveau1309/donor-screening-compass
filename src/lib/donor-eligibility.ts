// Estado de aptitud del donante compartido entre backoffice y app (demo en localStorage).
export type Outcome =
  | { kind: "apto" }
  | { kind: "temporal"; reason: string; until: string } // until: YYYY-MM-DD
  | { kind: "permanente"; reason: string }
  | { kind: "lab_rechazo" }; // citación confidencial, sin diagnóstico

export const OUTCOME_KEY = "nexovital-donor-outcomes";
export const DEMO_DONOR_DOC = "demo";
const DAY = 86400000;

export function daysUntil(until: string, now = Date.now()): number {
  const end = new Date(`${until}T00:00:00`).getTime();
  return Math.max(0, Math.ceil((end - now) / DAY));
}

/** Estado del carnet: habilitado, diferido (con días restantes) o no apto permanente. */
export function eligibility(o: Outcome | undefined, now = Date.now()): { status: "habilitado" | "diferido" | "permanente"; days: number } {
  if (!o || o.kind === "apto") return { status: "habilitado", days: 0 };
  if (o.kind === "permanente") return { status: "permanente", days: 0 };
  if (o.kind === "temporal") { const d = daysUntil(o.until, now); return d > 0 ? { status: "diferido", days: d } : { status: "habilitado", days: 0 }; }
  return { status: "diferido", days: 0 }; // lab_rechazo: en descanso hasta consejería
}

export const loadOutcomes = (): Record<string, Outcome> => { try { return JSON.parse(localStorage.getItem(OUTCOME_KEY) ?? "{}"); } catch { return {}; } };
export function saveOutcome(doc: string, o: Outcome) {
  const all = loadOutcomes(); all[doc] = o; all[DEMO_DONOR_DOC] = o; // el último resultado se refleja en la app demo
  localStorage.setItem(OUTCOME_KEY, JSON.stringify(all));
  window.dispatchEvent(new Event("nexovital-outcome"));
}
