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
- For each candidate slot, it checks counters `0..2`:
  - counts how many counters can fit the slot (**spots left**)
  - assigns the **first available counter** as `counterId` (for booking summary)
- If **all 3 counters** overlap, the slot is **blocked** and shows **0 spots left**.

### Critical test case

Unit test: `test/slot_finder_test.dart`

Requirement: **a 60-minute service at 10:00 AM must be blocked** when every counter has an overlap with \([10:00, 11:00)\).

## Company assignment demo mode (provided existing bookings)

By default the app runs in **Demo mode** (deterministic review). It uses the exact “Existing Bookings” dataset from the assignment:

- Counter 1: **10:00–11:00**
- Counter 2: **10:30–11:30**
- Counter 3: **09:00–10:30**

This is implemented in:

- `lib/utils/demo_existing_bookings.dart`
- `demoModeProvider` in `lib/providers/firestore_providers.dart`

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
