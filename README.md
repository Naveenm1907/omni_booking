# OmniBooking

Multi-service booking app built with **Flutter + Riverpod + Firebase Firestore**.

## Features

- **Multi-service selection** with live total **price + duration**
- **3-counter availability logic** (slot finder assigns a counter ID)
- **Time slot grid** (9 AM–6 PM) using 15-minute intervals
- Booking confirmation that writes to Firestore
- Firestore **offline persistence/cache** enabled

## Tech

- **Flutter** (Material 3)
- **Riverpod** for state management
- **Firebase**: `firebase_core`, `cloud_firestore`

## Data model

### `services` collection

Document id: service id

```json
{
  "name": "Haircut",
  "durationMinutes": 30,
  "priceCents": 1500
}
```

### `bookings` collection

```json
{
  "startAt": "timestamp",
  "durationMinutes": 60,
  "counterId": 0,
  "serviceIds": ["haircut", "shave"],
  "totalPriceCents": 2300
}
```

## Slot finder algorithm (3 counters)

Implemented in `lib/utils/slot_finder.dart`.

- Generates candidate start times from **09:00 to 18:00** at **15-minute** steps.
- Uses **half-open time ranges** \([start, end)\) to detect overlaps.
- For each candidate slot, it checks counters `0..2` and assigns the **first** counter
  that has **no overlapping booking** for that time range.
- If **all 3 counters** overlap, the slot is **blocked**.

### Critical test case

Unit test: `test/slot_finder_test.dart`

Requirement: **a 60-minute service at 10:00 AM must be blocked** when every counter has an overlap with \([10:00, 11:00)\).

## Running locally

1. Install Flutter SDK
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run:

```bash
flutter run
```

## Notes / AI usage disclosure

This codebase was developed with assistance from an AI coding agent (Cursor) for:

- scaffolding Riverpod providers and screens
- implementing the slot finder algorithm + tests
- improving UI structure and documentation

All changes were reviewed and adjusted to keep `flutter analyze` clean and to keep commits small and phase-based.
