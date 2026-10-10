# Kyclaro – implementeringsbrief til AI-kodeagent

## Opgave

Færdiggør **Kyclaro Timer version 1.0** til den første App Store-udgivelse.

Projektet ligger her:

https://github.com/rasmus0201/interval-app

**Vigtigt: Implementér kun trin 2 i denne opgave.** Trin 3, 4 og 5 er fremtidige udviklingsplaner og skal dokumenteres, men ikke implementeres.

Start med at undersøge den aktuelle kodebase, arkitektur, tests og eksisterende funktioner. Brug koden som sandhedskilde frem for at antage, at nedenstående beskrivelser er fuldstændige.

## 1. Produktvision

Kyclaro er en native iPhone-app bygget i SwiftUI.

Formålet er at tilbyde en enkel, flot og pålidelig intervaltimer til træning.

Appens vigtigste principper er:

- Hurtig opsætning uden unødvendige skærme.
- Meget tydeligt countdown-display.
- Fuld fokus på træningen.
- Mulighed for at bruge appen uden at se på telefonen.
- Lyd og vibration ved faseskift.
- Funktionalitet på låseskærmen.
- Ingen konto, reklamer eller nødvendig internetforbindelse.
- Lokal lagring af indstillinger og træningshistorik.
- Native Apple-teknologier frem for tredjepartsafhængigheder.

Appen skal føles som et gennemarbejdet iOS-produkt, ikke som en kompleks fitnessplatform.

Navn i App Store: **Kyclaro Timer**.

Navn på hjemmeskærmen: **Kyclaro**.

Primær kategori: Health & Fitness.

Der skal fortsat understøttes dansk og engelsk.

## 2. Eksisterende funktionalitet – bevar denne

Kyclaro har allerede:

- Konfigurerbar arbejdstid.
- Konfigurerbar hviletid.
- Antal gentagelser og runder.
- Ekstra pause mellem runder.
- Startnedtælling på 0, 10, 30 eller 60 sekunder.
- Pause, fortsæt, spring over og genstart.
- Tydeligt countdown med fasefarver.
- Lydsignaler og vibration.
- Separat aktivering af biplyde og vibration.
- Justerbar lydstyrke til signaler.
- Lyd under låst skærm.
- Live Activity på låseskærm og i Dynamic Island.
- Lokal træningshistorik.
- Genbrug af tidligere træningskonfigurationer.
- Lokal lagring af indstillinger.
- Dansk og engelsk brugerflade via String Catalog.

**Ingen eksisterende funktionalitet må fjernes eller forringes.**

Eksisterende UI-design skal bevares, medmindre en ændring er nødvendig for den nye funktionalitet.

Læs især:

- `PRODUCT.md`
- `DESIGN.md`
- `README.md`
- `Interval/WorkoutEngine.swift`
- `Interval/AudioCueService.swift`
- `Interval/Models.swift`
- `Interval/AppStore.swift`
- `Interval/RootView.swift`
- `Interval/WorkoutView.swift`
- `Interval/SettingsView.swift`
- `Interval/Localizable.xcstrings`

Bemærk, at den eksisterende timerlogik ikke nødvendigvis har hvile efter hver gentagelse. Respektér den faktiske træningsmodel og ændr ikke intervalstrukturen som en utilsigtet del af denne opgave.

---

# TRIN 2 – IMPLEMENTÉR NU

## 3. Talte cues (AVSpeechSynthesizer)

Tilføj mulighed for taleinstruktioner under en træning.

Brug Apples `AVSpeechSynthesizer` og eksisterende lydarkitektur, hvor det er hensigtsmæssigt.

### Funktionalitet

Når talte cues er aktiveret, skal appen kunne annoncere:

**Start af træning:**
- "Get ready" / "Gør dig klar", når relevant.
- "Start" eller "Work" / "Arbejde", når arbejdsfasen starter.

**Under træningen:**
- "10 seconds remaining" / "10 sekunder tilbage".
- "Rest" / "Hvile" ved hvile.
- "Round 2 of 5" / "Runde 2 af 5" ved ny runde.
- "Round break" / "Rundepause" ved særskilt rundepause.

**Afslutning:**
- "Workout complete" / "Træningen er færdig".

Brug naturlige formuleringer og korrekt dansk/engelsk lokalisering.

Undgå for mange beskeder. Taleinstruktioner skal være korte og give mening under fysisk aktivitet.

Ti-sekundersadvarslen skal kun afspilles, når en relevant fase varer længe nok.

### Indstillinger

Tilføj en separat indstilling:

**Spoken cues / Talte beskeder**

- Skal kunne aktiveres/deaktiveres.
- Skal være slået fra som standard, så eksisterende brugere ikke oplever en uventet ændring.
- Gemmes lokalt sammen med de øvrige `AppSettings`.
- Skal fungere uafhængigt af eksisterende biplyde og vibration.
- Skal bruge korrekt sproglokalisering.
- Skal respektere enhedens lydindstillinger og eksisterende audio session så vidt muligt.

Integrér indstillingen naturligt i den eksisterende Settings-skærm.

Undgå at ændre mere af designet end nødvendigt.

### Teknisk kvalitet

Vær særligt opmærksom på:

- Talte beskeder må ikke overlappe hinanden uhensigtsmæssigt.
- En besked må ikke gentages ved almindelige timer-opdateringer.
- Pause må ikke forårsage nye fasebeskeder.
- Genoptagelse må ikke afspille den samme besked igen.
- Spring over og genstart skal håndtere igangværende tale korrekt.
- Afslutning og annullering skal stoppe eventuelle planlagte eller igangværende beskeder.
- Tale og biplyde må ikke skabe en kaotisk lydoplevelse.
- Manglende eller afbrudt tale må aldrig påvirke selve timeren.
- Appen skal fortsat kunne køre offline.

Den eksisterende `WorkoutEngine` benytter tidsbaseret synkronisering. Nye cue-events må ikke afspilles gentagne gange, hvis appen har været i baggrunden og indhenter tabt tid.

Test specifikt tale med låst skærm på en fysisk iPhone. Hvis iOS begrænser afspilning i bestemte tilstande, skal dette dokumenteres frem for at omgås med skrøbelige løsninger.

Overvej at isolere beslutningen om, *hvornår* en besked skal afspilles, fra selve taleafspilningen. Det vil gøre logikken nemmere at enhedsteste og genbruge senere.

## 4. Siri og App Intents

Tilføj understøttelse af Siri og Shortcuts via Apples App Intents-framework.

### Primær funktion

Brugeren skal kunne starte sin senest anvendte træningskonfiguration med en genvej.

Eksempler på ønsket brugeroplevelse:

- "Start my Kyclaro workout"
- "Start min Kyclaro-træning"

Brug passende `AppIntent` og `AppShortcutsProvider`, så handlingen kan findes i Genveje/Shortcuts og anvendes med Siri på understøttede enheder og sprog.

Kontrollér de faktiske muligheder i den iOS-version, projektet understøtter, og lov ikke Siri-formuleringer eller låseskærmsadfærd, som systemet ikke kan garantere.

### Forventet opførsel

Når brugeren aktiverer genvejen:

1. Find den senest anvendte/gemte træningskonfiguration fra appens eksisterende datalager.
2. Hvis der ikke findes en brugerdefineret konfiguration, anvend appens normale standardopsætning.
3. Åbn appen i den aktive træningsvisning.
4. Start træningen gennem den eksisterende `WorkoutEngine`.
5. Bevar Live Activity, lyd, vibration og eventuelle talte cues.

Der må ikke oprettes en separat timer-motor specielt til Siri.

Hvis en træning allerede er aktiv, må intent-handlingen ikke skabe en parallel træningssession eller nulstille den uden brugerens accept.

Brug en robust mekanisme til at føre intent-handlingen ind i den eksisterende app-navigation/sessionstilstand.

Undgå at starte en træning både inde i intent-koden og ved `WorkoutView.onAppear`.

### Integrationer

Den samme genvej skal så vidt muligt kunne bruges via:

- Siri.
- Apple Shortcuts.
- iPhones Action-knap via en Shortcut, hvor det understøttes.

En selvstændig Control Center-kontrol kan undersøges som en senere forbedring, hvis det kræver yderligere WidgetKit-/Control Widget-arbejde. Det må ikke forsinke version 1.0.

### Designprincip

App Intents skal være en lille, native integration.

Ingen nye hovedfaner, onboarding-flows, backend eller brugerkonti.

---

## 5. Lokalisering

Appen understøtter allerede dansk og engelsk.

Udbyg den eksisterende `Localizable.xcstrings` i stedet for at opfinde et nyt lokaliseringssystem.

Alle nye UI-tekster, intent-titler, beskeder og taleinstruktioner skal understøtte begge sprog.

Tale skal bruge en passende stemme for det valgte sprog. Sørg for en fornuftig fallback, hvis en foretrukken stemme ikke er installeret.

Kontrollér at nye tekster fungerer med Dynamic Type og VoiceOver.

## 6. Eksisterende arkitektur

Bevar som udgangspunkt den nuværende projektstruktur.

Relevante komponenter:

- `WorkoutEngine`: timerens tilstand og faseovergange.
- `AudioCueService`: eksisterende lyd og vibrationssignaler.
- `AppSettings`: brugerindstillinger.
- `AppStore`: lokal lagring og aktuel træningskonfiguration.
- `RootView`: hovednavigation og aktiv session.
- `WorkoutView`: aktiv træning.
- `SettingsView`: konfiguration af feedback.
- `WorkoutTimeline`: opbygning af den eksisterende træningssekvens.

Ny funktionalitet skal placeres, hvor den naturligt hører hjemme.

Det er acceptabelt at introducere små nye services eller filer til speech og App Intents.

Undgå unødvendig refaktorering af hele projektet.

Projektets Xcode-filer genereres via `Tools/generate_project.rb`. Følg den eksisterende arbejdsgang, når nye kildefiler tilføjes.

Respektér nuværende deployment target og anvend kun API'er, som er kompatible med det, eller brug korrekt availability-håndtering.

## 7. Tests og kvalitetssikring

Implementér relevante automatiserede tests.

Minimum:

**Talte cues**
- Nye indstillinger gemmes og indlæses korrekt.
- Ældre gemte indstillinger kan stadig indlæses uden fejl.
- Ingen tale når funktionen er deaktiveret.
- Tale-events opstår på de korrekte faseovergange.
- Ti-sekundersadvarsel afspilles højst én gang pr. relevant fase.
- Ingen unødige gentagelser efter pause/genoptagelse.
- Spring over, genstart og stop håndterer cues korrekt.

**Siri/App Intents**
- Den korrekte gemte konfiguration vælges.
- Standardkonfiguration bruges, når relevant.
- Der opstår ikke dobbelte aktive sessioner.
- Den eksisterende træningshistorik og timer fungerer uændret.

**Regression**
- Eksisterende biplyde og vibration fungerer.
- Live Activity fungerer.
- Countdown er stadig korrekt.
- Sessioner afsluttes korrekt.
- Historik gemmes kun som hidtil.
- Alle eksisterende tests består.

Test desuden manuelt på fysisk iPhone, især Siri, låseskærm, baggrundslyd og tale. Skeln i afrapporteringen mellem det, der er automatiseret testet, og det, der kræver fysisk enhed.

---

# FREMTIDIG ROADMAP – IMPLEMENTÉR IKKE ENDNU

## Trin 3 – Kyclaro Pro

Dette bliver den første egentlige betalingsversion.

**Foreløbig pris: 39–49 DKK som engangskøb.**

Planlagte Pro-funktioner:

- Gem og navngiv træningsprogrammer.
- Flere genanvendelige presets.
- Sammensatte workouts med flere blokke.
- Opvarmning, intervaller og nedkøling i samme program.
- EMOM (Every Minute On the Minute).
- AMRAP (As Many Rounds/Reps As Possible).
- Eventuelt særlige presets til boxing og anden intervaltræning.

Eksempel på sammensat workout:

1. Opvarmning – 5 minutter.
2. Tabata – 8 × 20/10 sekunder.
3. Pause – 2 minutter.
4. EMOM – 10 minutter.
5. Nedkøling – 4 minutter.

Fremtidig monetisering skal som udgangspunkt bruge StoreKit 2.

Kernefunktionerne i Kyclaro skal fortsat være gratis og brugbare.

Ingen abonnementer eller reklamer som udgangspunkt.

Dette trin skal **ikke** bygges nu. Det må højst påvirke små arkitekturbeslutninger, hvis det kan ske uden ekstra kompleksitet.

## Trin 4 – Apple Health / HealthKit

Fremtidig integration med Apple Health.

Mål:

- Brugeren kan give eksplicit tilladelse til at gemme træningssessioner.
- Afsluttede sessioner kan registreres som workouts i Apple Sundhed.
- Passende træningstype og varighed.
- Undgå dobbelte registreringer.
- Fungere uden HealthKit-tilladelse.
- Bevare privatliv og minimere dataadgang.

Denne funktion skal som udgangspunkt være gratis, ikke en Pro-betaling.

Ingen HealthKit-kode, tilladelser eller entitlements i den aktuelle opgave.

## Trin 5 – Apple Watch

På sigt ønskes en rigtig watchOS-app.

Målet er ikke blot en fjernbetjening til iPhone, men en selvstændig træningstimer.

Mulige funktioner:

- Start og gennemfør træning direkte fra uret.
- Tydeligt countdown.
- Haptisk feedback ved faseovergange.
- Aktuel runde, gentagelse og interval.
- Puls under træningen.
- HealthKit workout sessions.
- Synkronisering af relevante programmer og resultater mellem iPhone og Watch.
- Understøttelse af træning uden telefonen i nærheden.

Apple Watch kan blive en væsentlig differentierende funktion og eventuelt være en del af Pro-tilbuddet. Den konkrete betalingsmodel besluttes senere.

Ingen watchOS-targets eller HealthKit-afhængigheder i denne opgave.

---

# FORRETNING OG ANDRE PRODUKTIDÉER

## Overordnet strategi

Kyclaro skal være en enkel, gennemført app med mulighed for beskeden sideindtægt.

Vi forventer ikke automatisk store indtægter på det konkurrenceprægede marked for intervaltimere.

Strategien er:

- En rigtig god gratis app.
- Eventuelt et rimeligt prissat engangskøb til avancerede funktioner.
- Ingen reklamer.
- Ingen nødvendig brugerregistrering.
- Ingen serveromkostninger, hvis de kan undgås.
- Fokus på tilfredse brugere og en god App Store-oplevelse.
- Undersøg Apple Small Business Program ved monetisering.

En frivillig "Støt udvikleren"-funktion kan overvejes senere, men er ikke vigtig for den første udgivelse.

## Mulige fremtidige søster-apps

Disse er idéer, ikke aktuelle udviklingsopgaver:

- Sauna- og vinterbadningstimer.
- Stræk- og mobilitetstimer med guidede intervaller.
- Walk/Run-app med begynderløbeprogrammer.
- Styrketræningsapp med pausetimer og sætregistrering.
- Pomodoro/fokustimer.
- Mac-app til generering og validering af App Store-screenshots.

Eventuel genbrug af Kyclaros timer-motor kan undersøges senere.

Opret ikke en separat Swift Package blot for at forberede disse idéer, medmindre det giver en konkret fordel allerede nu.

---

# APP STORE OG UDGIVELSE

## Nuværende situation

Kyclaro forberedes til sin første udgivelse i App Store Connect.

App Store-metadata findes i:

- `AppStore/en-US.md`
- `AppStore/da-DK.md`
- `AppStore/RELEASE_CHECKLIST.md`

Der findes også screenshots og scripts til at generere dem.

Appen skal fortsat markedsføres som en enkel intervaltimer med klare signaler, offlinefunktionalitet og Lock Screen-understøttelse.

### Metadata

Kontrollér, at beskrivelserne er korrekte efter implementeringen.

Når talte cues og Siri fungerer og er testet, kan de nævnes som ekstra features.

Opdatér eventuelt:

- Engelsk og dansk beskrivelse.
- Release notes.
- App Review Notes.
- README.
- Relevante produktspecifikationer og dokumentation.

Ingen funktioner må markedsføres som eksisterende, før de faktisk er implementeret.

### Screenshots

Der er tidligere genereret screenshots af:

1. Træningsopsætning.
2. Aktiv træning.
3. Træningshistorik.

Der findes billeder til iPhone Dynamic Island i både large og medium display-formater. Medium-versionerne blev lavet i 1206 × 2622 pixels.

App Store Connects nye Asset Library har tidligere givet en valideringsfejl om manglende medium-display-screenshots, selv om de var uploadet. Det kan være et spørgsmål om tilknytning til produktversion/lokalisering. Det er en separat manuel udgivelsesopgave, ikke en fejl i timerkoden.

Agenten skal ikke forsøge at ændre App Store Connect uden særskilt instruktion.

### App Review og baggrundslyd

Den eksisterende app benytter en aktiv lydsession og en stille lydsløjfe under træning for at understøtte lyd på låseskærmen.

Bevar funktionaliteten, men undersøg om tilføjelsen af talesyntese påvirker stabilitet, batteriforbrug eller Apples retningslinjer.

Undgå unødvendig baggrundsaktivitet.

Dokumentér eventuelle risici, især hvis teknikken kan give problemer ved App Review.

Bevar den eksisterende privatlivsmodel uden netværk eller indsamling af persondata. Opdatér kun privacy-dokumentation, hvis den faktiske databehandling ændres.

---

# ARBEJDSPROCES FOR AI-AGENTEN

1. Undersøg først den aktuelle kodebase og Git-status.
2. Identificér hvilke filer og komponenter der skal ændres.
3. Implementér talte cues og tilhørende indstillinger.
4. Implementér Siri/App Intents og Shortcuts.
5. Kontrollér begge lokaliseringer.
6. Udvid automatiserede tests.
7. Byg og kør tests i Xcode, hvis miljøet tillader det.
8. Kontrollér at eksisterende funktioner ikke er ødelagt.
9. Opdatér relevant dokumentation og release-metadata.
10. Giv en klar afrapportering af ændringer, testresultater og eventuelle tilbageværende opgaver.

Undgå store omstruktureringer, nye tredjepartsbiblioteker og uvedkommende forbedringer.

Ved commits skal den aktuelle branch først kontrolleres. Hvis branchnavnet indeholder en Jira-sagsnøgle i formatet `DEV-123` eller `SEN-123`, bruges denne nøgle som præfiks i commitbeskeden.

Undgå at ændre version, buildnummer, bundle-ID, signing team eller udgivelsesindstillinger uden nødvendighed.

## Definition of Done

Opgaven er færdig, når:

- Talte cues fungerer med dansk og engelsk.
- Brugeren kan slå talte cues til og fra.
- Indstillingen overlever genstart.
- Eksisterende lyd og vibration fortsat fungerer.
- Siri/Shortcuts kan starte en træning med den gemte konfiguration.
- Der ikke opstår parallelle træningssessioner.
- Eksisterende timer, historik og Live Activity fungerer.
- Appen fortsat fungerer uden konto og internet.
- Alle relevante automatiserede tests består, eller eventuelle blokeringer er dokumenteret.
- Funktioner, der kræver en fysisk iPhone, er testet eller eksplicit markeret til manuel validering.
- Dokumentation og App Store-tekster er opdateret efter behov.

**Det vigtigste er en stabil og enkel første udgivelse.**

Byg kun trin 2 nu. Trin 3, 4 og 5 skal vente til efter den første App Store-udgivelse.

Afslut med en kort opsummering af, hvad du har implementeret, hvilke filer du har ændret, hvilke tests du har kørt, samt hvad jeg konkret skal teste på min iPhone inden udgivelsen.
