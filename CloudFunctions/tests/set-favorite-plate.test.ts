describe("setFavoritePlate — logique de favori unique", () => {
  function applyFavoriteSelection(plateHashes: string[], targetHash: string | null) {
    if (targetHash && !plateHashes.includes(targetHash)) {
      throw new Error("not-found");
    }

    return plateHashes.map((hash) => ({
      hash,
      isFavorite: targetHash !== null && hash === targetHash,
    }));
  }

  test("une seule plaque peut etre favorite", () => {
    const result = applyFavoriteSelection(["a", "b", "c"], "b");
    expect(result.filter((plate) => plate.isFavorite)).toEqual([{ hash: "b", isFavorite: true }]);
  });

  test("retirer le favori remet toutes les plaques a false", () => {
    const result = applyFavoriteSelection(["a", "b", "c"], null);
    expect(result.every((plate) => plate.isFavorite === false)).toBe(true);
  });

  test("rejette une plaque absente de la selection utilisateur", () => {
    expect(() => applyFavoriteSelection(["a", "b"], "z")).toThrow("not-found");
  });
});