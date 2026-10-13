import SwiftUI
import UserNotifications

struct IncubationBatch: Codable {
    var startDate: Date = .now
    var eggs: Int = 26
    var title: String = "Min kläckning"
}

struct EggRecord: Identifiable, Codable {
    var id: Int
    var status: String = "I kläckaren"
    var note: String = ""
}

struct Measurement: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    var temperature: Double
    var humidity: Double
    var note: String
}

@MainActor
final class HatchStore: ObservableObject {
    @Published var batch = IncubationBatch() { didSet { save() } }
    @Published var eggs: [EggRecord] = [] { didSet { save() } }
    @Published var measurements: [Measurement] = [] { didSet { save() } }

    init() {
        if let data = UserDefaults.standard.data(forKey: "batch"), let decoded = try? JSONDecoder().decode(IncubationBatch.self, from: data) { batch = decoded }
        if let data = UserDefaults.standard.data(forKey: "eggs"), let decoded = try? JSONDecoder().decode([EggRecord].self, from: data) { eggs = decoded }
        if let data = UserDefaults.standard.data(forKey: "measurements"), let decoded = try? JSONDecoder().decode([Measurement].self, from: data) { measurements = decoded }
        if eggs.isEmpty { createMissingEggs() }
    }
    var day: Int { Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: batch.startDate), to: Calendar.current.startOfDay(for: .now)).day ?? 0 }
    var dueDate: Date { Calendar.current.date(byAdding: .day, value: 21, to: batch.startDate) ?? .now }
    var hatched: Int { eggs.filter { $0.status == "Kläckt" }.count }
    func createMissingEggs() {
        for number in 1...max(1, min(999, batch.eggs)) where !eggs.contains(where: { $0.id == number }) {
            eggs.append(EggRecord(id: number))
        }
    }
    func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(batch) { UserDefaults.standard.set(data, forKey: "batch") }
        if let data = try? encoder.encode(eggs) { UserDefaults.standard.set(data, forKey: "eggs") }
        if let data = try? encoder.encode(measurements) { UserDefaults.standard.set(data, forKey: "measurements") }
    }
    func scheduleReminder() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        guard granted else { return false }
        center.removePendingNotificationRequests(withIdentifiers: ["daily-incubation"])
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        let content = UNMutableNotificationContent()
        content.title = "HatchTracker"
        content.body = "Kontrollera dagens temperatur, luftfuktighet och äggens utveckling."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "daily-incubation", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true))
        return (try? await center.add(request)) != nil
    }
}

struct ContentView: View {
    @StateObject private var store = HatchStore()
    @State private var temperature = "37.5"
    @State private var humidity = "50"
    @State private var note = ""
    @State private var notice = ""
    private let orange = Color(red: 0.96, green: 0.53, blue: 0.34)

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AKTUELL KLÄCKNING").font(.caption.bold()).foregroundStyle(.orange)
                            Text("Dag \(max(0, store.day))").font(.system(size: 54, weight: .bold, design: .rounded))
                            ProgressView(value: min(1, max(0, Double(store.day) / 21))).tint(orange)
                            HStack {
                                Label("\(store.batch.eggs) ägg", systemImage: "circle.grid.3x3.fill")
                                Spacer()
                                Label("\(store.hatched) kläckta", systemImage: "checkmark.circle.fill")
                            }.font(.subheadline)
                            Text("Beräknad kläckning: \(store.dueDate.formatted(date: .abbreviated, time: .omitted))").foregroundStyle(.secondary)
                        }.padding(20).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                        GroupBox("Idag") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(DayGuide.action(for: store.day))
                                if store.day == 18 { Text("Avsluta äggvändningen och förbered kläckningen.").foregroundStyle(.orange) }
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 8)
                        }
                        GroupBox("Snabbregistrering") {
                            VStack(spacing: 12) {
                                TextField("Temperatur °C", text: $temperature).keyboardType(.decimalPad)
                                TextField("Luftfuktighet %", text: $humidity).keyboardType(.numberPad)
                                TextField("Anteckning (valfritt)", text: $note)
                                Button("Spara mätning") {
                                    guard let t = Double(temperature.replacingOccurrences(of: ",", with: ".")),
                                          let h = Double(humidity.replacingOccurrences(of: ",", with: ".")),
                                          (20...45).contains(t), (0...100).contains(h) else {
                                        notice = "Kontrollera temperatur och luftfuktighet."
                                        return
                                    }
                                    store.measurements.insert(Measurement(temperature: t, humidity: h, note: note), at: 0)
                                    note = ""
                                    notice = "Mätningen sparad."
                                }.buttonStyle(.borderedProminent).tint(orange)
                                if !notice.isEmpty { Text(notice).font(.caption).foregroundStyle(.secondary) }
                            }.textFieldStyle(.roundedBorder).padding(.vertical, 8)
                        }
                    }.padding()
                }.navigationTitle("HatchTracker")
            }.tabItem { Label("Idag", systemImage: "house.fill") }
            NavigationStack {
                List(1...21, id: \.self) { day in
                    NavigationLink {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Dag \(day)").font(.largeTitle.bold())
                                Text(DayGuide.detail(for: day))
                                Text("Att göra").font(.title3.bold())
                                Text(DayGuide.action(for: day))
                                Text("Utvecklingen varierar mellan ägg. Följ kläckarens manual och bedöm trender över tid.").font(.footnote).foregroundStyle(.secondary)
                            }.padding()
                        }.navigationTitle("Dag \(day)")
                    } label: {
                        HStack { Text("Dag \(day)"); Spacer(); if store.day == day { Text("Idag").foregroundStyle(.orange) } }
                    }
                }.navigationTitle("21 dagar")
            }.tabItem { Label("Dagguide", systemImage: "calendar") }
            NavigationStack {
                List {
                    Section {
                        Button("Skapa saknade äggkort") { store.createMissingEggs() }
                        Text("\(store.hatched) av \(store.eggs.count) kläckta").foregroundStyle(.secondary)
                    }
                    ForEach($store.eggs) { $egg in
                        NavigationLink {
                            Form {
                                Picker("Status", selection: $egg.status) {
                                    ForEach(["I kläckaren", "Utvecklas", "Osäkert", "Ej utvecklat", "Kläckt", "Avbrutet"], id: \.self) { Text($0) }
                                }
                                TextField("Anteckningar", text: $egg.note, axis: .vertical)
                            }.navigationTitle("Ägg \(egg.id)")
                        } label: { HStack { Text("Ägg \(egg.id)"); Spacer(); Text(egg.status).font(.caption).foregroundStyle(.secondary) } }
                    }
                }.navigationTitle("Mina ägg")
            }.tabItem { Label("Ägg", systemImage: "oval.portrait.fill") }
            NavigationStack {
                List(store.measurements) { m in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(m.temperature.formatted()) °C · \(m.humidity.formatted()) %").font(.headline)
                        Text(m.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary)
                        if !m.note.isEmpty { Text(m.note) }
                    }
                }.navigationTitle("Mätningar")
            }.tabItem { Label("Journal", systemImage: "list.bullet.clipboard") }
            NavigationStack {
                Form {
                    Section("Min kläckning") {
                        TextField("Namn", text: $store.batch.title)
                        DatePicker("Startdatum", selection: $store.batch.startDate, displayedComponents: .date)
                        Stepper("Antal ägg: \(store.batch.eggs)", value: $store.batch.eggs, in: 1...999)
                        Button("Skapa äggkort") { store.createMissingEggs() }
                    }
                    Section("Påminnelser") {
                        Button("Aktivera daglig påminnelse kl. 09") {
                            Task { notice = await store.scheduleReminder() ? "Påminnelsen är aktiverad." : "Tillåt notiser i iPhones inställningar."; }
                        }
                        if !notice.isEmpty { Text(notice).font(.caption) }
                    }
                    Section("Om appen") {
                        Text("Data sparas lokalt på enheten. Den här iOS-versionen synkar ännu inte med webbappen.")
                        Text("Dagguider är allmän information för hönsägg i kläckmaskin.")
                    }
                }.navigationTitle("Inställningar")
            }.tabItem { Label("Inställningar", systemImage: "gearshape.fill") }
        }.tint(orange)
    }
}
