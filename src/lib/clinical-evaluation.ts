export const CLINICAL_FIELDS = [
  ["pulse", "Latidos del corazón (ppm)"],
  ["bp", "Presión arterial"],
  ["temp", "Temperatura (°C)"],
  ["hb", "Hemoglobina (g/dL)"],
] as const;

export type ClinicalStep = "identify" | "evaluacion" | "donacion" | "laboratorio";
export const CLINICAL_STEPS: [ClinicalStep, string][] = [
  ["identify", "Identificación"], ["evaluacion", "Evaluación clínica"],
  ["donacion", "Donación"], ["laboratorio", "Validación de laboratorio"],
];
export function normalizeClinicalStep(step: ClinicalStep | "tamizaje" | "entrevista"): ClinicalStep {
  return step === "tamizaje" || step === "entrevista" ? "evaluacion" : step;
}

export const PREDONATION_QUESTIONS = [
  "¿Te sientes bien de salud hoy?",
  "¿Has dormido al menos 6 horas anoche?",
  "¿Has comido algo en las últimas 4 horas?",
  "¿Has tenido fiebre, gripe o infección en los últimos 14 días?",
  "¿Has tomado antibióticos u otros medicamentos en la última semana?",
  "¿Te has hecho un tatuaje, piercing o acupuntura en los últimos 12 meses?",
  "¿Has tenido alguna cirugía o transfusión en los últimos 12 meses?",
  "¿Has consumido alcohol en las últimas 24 horas?",
];
export function questionnaireReview(answers: Record<string, unknown>) {
  const complete = PREDONATION_QUESTIONS.every((_, i) => answers[i] === "Sí" || answers[i] === "No");
  const alerts = PREDONATION_QUESTIONS.flatMap((question, i) => answers[i] === (i < 3 ? "No" : "Sí") ? [{ question, answer: String(answers[i]) }] : []);
  return { complete, alerts };
}