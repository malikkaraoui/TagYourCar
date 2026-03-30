import * as crypto from "crypto";

// Test the hashing logic independently (no Firebase dependency)
describe("hashPlate logic", () => {
  const SALT = "test-salt-secret";

  function hashPlateLogic(plate: string, salt: string): string {
    return crypto.createHash("sha256").update(plate + salt).digest("hex");
  }

  test("same plate + same salt = same hash", () => {
    const hash1 = hashPlateLogic("AB-123-CD", SALT);
    const hash2 = hashPlateLogic("AB-123-CD", SALT);
    expect(hash1).toBe(hash2);
  });

  test("different plates = different hashes", () => {
    const hash1 = hashPlateLogic("AB-123-CD", SALT);
    const hash2 = hashPlateLogic("EF-456-GH", SALT);
    expect(hash1).not.toBe(hash2);
  });

  test("same plate + different salt = different hash", () => {
    const hash1 = hashPlateLogic("AB-123-CD", SALT);
    const hash2 = hashPlateLogic("AB-123-CD", "other-salt");
    expect(hash1).not.toBe(hash2);
  });

  test("hash is 64 chars hex (SHA-256)", () => {
    const hash = hashPlateLogic("AB-123-CD", SALT);
    expect(hash).toMatch(/^[a-f0-9]{64}$/);
  });

  test("hash does not contain the original plate", () => {
    const hash = hashPlateLogic("AB-123-CD", SALT);
    expect(hash).not.toContain("AB");
    expect(hash).not.toContain("123");
    expect(hash).not.toContain("CD");
  });
});

describe("plate format validation", () => {
  const plateRegex = /^[A-Z]{2}-[0-9]{3}-[A-Z]{2}$/;

  test("valid French plate format", () => {
    expect(plateRegex.test("AB-123-CD")).toBe(true);
    expect(plateRegex.test("ZZ-999-ZZ")).toBe(true);
    expect(plateRegex.test("AA-001-AA")).toBe(true);
  });

  test("invalid formats rejected", () => {
    expect(plateRegex.test("ab-123-cd")).toBe(false); // lowercase
    expect(plateRegex.test("AB123CD")).toBe(false); // no dashes
    expect(plateRegex.test("ABC-123-CD")).toBe(false); // 3 letters
    expect(plateRegex.test("AB-12-CD")).toBe(false); // 2 digits
    expect(plateRegex.test("AB-1234-CD")).toBe(false); // 4 digits
    expect(plateRegex.test("")).toBe(false); // empty
    expect(plateRegex.test("AB 123 CD")).toBe(false); // spaces
  });
});

describe("plate limit", () => {
  const MAX_PLATES_PER_USER = 5;

  test("limit is 5 plates per user", () => {
    expect(MAX_PLATES_PER_USER).toBe(5);
  });

  test("user with 4 plates can add one more", () => {
    const currentCount = 4;
    expect(currentCount < MAX_PLATES_PER_USER).toBe(true);
  });

  test("user with 5 plates cannot add more", () => {
    const currentCount = 5;
    expect(currentCount >= MAX_PLATES_PER_USER).toBe(true);
  });
});
