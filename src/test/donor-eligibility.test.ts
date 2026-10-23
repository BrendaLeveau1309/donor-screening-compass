import { describe, expect, it } from "vitest";
import { eligibility } from "@/lib/donor-eligibility";

const now = new Date("2026-10-23T12:00:00").getTime();

describe("eligibility", () => {
  it("apto is habilitado", () => expect(eligibility({ kind: "apto" }, now).status).toBe("habilitado"));
  it("temporal deferral counts remaining days", () => expect(eligibility({ kind: "temporal", reason: "x", until: "2026-11-02" }, now)).toEqual({ status: "diferido", days: 10 }));
  it("expired temporal deferral is habilitado again", () => expect(eligibility({ kind: "temporal", reason: "x", until: "2026-10-01" }, now).status).toBe("habilitado"));
  it("permanent stays permanente", () => expect(eligibility({ kind: "permanente", reason: "x" }, now).status).toBe("permanente"));
  it("temporal exclusion without an end date stays deferred", () => expect(eligibility({ kind: "temporal", reason: "Pendiente de reevaluación" }, now)).toEqual({ status: "diferido", days: 0 }));
});
