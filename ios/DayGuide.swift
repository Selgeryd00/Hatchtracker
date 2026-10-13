import Foundation

enum DayGuide {
    static let details: [String] = [
        "Celldelningen fortsätter och embryots tidiga strukturer börjar utvecklas.",
        "Hjärtats utveckling och tidig blodcirkulation pågår.",
        "Blodkärlen förgrenas; ögon och organ börjar ta form.",
        "Huvud, ögon och kroppsform blir tydligare.",
        "Anlag för ben och vingar utvecklas.",
        "Embryot växer och blodkärl kan bli synliga vid lysning.",
        "Första ordentliga lysningen: sök efter kärlnät och ett mörkt embryo.",
        "Fjäderanlag utvecklas och tillväxten fortsätter.",
        "Näbb och klor utvecklas vidare.",
        "Embryot växer snabbt och rörelser kan synas vid lysning.",
        "Organ, fjädrar och extremiteter fortsätter utvecklas.",
        "Embryot tar mer plats; luftblåsan är fortsatt viktig.",
        "Kycklingens form blir allt tydligare.",
        "En andra lysning kan hjälpa dig följa utveckling och luftblåsa.",
        "Kycklingen växer och använder näringen från gulan.",
        "Slutskedet närmar sig; förbered en säker uppfödningsplats.",
        "Kycklingen börjar orientera sig inför kläckningen.",
        "Avsluta normalt vändningen och förbered kläckningsläge.",
        "Kycklingen kan börja nå luftblåsan för första andningen.",
        "Vissa kycklingar gör första hålet i skalet; andra väntar.",
        "Många kycklingar kläcks omkring dag 21, men variation förekommer."
    ]
    static func detail(for day: Int) -> String {
        guard (1...21).contains(day) else { return "Kläckning tar normalt omkring 21 dygn. Kontrollera datum och följ utvecklingen." }
        return details[day - 1]
    }
    static func action(for day: Int) -> String {
        switch day {
        case ..<0: return "Förbered kläckaren och kontrollera inställningarna."
        case 0...6: return "Kontrollera temperatur, fukt och äggvändning. Undvik onödiga öppningar."
        case 7: return "Lys äggen försiktigt och notera osäkra resultat för senare kontroll."
        case 8...13: return "Följ temperatur och fukt. Kontrollera att vändningen fungerar."
        case 14: return "Följ upp med lysning och kontrollera luftblåsans utveckling."
        case 15...17: return "Förbered kläckningsfasen och kycklingarnas uppfödningsplats."
        case 18: return "Stoppa vändningen och följ maskinens instruktioner för kläckningsfukt."
        case 19...21: return "Håll kläckaren stabil och undvik onödiga öppningar."
        default: return "Följ upp kläckningsresultatet och kontrollera kycklingarnas välmående."
        }
    }
}
