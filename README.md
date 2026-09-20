# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and sends the selected stream URL to a Q-SYS URL Receiver component.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Compatibility

V2.3.0 is the V2 maintenance release targeting Q-SYS Designer V9.13. It retains the external URL Receiver integration and does not embed a receiver.

For Q-SYS Designer V10.0 or later, use V3.4.0 with its embedded receiver.

---

## Features

- Save station URLs, names, and favicon URLs in 1-40 preset slots (default 10)
- Use Save, Recall, and Delete on a dedicated Presets page
- Show or hide logo pages and artwork with `Enable Logo Pages` (enabled by default)

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
| Version | 2.3.0 |
| Author | Jens Claerebout |
| Protocol | HTTPS / Radio Browser API |
| Required Q-SYS Component | URL Receiver |

---

## Configuration

### Properties

| Property | Type | Default | Range | Description |
| --- | --- | --- | --- | --- |
| `Preset Count` | Integer | 10 | 1-40 | Number of selectable preset slots |
| `Enable Logo Pages` | Boolean | true | true/false | Shows Results pages and now-playing/preset artwork when enabled |
| `Result Count` | Integer | 20 | 1-40 | Sets the number of visual station result controls and creates one result page per group of 10 |

---

**Result-button text colour:** Station names use native Q-SYS button text. Set Text Color on the ResultName controls in Designer/UCI.

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


| `SelectBtn` / `ResultName` | Trigger Buttons (1-40 each) | SVG artwork occupies the left quarter and centered native station text occupies the right three quarters; either button selects the station |
| `StationLogo` | Momentary Button | Displays the active station logo using SVG |
| `code` | Text | Plugin code/debug text control |
| `PresetList` | ListBox | Selects a numbered preset slot without starting playback |
| `PresetName` / `PresetUrl` | Text Indicators | Show the selected preset's saved name and stream URL |
| `PresetFavicon` | Momentary Button / SVG | Shows the selected preset's artwork when logo pages are enabled |
| `PresetSave` / `PresetRecall` / `PresetDelete` | Trigger Buttons | Save the current station, recall the selected slot, or clear it |
| `PresetStatus` | Text Indicator | Shows preset action feedback |
| `PresetData` | Hidden Text | Stores preset URLs, full station names, and original favicon URLs as JSON |

---

## UI Layout

The plugin UI always contains Search and Presets pages. Enable `Enable Logo Pages` to show artwork and dynamically generated Results pages. The UI includes:

- URL Receiver component selection
- Country selection
- Station search field
- Search result list on page 1
- Result pages starting at page 2, with up to 10 artwork tiles per page
- Now-playing station name and artwork

---

Search and Presets use an approximately 560 × 420 layout with compact 12-point labels, aligned fields, and thin group borders with a corner radius of 5. Result pages use the same border styling with tighter spacing between station tiles.

Station artwork fits within a consistent 56 × 56 area on all pages, preserving its proportions. The image service conservatively trims uniform outer padding before resizing so padded logos fill more of the available space. Logos sit inside a small safety margin on a rounded white tile; the artwork itself is not clipped. Transparent areas show the white tile, and backgrounds within the logo itself are retained. Unusual shapes or nonuniform padding can still produce differences in apparent size.

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

### Station Artwork

When logo pages are enabled, the Core downloads artwork using `HttpClient.Download` through `images.weserv.nl`, requesting a PNG fitted within 300 × 300 pixels. Each PNG is base64-encoded inside an SVG `<image>` with `preserveAspectRatio="xMidYMid meet"`; the complete SVG is then base64-encoded into the button Legend's JSON `IconData`, with `DrawChrome=false`. No EzSVG dependency is needed. UCI clients receive the embedded artwork rather than downloading favicon URLs themselves.

Artwork buttons stay enabled to avoid Q-SYS dimming their SVGs in Live/Emulate. The Now Playing and preset artwork handlers immediately clear presses without tuning. Each result tile has SVG artwork in the left quarter and a native station-name button in the right three quarters. Station names are centered and wrap within the text area. Use the normal Designer/UCI text settings to customize their appearance. Pressing either area selects the station. Missing or invalid favicon URLs, failed downloads, non-200 responses, unexpected Content-Type, empty data, and structurally invalid PNGs show a locally generated radio icon. Downloads are serialized with active-station artwork taking priority over pending preset and result artwork. Selection changes invalidate old responses and replace pending work; the last successful logo/URL is cached, with a separate cache for the active station. Repeated Now Playing updates for the same station/favicon do not retry downloads, including failed downloads. Select another station and return to retry a failure.

Images above 512 KiB or 512 pixels on either axis are rejected before base64 encoding. PNG signature, chunk boundaries, header, image-data presence, and ending are checked; this is not a full PNG decoder or checksum validation. The [Q-SYS HttpClient API](https://help.qsys.com/Content/Control_Scripting/Using_Lua_in_Q-Sys/HttpClient.htm) buffers the response before calling the handler and exposes no streaming receive-size limit, so the 512 KiB check limits processing/cache memory rather than imposing a hard network receive cap. Conversion dimensions and a 10-second timeout reduce exposure. Failure messages are limited to one per 10 seconds. No artwork is downloaded when logo pages are disabled.

After upgrading, check the renamed `Enable Logo Pages` property and reselect your external URL Receiver if necessary. Replace any UCI reference to `NowPlayingFavicon` with `StationLogo`; preset artwork changes from a text indicator to a button. Result tiles now pair `SelectBtn` (artwork) with `ResultName` (native text). Update existing UCI result tiles by placing both controls beside each other in a 1:3 width ratio.

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

### 2.3.0 - 2026-09-20

- Removed transparent-black color overrides from ResultName so it inherits native button theme colors.
- Reduced Search and Presets to approximately 560 × 420, with compact controls and group boxes with a corner radius of 5.
- Centered control text while preserving label alignment.
- Split result tiles into SVG artwork in the left quarter and native, centered station text in the right three quarters. Either area selects the station.
- Added conservative logo-padding trimming and consistent artwork sizing with rounded white backgrounds, including the fallback icon. Artwork is inset instead of clipped.
- Existing UCI result tiles must include both `SelectBtn` and `ResultName`; native text now supports Designer/UCI text styling.
- Retained the external receiver selector and V9.13 architecture; V2.2.0 remains archived.

### 2.2.0 - 2026-09-18

- Ported V3.3.0 SVG station logos to the V2 plugin for Designer 9.13, retaining external URL Receiver selection.
- Combined each result logo, wrapped name, and selection action into one button.
- Renamed Enable Favicon Pages to Enable Logo Pages (enabled by default).
- Added Core-side PNG downloads, local fallback artwork, response validation, caching, serialized downloads, and stale-response protection.
- Reset the active logo when changing receivers and ignore artwork responses from the previous receiver selection.


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
