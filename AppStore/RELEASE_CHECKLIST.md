# Udgivelsestjekliste

## Før arkivering

- Vælg det endelige appnavn og opdater `CFBundleDisplayName` i `Interval/Info.plist`.
- Erstat `APP_BUNDLE_ID` i projektets Build Settings med et entydigt ID, som udgiveren ejer.
- Vælg udgiverens Apple Developer-team for app- og widget-targets i Xcode.
- Opdater udgiverens juridiske navn i `AppStore/da-DK.md`.
- Publicer `docs/` med GitHub Pages, og kontroller alle tre webadresser.
- Øg `CURRENT_PROJECT_VERSION` for hver upload til App Store Connect.
- Kontroller appnavnets tilgængelighed i App Store Connect.
- Test en Release-build på mindst én fysisk iPhone med låst skærm.
- Kontroller lyd, vibration, Live Activity og afslutning af en fuld træning.

## App Store Connect

- Opret appen med samme bundle-ID som Xcode-projektet.
- Indsæt metadata fra `AppStore/da-DK.md`.
- Angiv privatlivspolitik og svar, at appen ikke indsamler data.
- Angiv kategorierne Sundhed og fitness samt Hjælpeværktøjer.
- Udfyld aldersvurderingen.
- Upload skærmbilleder, som viser opsætning, aktiv træning og historik.
- Indsæt App Review-noterne om baggrundslyd og Live Activity.
- Upload arkivet fra Xcode Organizer.
- Vælg buildet, og send det til App Review.

## Kendt kontrolpunkt

Appen afspiller en stille lydsløjfe under en aktiv træning. Det holder lydsessionen aktiv, så fasesignaler virker på låseskærmen. Funktionen er central for appens brug i en lomme. Apple kan kontrollere brugen af baggrundslyd under App Review.
