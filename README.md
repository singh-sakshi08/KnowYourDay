# KnowYourDay

Native iOS app: It is an application to rank 4 activities for 7 days depending on certain weather conditions of the searched city

## Problem
Build a native mobile application that allows a user to search for a city or town and rank how suitable the next 7 days will be for each of these activities:
        • Skiing
        • Surfing
        • Outdoor sightseeing
        • Indoor sightseeing
Use Open-Meteo for weather data:
        • Geocoding API
        • Forecast API
How you determine suitability, structure the application, manage state, and present
information is part of the problem. No backend is required

## Solution

## Feature List
        - Search for a city
        - Save the searched cities(in device) and display, and delete if needed 
        - Show the ranking of the activities for next 7 days, including present day
        
## Tech Stack

- Swift 5.9+, SwiftUI, SwiftData
- Structured concurrency (async/await, async let) for all networking
- No external dependencies. No SPM packages, no CocoaPods. Foundation + SwiftUI + SwiftData only
- APIs: Open-Meteo Geocoding, Forecast and Marine

## Requirements

- Xcode 15 or newer
- iOS 17 simulator/device minimum, the app uses `@Observable`, `SwiftData`, `Grid` and `ContentUnavailableView`, all iOS 17+ only

## How to Run

1. Open the project in Xcode.
2. Pick the `KnowYourDay` scheme, any iOS 17+ simulator.
3. Cmd+R.

## How to Review This App

Two screens, both reachable in a couple of taps.

**Screen 1:city search.** Type a city and hit search. The Geocoding call only fires on submit, not on every keystroke. Did this step intentionally, since the free API tier is limited. Tap a result and it gets saved to recent searches (SwiftData, so it survives app restarts) and takes you to Screen 2. When the search bar is empty you see your recent searches as cards, tap the minus icon on a card to remove it.

Testing values:
- A coastal city (Honolulu, Reykjavik): surfing gets a real score here.
- A landlocked city (Bengaluru): Marine API has nothing to return for this, so surfing quietly scores 0 and sits last in the ranking. This is expected behaviour, not a bug: no error is shown for it on purpose.
- A cold/mountain city in winter (Chamonix, Zermatt): good one to sanity check skiing scores against.

**Screen 2 : 7-day ranking for the city.** Top of the screen shows today's best activity, big icon and name. Below that:
- Grid 1: one column per day, just the top-ranked activity for that day.
- Grid 2: full ranking, all 4 activities per day, best to worst left to right.

Loads automatically the first time you land on the screen, pull-to-refresh re-fetches.

## Architecture

Went with MVVM architecture, with each screen has its own View, Model and ViewModel. Services and Persistence are shared with both the screens. Dependencies are injected through protocols(LocationSearchingProtocol, RankingProviding).

## Assumptions
- Weather is the only factor for activity considerations
-  If the weather is sunny/pleasant, rank indoor activities lowest
- Skiing and Surfing will only be treated as outdoor activities(no indoor surfing or skiing places would be considered)
- We assume that sports are of high priority
- We assume the latitude and longitude for one point is the same for complete city


## Rules
All the below logic is implemented in the **RankingService.swift** file. All the activities Skiing, Surfing and Outdoor Sightseeing are scored in the same basic way.

1. Hard Disqualifiers: If any activity scores hits any of the disqualifier condition from the sheet, they will be given 0 for the day.
2.  If the conditions vary in the range of Ideal to poor, the final score for the day on the particular activity will be average of all the bands
3. All the units of the parameters are same as mentioned in the sheet attached with the project link
        
**Surfing** additionally needs Marine API data (wave height + period) for
that date. If there's no marine data at all, most probably because the city is landlocked and the Marine API has nothing to return, then surfing just scores 0 for every day without any indication.

**Indoor Sightseeing is not scored against the weather at all** because of its independence from the weather. 
    It is calculated as **1-(average of other 3 activity's scores)**. Bad weather across the board pushes indoor toward 1.0, great weather pushes it toward 0.0
    
    **Tie Breakers** :
      There are two types of tie breakers and in both the cases I have kept a different order
      
        Non-Zero score Ties:   ["Skiing", "Surfing", "Outdoor", "Indoor"]
        Zero score Ties: ["Indoor", "Outdoor", "Surfing", "Skiing"]

## Testing
'RankingService' and 'Activity' are the only files that are actually tested in Unit test, everything else is verified manually for now.

## Known Limitations

- No caching layer, every visit to a city re-fetches Forecast + Marine fresh. Fine for this exercise, wouldn't ship a real product this way.
- No retry/backoff on a failed network call — you get an error state and pull-to-refresh as the recovery path, nothing automatic.
- Search history has no cap on size. Could grow unbounded on a device over a long time.
