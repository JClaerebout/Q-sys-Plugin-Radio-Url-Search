# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and plays the selected stream through its embedded Q-SYS Media Stream Receiver.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Compatibility

**Plugin V3.x requires Q-SYS Designer V10.0 or later.**

For **Q-SYS Designer V9.13**, use [plugin V2.3.0](Previous_releases/Q-sys-Plugin-Radio-Url-Search-2.3.0/README.md), which retains the external URL Receiver integration.

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
- Enable or disable the embedded receiver with a Boolean toggle
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
| Version | 3.4.0 |
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
| `Enable Logo Pages` | Boolean | true | true/false | Shows the favicon result pages, now-playing artwork, and preset artwork. When disabled, Search and Presets remain available without artwork. |

**Result-button text colour:** Station names use native Q-SYS button text. Set Text Color on the ResultName controls in Designer/UCI. The former Result Color property has been removed.

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

#### Receiver Controls

| Control | Type | Direction | Description |
| --- | --- | --- | --- |
| `enable` | Boolean Toggle | Input / Output | Enables or disables the embedded receiver and mirrors its current enable state; selecting or recalling a station enables playback |
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
| `SelectBtn` / `ResultName` | Trigger Buttons (1-40 each) | SVG artwork occupies the left quarter and centered native station text occupies the right three quarters; either button selects the station |
| `StationLogo` | Momentary Button | Displays the active station's SVG logo without button chrome; presses reset immediately |
| `code` | Text | Plugin code/debug text control |
| `PresetList` | ListBox | Selects a numbered preset slot without starting playback |
| `PresetName` / `PresetUrl` | Text Indicators | Show the selected preset's saved name and stream URL |
| `PresetFavicon` | Momentary Button | Displays the selected preset's SVG artwork when favicon pages are enabled; presses reset immediately |
| `PresetSave` / `PresetRecall` / `PresetDelete` | Trigger Buttons | Save the current station, recall the selected slot, or clear it |
| `PresetStatus` | Text Indicator | Shows preset action feedback |
| `PresetData` | Hidden Text | Stores preset URLs, full station names, and original favicon URLs as JSON |

---

## UI Layout

The plugin UI always contains Search and Presets pages. When `Enable Logo Pages` is enabled, it also includes dynamically generated Results pages. The UI provides:

- Media Stream Receiver status
- Receiver Enable toggle above the stereo controls in a compact Receiver panel
- Network interface selection
- Stereo channel gain, invert, mute, and peak-level controls
- Country selection
- Station search field
- Search result list on page 1
- Result pages starting at page 2, with up to 10 artwork tiles per page
- Now-playing station name and optional artwork

Search and Presets use an approximately 560 × 420 layout with compact 12-point labels, aligned fields, and thin group borders with a corner radius of 5. Result pages use the same border styling with tighter spacing between station tiles.

Station artwork fits within a consistent 56 × 56 area on all pages, preserving its proportions. The image service conservatively trims uniform outer padding before resizing so padded logos fill more of the available space. Logos sit inside a small safety margin on a rounded white tile; the artwork itself is not clipped. Transparent areas show the white tile, and backgrounds within the logo itself are retained. Unusual shapes or nonuniform padding can still produce differences in apparent size.

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

Preset data is held in a persistent text control within the Q-SYS design. Save your design after configuring presets. Reducing `Preset Count` hides higher slots while retaining their data; increasing it makes them available again.

### Station Artwork

When favicon pages are enabled, the Core downloads artwork using `HttpClient.Download` through `images.weserv.nl`, requesting a PNG fitted within 300 × 300 pixels. Each PNG is base64-encoded inside an SVG `<image>` with `preserveAspectRatio="xMidYMid meet"`; the complete SVG is then base64-encoded into the button Legend's JSON `IconData`, with `DrawChrome=false`. No EzSVG dependency is needed. UCI clients receive the embedded artwork rather than downloading favicon URLs themselves.

Artwork buttons stay enabled to avoid Q-SYS dimming their SVGs in Live/Emulate. The Now Playing and preset artwork handlers immediately clear presses without tuning. Each result tile is one trigger button with the logo and station name drawn together in SVG. Names wrap to three lines, with an ellipsis for longer names. Set the plugin's `Result Color` property to change result text colour: `#ff000000` is opaque black, `#ffff0000` is opaque red, and `#ffffffff` is opaque white. Eight-digit values use `#AARRGGBB`; six-digit `#RRGGBB` values are also accepted as opaque. Invalid values fall back to opaque black. Alpha applies only to the text, not the logo. Designer/UCI Text Color does not change SVG text. Pressing anywhere on the tile selects that station. Missing or invalid favicon URLs, failed downloads, non-200 responses, unexpected Content-Type, empty data, and structurally invalid PNGs show a locally generated radio icon. Downloads are serialized with active-station artwork taking priority over pending preset and result artwork. Selection changes invalidate old responses and replace pending work; the last successful logo/URL is cached, with a separate cache for the active station. Repeated Now Playing updates for the same station/favicon do not retry downloads, including failed downloads. Select another station and return to retry a failure.

Images above 512 KiB or 512 pixels on either axis are rejected before base64 encoding. PNG signature, chunk boundaries, header, image-data presence, and ending are checked; this is not a full PNG decoder or checksum validation. The [Q-SYS HttpClient API](https://help.qsys.com/Content/Control_Scripting/Using_Lua_in_Q-Sys/HttpClient.htm) buffers the response before calling the handler and exposes no streaming receive-size limit, so the 512 KiB check limits processing/cache memory rather than imposing a hard network receive cap. Conversion dimensions and a 10-second timeout reduce exposure. Failure messages are limited to one per 10 seconds. No artwork is downloaded when favicon pages are disabled.

After upgrading, replace any UCI reference to `NowPlayingFavicon` with `StationLogo`; preset artwork changes from a text indicator to a button. Result tiles now pair `SelectBtn` (artwork) with `ResultName` (native text). Update existing UCI result tiles by placing both controls beside each other in a 1:3 width ratio.

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

### 3.4.0 - 2026-09-20

- Removed transparent-black color overrides from ResultName so it inherits native button theme colors.
- Reduced Search and Presets to approximately 560 × 420, with compact controls and group boxes with a corner radius of 5.
- Centered control text while preserving label alignment.
- Split result tiles into SVG artwork in the left quarter and native, centered station text in the right three quarters. Either area selects the station.
- Added conservative logo-padding trimming and consistent artwork sizing with rounded white backgrounds, including the fallback icon. Artwork is inset instead of clipped.
- Existing UCI result tiles must include both `SelectBtn` and `ResultName`; native text now supports Designer/UCI text styling.
- Archived V3.3.0 and provided the matching V2.3.0 update for external receivers.

### 3.3.0 - 2026-09-18

- Replaced Media Display artwork with chrome-free SVG button legends for Now Playing, search results, and preset previews.
- Combined each result's logo, wrapped SVG station name, and selection action into one `SelectBtn` button; added `Result Color` for text colour and alpha.
- Added Core-side PNG downloads, a generated radio fallback, HTTP/content validation, and image size checks.
- Serialized artwork downloads, ignored stale responses, and cached successful logos without repeated Now Playing downloads.
- Renamed the active-station artwork control to `StationLogo`; retained existing search, receiver, and preset behavior.

### 3.2.0 - 2026-09-16

- Added an Enable toggle in its own box above Receiver Channels, with input and output pins.
- Synchronized the toggle with the embedded receiver's enable state, including station selection and preset recall.
- Moved Receiver Channels down to make room for the Enable box.

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
