# CIANTIS Calendar

Standalone Flutter calendar module based on the approved CIANTIS calendar mockup.

## Visual direction
- Warm ivory background
- Elegant serif Calendar title
- Borderless, icon-only universal CIANTIS bottom navigation
- Active Calendar icon sits higher than the inactive icons
- Day / Week / Month / Year tabs with the active tab taller and softly filled
- Large rounded month card
- Tiny subject-color event dots beneath dates
- Minimal Upcoming rows beneath the calendar
- No harsh borders, bright colors, or generic Material calendar styling

## Included behavior
- Day, Week, Month, and Year views
- Previous / next month controls
- Month/year picker
- Date selection and double-tap into Day view
- Add, edit, and delete calendar entries
- Swipe-to-delete Upcoming rows
- Persistent local storage with SharedPreferences
- CIANTIS subject colors for Birthday, Appointment, Meeting, Task, Reminder, Work, School, Family, Travel, Finance, Health, Salon, and Spiritual

## Chrome-ready setup
The Flutter web entry files are already included in `web/`.

### Easiest Windows launch
From the `calendar_app` folder, run:

```powershell
.\run_chrome.ps1
```

### Manual launch
```powershell
flutter config --enable-web
flutter pub get
flutter run -d chrome
```

A GitHub Actions workflow at `.github/workflows/calendar-web-check.yml` also runs Flutter analyze and a release web build when calendar files change.
