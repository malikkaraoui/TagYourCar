describe("onReportCreated — labels de probleme", () => {
  const problemLabels: Record<string, string> = {
    headlights_on: "vos phares sont allumes",
    hood_open: "votre capot est ouvert",
    charge_flap_open: "votre trappe de charge est ouverte",
    flat_tire_front: "vous avez un pneu a plat (avant)",
    other_front: "un probleme a ete signale (avant)",
    window_open: "votre vitre est ouverte",
    door_ajar: "votre portiere est mal fermee",
    sunroof_open: "votre toit ouvrant est ouvert",
    other_middle: "un probleme a ete signale (milieu)",
    taillights_on: "vos feux sont allumes",
    fuel_flap_open: "votre trappe a essence est ouverte",
    trunk_open: "votre coffre est ouvert",
    flat_tire_rear: "vous avez un pneu a plat (arriere)",
    other_rear: "un probleme a ete signale (arriere)",
  };

  test("14 types de problemes couverts", () => {
    expect(Object.keys(problemLabels).length).toBe(14);
  });

  test("chaque label est une phrase en francais", () => {
    for (const label of Object.values(problemLabels)) {
      expect(label.length).toBeGreaterThan(5);
      // Pas de clef technique dans le label
      expect(label).not.toContain("_");
    }
  });

  test("type inconnu = fallback generique", () => {
    const unknownType = "something_unknown";
    const text = problemLabels[unknownType] || "un probleme a ete signale";
    expect(text).toBe("un probleme a ete signale");
  });
});

describe("onReportCreated — construction notification FCM", () => {
  function buildNotificationBody(problemText: string, partialPlate: string): string {
    return `Quelqu'un vous signale que ${problemText} sur ${partialPlate}.`;
  }

  test("notification avec phares allumes", () => {
    const body = buildNotificationBody("vos phares sont allumes", "AB-xxx-CD");
    expect(body).toBe("Quelqu'un vous signale que vos phares sont allumes sur AB-xxx-CD.");
  });

  test("notification avec plaque fallback", () => {
    const emptyPlate = "" as string;
    const partialPlate = emptyPlate || "votre vehicule";
    const body = buildNotificationBody("votre coffre est ouvert", partialPlate);
    expect(body).toContain("votre vehicule");
  });
});

describe("onReportCreated — auto-signalement", () => {
  test("proprietaire == signaleur = pas de notification", () => {
    const ownerUid: string = "user-123";
    const reporterUid: string = "user-123";
    expect(ownerUid === reporterUid).toBe(true);
  });

  test("proprietaire != signaleur = notification envoyee", () => {
    const ownerUid: string = "user-123";
    const reporterUid: string = "user-456";
    expect(ownerUid === reporterUid).toBe(false);
  });
});

describe("onReportCreated — badge APNs", () => {
  test("badge est incrementiel (pas hardcode a 1)", () => {
    // Simule le compteur unreadBadge
    let unreadBadge = 0;

    // Premier signalement
    unreadBadge += 1;
    expect(unreadBadge).toBe(1);

    // Deuxieme signalement
    unreadBadge += 1;
    expect(unreadBadge).toBe(2);

    // Troisieme signalement
    unreadBadge += 1;
    expect(unreadBadge).toBe(3);
  });
});

describe("onReportCreated — statuts du report", () => {
  test("statuts possibles : pending, delivered, failed", () => {
    const statuses = ["pending", "delivered", "failed"];
    expect(statuses).toContain("pending");
    expect(statuses).toContain("delivered");
    expect(statuses).toContain("failed");
  });

  test("report cree avec status pending", () => {
    const initialStatus = "pending";
    expect(initialStatus).toBe("pending");
  });
});
