import { describe, expect, it } from "vitest";
import { CLINICAL_FIELDS, CLINICAL_STEPS, DEMO_DIGITAL_ANSWERS, DONATION_INTERRUPTION_REASONS, UNIT_REJECTION_REASONS, resolveClinicalReason, normalizeClinicalStep, questionnaireReview } from "@/lib/clinical-evaluation";

describe("unified clinical evaluation", () => {
  it("uses four stages with evaluation before donation", () => expect(CLINICAL_STEPS.map(([step]) => step)).toEqual(["identify", "evaluacion", "donacion", "laboratorio"]));
  it("collects only pulse, pressure, temperature and hemoglobin, without weight", () => expect(CLINICAL_FIELDS.map(([field]) => field)).toEqual(["pulse", "bp", "temp", "hb"]));
  it("continues legacy screening and interview records in evaluation", () => {
    expect(normalizeClinicalStep("tamizaje")).toBe("evaluacion");
    expect(normalizeClinicalStep("entrevista")).toBe("evaluacion");
  });
  it("flags declared medication for medical review without making a fitness decision", () => {
    const review = questionnaireReview({ 0: "Sí", 1: "Sí", 2: "Sí", 3: "No", 4: "Sí", 5: "No", 6: "No", 7: "No" });
    expect(review.complete).toBe(true);
    expect(review.alerts).toEqual([{ question: "¿Has tomado antibióticos u otros medicamentos en la última semana?", answer: "Sí" }]);
  });
  it("does not label missing answers as a complete questionnaire", () => expect(questionnaireReview({}).complete).toBe(false));
  it("provides a complete favorable digital questionnaire for the demo", () => expect(questionnaireReview(DEMO_DIGITAL_ANSWERS)).toEqual({ complete: true, alerts: [] }));
  it("requires a written reason for an interrupted donation marked Other", () => {
    expect(resolveClinicalReason("Otro", "   ", DONATION_INTERRUPTION_REASONS)).toBeNull();
    expect(resolveClinicalReason("Otro", " Extracción suspendida a solicitud médica ", DONATION_INTERRUPTION_REASONS)).toBe("Extracción suspendida a solicitud médica");
    expect(resolveClinicalReason("Decisión del donante", "", DONATION_INTERRUPTION_REASONS)).toBe("Decisión del donante");
  });
  it("requires an internal reason for a unit rejected as Other", () => {
    expect(resolveClinicalReason("Otro", "", UNIT_REJECTION_REASONS)).toBeNull();
    expect(resolveClinicalReason("Otro", "Bolsa dañada", UNIT_REJECTION_REASONS)).toBe("Bolsa dañada");
  });
});