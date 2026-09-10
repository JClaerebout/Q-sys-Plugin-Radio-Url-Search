# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and plays the selected stream through its embedded Q-SYS Media Stream Receiver.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Compatibility

**Plugin V3.0.0 and V3.1.0 require Q-SYS Designer V10.0 or later.**

If you use **Q-SYS Designer V9.13 or earlier**, use [plugin V2.1.0](https://github.com/JClaerebout/Q-sys-Plugin-Radio-Url-Search/releases/tag/V2.1.0).

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
- Play stations through an embedded Q-SYS Media Stream Receiver
- Select the receiver's network interface
- Monitor the receiver status
- Control stereo gain, polarity, and mute with peak-level metering
- Show the selected station as now playing
- Restore the now-playing station name from the current Media Stream Receiver stream URL
- Save and recall station presets (URL, name, and favicon) from a separate Presets page
- Configure between 1 and 40 preset slots, with Save, Recall, and Delete buttons

---

## Plugin Information

| Property | Value |
| --- | --- |
| Name | Radio Url Search |
| Version | 3.1.0 |
| Author | Jens Claerebout |
| Protocol | HTTPS / Radio Browser API |
| Embedded Q-SYS Component | Media Stream Receiver |

---

## Configuration

### Properties

| Property | Type | Default | Range | Description |
| --- | --- | --- | --- | --- |
| `Result Count` | Integer | 20 | 1-40 | Sets the number of visual station result controls and creates one result page per group of 10 |
| `Preset Count` | Integer | 10 | 1-40 | Sets the number of selectable slots on the Presets page |
| `Enable Favicon Pages` | Boolean | false | true/false | Shows the favicon result pages, now-playing artwork, and preset artwork. When disabled, Search and Presets remain available without artwork. |

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
| `ReceiverStatus` | Status Indicator | Mirrors the embedded Media Stream Receiver status |

#### Receiver Channel Controls

| Control | Type | Direction | Description |
| --- | --- | --- | --- |
| `channel.1.gain` | Float / dB | Input / Output | Channel 1 gain from -100 dB to +20 dB |
| `channel.1.invert` | Boolean | Input / Output | Channel 1 polarity inversion |
| `channel.1.mute` | Boolean | Input / Output | Channel 1 mute |
| `channel.1.peak.level` | Float / dBFS | Output | Channel 1 peak level meter |
| `channel.2.gain` | Float / dB | Input / Output | Channel 2 gain from -100 dB to +20 dB |
| `channel.2.invert` | Boolean | Input / Output | Channel 2 polarity inversion |
| `channel.2.mute` | Boolean | Input / Output | Channel 2 mute |
| `channel.2.peak.level` | Float / dBFS | Output | Channel 2 peak level meter |

#### Internal / UI Controls

These controls are used inside the plugin UI and are not exposed as user pins:

| Control | Type | Description |
| --- | --- | --- |
| `interface` | ComboBox | Selects the network interface used by the embedded receiver |
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

The plugin UI always contains Search and Presets pages. When `Enable Favicon Pages` is enabled, it also includes dynamically generated Results pages. The UI provides:

- Media Stream Receiver status
- Network interface selection
- Stereo channel gain, invert, mute, and peak-level controls
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
- connects to the embedded Media Stream Receiver
- lists the Core's available network interfaces
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
- selecting a station writes that station's stream URL to the embedded Media Stream Receiver
- `NowPlaying` is updated with the selected station name

### Media Stream Receiver Integration

When a station is selected, the plugin writes its stream URL to the embedded receiver's `url` control:

```text
embedded Media Stream Receiver -> url
```

### Station Presets

1. Play a station from Search or a Results page.
2. Open Presets and select a numbered slot.
3. Press **Save** to store its stream URL, full station name, and favicon URL. Saving replaces any station already in that slot.
4. Select a saved slot and press **Recall** to play it and update Now Playing.
5. Press **Delete** to clear the selected slot. Playback continues.

Selecting a slot only previews it; empty slots cannot be recalled or deleted. Recall uses the stored stream URL directly, without a Radio Browser lookup. Favicons are saved as URLs, so displaying artwork still requires network access.

Preset data is held in a persistent text control within the Q-SYS design. Save your design after configuring presets. Reducing `Preset Count` hides higher slots while retaining their data; increasing it makes them available again. Verify save/reopen and Core restart behavior during testing.

---

## Installation

1. Add the Radio URL Search plugin to your design
2. Connect its Channel 1 and Channel 2 audio outputs
3. Deploy to the Core
4. Select a network interface and country
5. Search for a station name
6. Select a station from the result list

---

## Notes

- An internet connection is required for Radio Browser API access
- The plugin uses the `de1.api.radio-browser.info` Radio Browser server
- Country selection defaults to `All`
- The Media Stream Receiver is embedded in the plugin and does not need to be added separately

---

## Known Limitations

- Search results are limited to the configured 1-40 visible stations

---

## Future Improvements

- Add clearer UI feedback for failed searches or unavailable API responses

---

## Changelog

### 3.1.0 - 2026-09-10

- Added a dedicated Presets page with configurable 1-40 slots (default 10).
- Added Save, Recall, and Delete buttons for station URLs, names, and favicons.
- Stored presets in a persistent text control and retained hidden slots when the preset count is reduced.
- Prevented delayed startup station lookups from replacing a newly selected or recalled station's details.
- Still requires Q-SYS Designer V10.0 or later. For V9.13 or earlier, use plugin V2.1.0.

### 3.0.0 - 2026-09-02

- Requires Q-SYS Designer V10.0 or later. For Q-SYS Designer V9.13 or earlier, use [plugin V2.1.0](https://github.com/JClaerebout/Q-sys-Plugin-Radio-Url-Search/releases/tag/V2.1.0).
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
