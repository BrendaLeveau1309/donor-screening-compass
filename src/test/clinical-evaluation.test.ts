import { describe, expect, it } from "vitest";
import { CLINICAL_FIELDS, CLINICAL_STEPS, normalizeClinicalStep, questionnaireReview } from "@/lib/clinical-evaluation";

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
});