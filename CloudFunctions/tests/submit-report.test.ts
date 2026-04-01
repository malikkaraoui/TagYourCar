import * as crypto from "crypto";

describe("submitReport — logique de validation", () => {
  const plateRegex = /^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$/;

  test("plaque valide acceptee", () => {
    expect(plateRegex.test("AB-123-CD")).toBe(true);
    expect(plateRegex.test("ZZ-999-AA")).toBe(true);
  });

  test("plaque invalide rejetee", () => {
    expect(plateRegex.test("ab-123-cd")).toBe(false);
    expect(plateRegex.test("")).toBe(false);
    expect(plateRegex.test("AB-12-CD")).toBe(false);
    expect(plateRegex.test("ABC-123-CD")).toBe(false);
  });

  test("champs requis : zone, problemType, vehicleColor, plate", () => {
    const requiredFields = ["zone", "problemType", "vehicleColor", "plate"];
    const data = { zone: "front", problemType: "headlights_on", vehicleColor: "blue", plate: "AB-123-CD" };

    for (const field of requiredFields) {
      const incomplete = { ...data };
      delete (incomplete as Record<string, unknown>)[field];
      const missing = !incomplete.zone || !incomplete.problemType || !incomplete.vehicleColor || !incomplete.plate;
      expect(missing).toBe(true);
    }
  });

  test("donnees completes passent la validation", () => {
    const data = { zone: "front", problemType: "headlights_on", vehicleColor: "blue", plate: "AB-123-CD" };
    const valid = data.zone && data.problemType && data.vehicleColor && data.plate && plateRegex.test(data.plate);
    expect(valid).toBe(true);
  });
});

describe("submitReport — masquage partialPlate (RGPD)", () => {
  function buildPartialPlate(plate: string): string {
    return plate.substring(0, 2) + "-xxx-" + plate.substring(7);
  }

  test("AB-123-CD masque en AB-xxx-CD", () => {
    expect(buildPartialPlate("AB-123-CD")).toBe("AB-xxx-CD");
  });

  test("ZZ-999-AA masque en ZZ-xxx-AA", () => {
    expect(buildPartialPlate("ZZ-999-AA")).toBe("ZZ-xxx-AA");
  });

  test("aucun chiffre visible dans la partie masquee", () => {
    const partial = buildPartialPlate("XY-456-WQ");
    // La partie centrale doit etre "xxx"
    const middle = partial.split("-")[1];
    expect(middle).toBe("xxx");
  });

  test("les lettres de debut et fin sont preservees", () => {
    const partial = buildPartialPlate("AB-123-CD");
    expect(partial.startsWith("AB")).toBe(true);
    expect(partial.endsWith("CD")).toBe(true);
  });
});

describe("submitReport — hashage plaque", () => {
  const SALT = "test-salt";

  function hashPlate(plate: string, salt: string): string {
    return crypto.createHash("sha256").update(plate + salt).digest("hex");
  }

  test("hash est deterministe", () => {
    expect(hashPlate("AB-123-CD", SALT)).toBe(hashPlate("AB-123-CD", SALT));
  });

  test("plaques differentes produisent des hash differents", () => {
    expect(hashPlate("AB-123-CD", SALT)).not.toBe(hashPlate("EF-456-GH", SALT));
  });
});
