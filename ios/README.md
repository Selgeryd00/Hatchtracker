# HatchTracker för iPhone – SwiftUI

Detta är **källkod till en separat, riktig iOS-app**, inte en färdigsignerad .ipa. Den befintliga webbappen i repositoryts rot är oförändrad.

## Bygg i Xcode (Mac krävs för lokal iOS-byggning)

1. Öppna Xcode och välj **File → New → Project → iOS → App**.
2. Product Name: **HatchTracker**, Interface: **SwiftUI**, Language: **Swift**.
3. Ersätt den genererade `HatchTrackerApp.swift` med filen här och lägg till `ContentView.swift` och `DayGuide.swift` i appens target. Ta bort eller ersätt den ursprungliga ContentView-filen för att undvika dubbletter.
4. Välj ditt **Team** under **Signing & Capabilities** och ett unikt **Bundle Identifier** (t.ex. `se.selgeryd.hatchtracker`, om ledigt).
5. Sätt Deployment Target till **iOS 17 eller senare**.
6. Bygg och kör på iPhone från Xcode. Godkänn notiser i appen om du vill ha daglig påminnelse.
7. För TestFlight: registrera Apple Developer Program, skapa appen i App Store Connect, välj **Product → Archive**, distribuera via **Distribute App → App Store Connect** och konfigurera TestFlight.

## Begränsningar

- iOS-appen använder egen lokal lagring via UserDefaults och delar **inte automatiskt** data med webbappen. Import/synk behöver byggas separat.
- Äggkort, mätningar och dagguide finns. Påminnelse kl. 09 använder lokala iOS-notiser efter användarens tillstånd.
- Projektfilerna är Swift-källkod; Xcode-projektfil, signering, test på fysisk iPhone och App Store-uppladdning är ännu inte genomförda.
- För produktionsversion rekommenderas fler tester, dataexport, flera omgångar, tillgänglighetsgranskning och appikon i Apples föreskrivna format.
