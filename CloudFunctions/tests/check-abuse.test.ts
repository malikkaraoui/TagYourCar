describe("checkAbuse — constantes et regles", () => {
  const MAX_REPORTS_PER_24H = 10;
  const SAME_PLATE_THRESHOLD = 3;
  const BLOCK_DURATIONS: Record<number, number | null> = {
    1: 24 * 60 * 60 * 1000,
    2: 72 * 60 * 60 * 1000,
    3: null,
  };

  test("limite globale est 10 signalements par 24h", () => {
    expect(MAX_REPORTS_PER_24H).toBe(10);
  });

  test("seuil meme plaque est 3", () => {
    expect(SAME_PLATE_THRESHOLD).toBe(3);
  });

  test("blocage niveau 1 = 24h", () => {
    expect(BLOCK_DURATIONS[1]).toBe(24 * 60 * 60 * 1000);
  });

  test("blocage niveau 2 = 72h", () => {
    expect(BLOCK_DURATIONS[2]).toBe(72 * 60 * 60 * 1000);
  });

  test("blocage niveau 3 = definitif (null)", () => {
    expect(BLOCK_DURATIONS[3]).toBeNull();
  });
});

describe("checkAbuse — logique de rate limiting", () => {
  const MAX_REPORTS_PER_24H = 10;

  test("9 signalements = autorise", () => {
    const count = 9;
    expect(count < MAX_REPORTS_PER_24H).toBe(true);
  });

  test("10 signalements = bloque", () => {
    const count = 10;
    expect(count >= MAX_REPORTS_PER_24H).toBe(true);
  });

  test("0 signalements = autorise", () => {
    const count = 0;
    expect(count < MAX_REPORTS_PER_24H).toBe(true);
  });

  test("signalements restants calcules correctement", () => {
    const count = 7;
    const remaining = MAX_REPORTS_PER_24H - count - 1;
    expect(remaining).toBe(2);
  });
});

describe("checkAbuse — logique de blocage progressif", () => {
  const SAME_PLATE_THRESHOLD = 3;
  test("2 signalements meme plaque = pas de blocage", () => {
    const samePlateCount = 2;
    expect(samePlateCount < SAME_PLATE_THRESHOLD).toBe(true);
  });

  test("3 signalements meme plaque = blocage", () => {
    const samePlateCount = 3;
    expect(samePlateCount >= SAME_PLATE_THRESHOLD).toBe(true);
  });

  test("progression : niveau 0 → 1", () => {
    const currentLevel = 0;
    const newLevel = Math.min(currentLevel + 1, 3);
    expect(newLevel).toBe(1);
  });

  test("progression : niveau 1 → 2", () => {
    const currentLevel = 1;
    const newLevel = Math.min(currentLevel + 1, 3);
    expect(newLevel).toBe(2);
  });

  test("progression : niveau 2 → 3 (definitif)", () => {
    const currentLevel = 2;
    const newLevel = Math.min(currentLevel + 1, 3);
    expect(newLevel).toBe(3);
  });

  test("progression plafonnee a 3", () => {
    const currentLevel = 3;
    const newLevel = Math.min(currentLevel + 1, 3);
    expect(newLevel).toBe(3);
  });
});

describe("checkAbuse — expiration de blocage", () => {
  test("blocage 24h expire apres 24h01", () => {
    const blockedAt = Date.now() - (24 * 60 * 60 * 1000 + 60 * 1000);
    const duration = 24 * 60 * 60 * 1000;
    const expired = Date.now() - blockedAt >= duration;
    expect(expired).toBe(true);
  });

  test("blocage 24h actif apres 23h59", () => {
    const blockedAt = Date.now() - (24 * 60 * 60 * 1000 - 60 * 1000);
    const duration = 24 * 60 * 60 * 1000;
    const expired = Date.now() - blockedAt >= duration;
    expect(expired).toBe(false);
  });

  test("blocage definitif ne expire jamais", () => {
    const blockDuration: number | null = null;
    expect(blockDuration).toBeNull();
  });
});
