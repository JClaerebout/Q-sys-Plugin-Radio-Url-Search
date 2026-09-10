# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and sends the selected stream URL to a Q-SYS URL Receiver component.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Compatibility

V2.1.0 is the V2 maintenance release for Q-SYS Designer V9.13 and earlier installations that support V2.0.0. It retains the external URL Receiver integration and does not embed a receiver.

For Q-SYS Designer V10.0 or later, [V3.1.0](https://github.com/JClaerebout/Q-sys-Plugin-Radio-Url-Search/releases/tag/V3.1.0) remains the latest release.

---

## Features

- Save station URLs, names, and favicon URLs in 1-40 preset slots (default 10)
- Use Save, Recall, and Delete on a dedicated Presets page
- Hide favicon pages and artwork by default with `Enable Favicon Pages`

- Search internet radio stations by name
- Filter station searches by country
- Configure between 1 and 40 visual station results
- Display up to 10 stations per result page in a two-column grid
- Show station favicons in search results and the now-playing area
- Filter searches across all countries or by a selected country
- Ignore stale responses when a newer search has started
- Hide broken stations from search results
- Select an existing Q-SYS URL Receiver component
- Write the selected station stream URL to the URL Receiver
- Show the selected station as now playing
- Restore the now-playing station name from the current URL Receiver stream URL

---

## Plugin Information

| Property | Value |
| --- | --- |
| Name | Radio Url Search |
| Version | 2.1.0 |
| Author | Jens Claerebout |
| Protocol | HTTPS / Radio Browser API |
| Required Q-SYS Component | URL Receiver |

---

## Configuration

### Properties

| Property | Type | Default | Range | Description |
| --- | --- | --- | --- | --- |
| `Preset Count` | Integer | 10 | 1-40 | Number of selectable preset slots |
| `Enable Favicon Pages` | Boolean | false | true/false | Shows Results pages and now-playing/preset artwork when enabled |
| `Result Count` | Integer | 20 | 1-40 | Sets the number of visual station result controls and creates one result page per group of 10 |

---

### Station Presets

Select a receiver and play a station, then select a slot on Presets and press Save. Save overwrites the slot; Recall tunes the selected receiver; Delete clears the slot without stopping playback. Presets store full names and original favicon URLs in a persistent text control. Save your Q-SYS design to retain its configured state. Reducing the preset count hides higher slots without deleting them.

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
| `ReceiverComponent` | ComboBox | Selects the Q-SYS URL Receiver component that will receive the stream URL |
| `Country_Code` | ComboBox | Selects the country used to filter station searches |
| `StrSearchResult` | ListBox | Displays matching radio stations on the Search page |
| `favicon` | Text Indicator / Media Display (1-40) | Shows station artwork for each configured result |
| `Name` | Text Indicator (1-40) | Shows the word-wrapped station name for each configured result |
| `SelectBtn` | Trigger (1-40) | Selects the corresponding configured station result |
| `NowPlayingFavicon` | Text Indicator / Media Display | Shows artwork for the active station |
| `code` | Text | Plugin code/debug text control |
| `PresetList` | ListBox | Selects a numbered preset slot without starting playback |
| `PresetName` / `PresetUrl` | Text Indicators | Show the selected preset's saved name and stream URL |
| `PresetFavicon` | Media Display | Shows the selected preset's artwork when favicon pages are enabled |
| `PresetSave` / `PresetRecall` / `PresetDelete` | Trigger Buttons | Save the current station, recall the selected slot, or clear it |
| `PresetStatus` | Text Indicator | Shows preset action feedback |
| `PresetData` | Hidden Text | Stores preset URLs, full station names, and original favicon URLs as JSON |

---

## UI Layout

The plugin UI always contains Search and Presets pages. Enable `Enable Favicon Pages` to show artwork and dynamically generated Results pages. The UI includes:

- URL Receiver component selection
- Country selection
- Station search field
- Search result list on page 1
- Result pages starting at page 2, with up to 10 artwork tiles per page
- Now-playing station name and artwork

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
- selecting a station writes that station's stream URL to the selected URL Receiver component
- `NowPlaying` is updated with the selected station name

### URL Receiver Integration

The plugin expects the selected receiver component to expose a `url` control. When a station is selected, the plugin writes the station stream URL to:

```text
selected URL Receiver -> url
```

---

## Installation

1. Add a Q-SYS URL Receiver component to your design
2. Add the Radio URL Search plugin to your design
3. Deploy to the Core
4. Select the URL Receiver component in the plugin UI
5. Select a country
6. Search for a station name
7. Select a station from the result list

---

## Notes

- An internet connection is required for Radio Browser API access
- The plugin uses the `de1.api.radio-browser.info` Radio Browser server
- Country selection defaults to `All`
- Only Q-SYS components of type `URL_receiver` are listed in the receiver dropdown
- The URL Receiver component must have a writable `url` control and have script acces

---

## Known Limitations

- Search results are limited to the configured 1-40 visible stations

---

## Future Improvements

- Add clearer UI feedback for failed searches or unavailable API responses

---

## Changelog

### 2.1.0 - 2026-09-10

- Backported configurable presets with Save, Recall, and Delete from V3.1.0.
- Added `Enable Favicon Pages`, disabled by default.
- Kept V2 external URL Receiver selection and no embedded components or audio pins.
- Guarded restored station details against stale requests and receiver changes.

---

## License

MIT License

---

## Author

Jens Claerebout
