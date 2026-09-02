# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and sends the selected stream URL to a Q-SYS Media Stream Receiver component.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Features

- Search internet radio stations by name
- Filter station searches by country
- Configure between 1 and 40 visual station results
- Display up to 10 stations per result page in a two-column grid
- Show station favicons in search results and the now-playing area
- Filter searches across all countries or by a selected country
- Ignore stale responses when a newer search has started
- Hide broken stations from search results
- Select an existing Q-SYS Media Stream Receiver component
- Write the selected station stream URL to the Media Stream Receiver
- Show the selected station as now playing
- Restore the now-playing station name from the current Media Stream Receiver stream URL

---

## Plugin Information

| Property | Value |
| --- | --- |
| Name | Radio Url Search |
| Version | 3.0.0 |
| Author | Jens Claerebout |
| Protocol | HTTPS / Radio Browser API |
| Required Q-SYS Component | Media Stream Receiver |

---

## Configuration

### Properties

| Property | Type | Default | Range | Description |
| --- | --- | --- | --- | --- |
| `Result Count` | Integer | 20 | 1-40 | Sets the number of visual station result controls and creates one result page per group of 10 |
| `Enable Favicon Pages` | Boolean | false | true/false | Shows the favicon result pages and now-playing artwork. When disabled, only the Search page is shown and the now-playing name expands across the artwork area. |

---

### Control Pins

#### Inputs

| Control | Type | Description |
| --- | --- | --- |
| `StrSearch` | Text | Station name search text |

#### Outputs

| Control | Type | Description |
| --- | --- | --- |
| `NowPlaying` | Text Indicator | Shows the selected or restored station name |

#### Internal / UI Controls

These controls are used inside the plugin UI and are not exposed as user pins:

| Control | Type | Description |
| --- | --- | --- |
| `ReceiverComponent` | ComboBox | Selects the Q-SYS Media Stream Receiver component that will receive the stream URL |
| `Country_Code` | ComboBox | Selects the country used to filter station searches |
| `StrSearchResult` | ListBox | Displays matching radio stations on the Search page |
| `favicon` | Text Indicator / Media Display (1-40) | Shows station artwork for each configured result |
| `Name` | Text Indicator (1-40) | Shows the word-wrapped station name for each configured result |
| `SelectBtn` | Trigger (1-40) | Selects the corresponding configured station result |
| `NowPlayingFavicon` | Text Indicator / Media Display | Shows artwork for the active station |
| `code` | Text | Plugin code/debug text control |

---

## UI Layout

The plugin UI always contains a Search page. When `Enable Favicon Pages` is enabled, it also includes dynamically generated Results pages with:

- Media Stream Receiver component selection
- Country selection
- Station search field
- Search result list on page 1
- Result pages starting at page 2, with up to 10 artwork tiles per page
- Now-playing station name and optional artwork

---

## Communication

The plugin communicates with Radio Browser using HTTPS requests.

### Endpoints Used

| Endpoint | Method | Purpose |
| --- | --- | --- |
| `https://de1.api.radio-browser.info/json/countries` | GET | Retrieve available countries |
| `https://de1.api.radio-browser.info/json/stations/search` | GET | Search stations by name and country code |
| `https://de1.api.radio-browser.info/json/stations/byurl` | GET | Resolve the current stream URL back to a station name |

### Station Search

Searches are sent with:

- station name from `StrSearch`
- selected country code from `Country_Code`
- up to the configured number of displayed results, selected from a larger API response
- broken stations hidden
- displayed results ranked by Radio Browser click count

---

## Behavior

### Startup

When the plugin starts:

- it loads the `rapidjson` module
- reads available Q-SYS components
- adds components of type `URL_receiver` to the receiver dropdown
- loads the Radio Browser country list

### Country Selection

Changing the selected country:

- updates the active country code
- clears the search field
- clears the current search results

### Search Behavior

Typing in the search field triggers a Radio Browser station search. While searching, the results list temporarily shows `Searching...`.

When results are returned:

- station names remain available in the page 1 result list
- station names and favicons are also shown across the paged result grids
- selecting a station writes that station's stream URL to the selected Media Stream Receiver component
- `NowPlaying` is updated with the selected station name

### Media Stream Receiver Integration

The plugin expects the selected receiver component to expose a `url` control. When a station is selected, the plugin writes the station stream URL to:

```text
selected Media Stream Receiver -> url
```

---

## Installation

1. Add a Q-SYS Media Stream Receiver component to your design from Inventory -> Streaming I/O
2. Give the Media Stream Receiver Script acces.
3. Add the Radio URL Search plugin to your design
4. Deploy to the Core
5. Select the Media Stream Receiver component in the plugin UI
6. Select a country
7. Search for a station name
8. Select a station from the result list

---

## Notes

- An internet connection is required for Radio Browser API access
- The plugin uses the `de1.api.radio-browser.info` Radio Browser server
- Country selection defaults to `All`
- Only Q-SYS components of type `Media_Stream_receiver` are listed in the receiver dropdown
- The Media Stream Receiver component must have a writable `url` control and have script acces

---

## Known Limitations

- Search results are limited to the configured 1-40 visible stations

---

## Future Improvements

- Add favorites or presets
- Add clearer UI feedback for failed searches or unavailable API responses
- Integrate Media_Stream_Receiver into the plugin

---

## Changelog

### 3.0.0 - 2026-09-02

- Embedded the Q-SYS Media Stream Receiver in the plugin.
- Added receiver status, network interface selection, and stereo audio output pins.
- Added the `Enable Favicon Pages` property. Favicons do not always load reliably in UCI, so they are disabled by default.

### 2.0.0 - 2026-08-25

- Added configurable visual result counts from 1 to 40.
- Added paged station results with names, artwork, and selection buttons.
- Added country filtering and improved asynchronous search handling.
- Added now-playing artwork and station restoration from the receiver URL.

### 1.0.0 - 2026-06-11

- Initial release with Radio Browser search and receiver URL control.
- Added the `NowPlaying` output pin.

---

## License

MIT License

---

## Author

Jens Claerebout
