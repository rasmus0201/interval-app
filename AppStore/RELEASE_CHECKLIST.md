# Udgivelsestjekliste

## Før arkivering

- Kontroller, at appnavnet Kyclaro er tilgængeligt i App Store Connect.
- Erstat `APP_BUNDLE_ID` i projektets Build Settings med et entydigt ID, som udgiveren ejer.
- Vælg udgiverens Apple Developer-team for app- og widget-targets i Xcode.
- Opdater udgiverens juridiske navn i `AppStore/en-US.md` og `AppStore/da-DK.md`.
- Publicer `docs/` med GitHub Pages, og kontroller alle seks webadresser: de engelske sider i roden og de danske sider under `da/`.
- Øg `CURRENT_PROJECT_VERSION` for hver upload til App Store Connect.
- Test en Release-build på mindst én fysisk iPhone med låst skærm.
- Kontroller lyd, vibration, Live Activity og afslutning af en fuld træning.

## App Store Connect

- Opret appen med samme bundle-ID som Xcode-projektet, og vælg engelsk (USA) som primært sprog.
- Tilføj dansk som ekstra lokalisering.
- Indsæt engelsk metadata fra `AppStore/en-US.md` og dansk metadata fra `AppStore/da-DK.md`.
- Angiv privatlivspolitikkens webadresse for hvert sprog, og svar, at appen ikke indsamler data.
- Angiv kategorierne Sundhed og fitness samt Hjælpeværktøjer.
- Udfyld aldersvurderingen.
- Upload skærmbillederne for hvert sprog fra `AppStore/Screenshots/en-US` og `AppStore/Screenshots/da-DK`. De viser opsætning, aktiv træning og historik. Kør `Tools/capture_screenshots.sh` for at tage dem igen.
- Indsæt App Review-noterne om baggrundslyd og Live Activity fra `AppStore/en-US.md`.
- Upload arkivet fra Xcode Organizer.
- Vælg buildet, og send det til App Review.

## Kendt kontrolpunkt

Appen afspiller en stille lydsløjfe under en aktiv træning. Det holder lydsessionen aktiv, så fasesignaler virker på låseskærmen. Funktionen er central for appens brug i en lomme. Apple kan kontrollere brugen af baggrundslyd under App Review.
