import * as crypto from "crypto";

describe("deletePlate — resolution du hash cible", () => {
  const SALT = "test-salt-secret";

  function resolvePlateHash(input: { plate?: string; plateHash?: string }, salt: string): string {
    if (input.plateHash && typeof input.plateHash === "string") {
      return input.plateHash;
    }

    if (input.plate && typeof input.plate === "string") {
      return crypto.createHash("sha256").update(input.plate + salt).digest("hex");
    }

    throw new Error("invalid-argument");
  }

  test("utilise le hash direct quand il est fourni", () => {
    expect(resolvePlateHash({ plateHash: "abc123" }, SALT)).toBe("abc123");
  });

  test("calcule le hash depuis la plaque quand besoin", () => {
    const expected = crypto.createHash("sha256").update("AB-123-CD" + SALT).digest("hex");
    expect(resolvePlateHash({ plate: "AB-123-CD" }, SALT)).toBe(expected);
  });

  test("rejette un appel sans plaque ni hash", () => {
    expect(() => resolvePlateHash({}, SALT)).toThrow("invalid-argument");
  });
});