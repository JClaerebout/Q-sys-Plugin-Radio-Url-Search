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
- Retrieve ICY song titles from the active stream and display them below the station name
- Restore the now-playing station name from the current Media Stream Receiver stream URL
- Save and recall station presets (URL, name, and favicon) from a separate Presets page
- Configure between 1 and 40 preset slots, with Save, Recall, and Delete buttons

---

## Plugin Information

| Property | Value |
| --- | --- |
| Name | Radio Url Search |
| Version | 3.4.1 |
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
| `StreamTitle` | Text Indicator | ICY `StreamTitle`, usually artist and song title, exactly as supplied by the station |
| `StreamUrl` | Text Indicator | ICY `StreamUrl` metadata value, when supplied (not the receiver URL) |
| `MetadataStatus` | Text Indicator | ICY connection, availability, and error feedback |
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

Now-playing artwork uses a 64 × 64 area spanning the station and song-title rows, with an 8-pixel gap to the text. Other station artwork retains its existing sizing. Artwork preserves its proportions. The image service conservatively trims uniform outer padding before resizing so padded logos fill more of the available space. Logos sit inside a small safety margin on a rounded white tile; the artwork itself is not clipped. Transparent areas show the white tile, and backgrounds within the logo itself are retained. Unusual shapes or nonuniform padding can still produce differences in apparent size.

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
- MP3 codec requested with `codec=mp3`
- duplicate resolved stream URLs merged, keeping the highest click count and then highest votes; empty resolved URLs fall back to the original URL
- different stream URLs retained even when station names match; URL paths and query parameters are preserved
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

### ICY Now-Playing Metadata

Displays the selected stream's song title below the station name. `StreamTitle`, `StreamUrl`, and `MetadataStatus` are available as output pins. Metadata follows station selections and presets, with automatic reconnects after connection failures.

Requires an HTTP(S) stream that provides ICY metadata and uses an additional stream connection. Missing metadata does not affect audio playback. Test on a Core; Designer Emulate may encounter DNS or TLS failures.

### Station Presets

1. Play a station from Search or a Results page.
2. Open Presets and select a numbered slot.
3. Press **Save** to store its stream URL, full station name, and favicon URL. Saving replaces any station already in that slot.
4. Select a saved slot and press **Recall** to play it and update Now Playing.
5. Press **Delete** to clear the selected slot. Playback continues.

Selecting a slot only previews it; empty slots cannot be recalled or deleted. Recall uses the stored stream URL directly, without a Radio Browser lookup. Favicons are saved as URLs, so displaying artwork still requires network access.

Preset data is held in a persistent text control within the Q-SYS design. Save your design after configuring presets. Reducing `Preset Count` hides higher slots while retaining their data; increasing it makes them available again.

### Station Artwork

When logo pages are enabled, station logos appear in search results, Now Playing, and preset previews. Artwork is downloaded through `images.weserv.nl` and embedded for UCI display. Missing or invalid images show a radio icon. Press either the artwork or station name in a result tile to select it.

For existing UCIs, replace `NowPlayingFavicon` with `StationLogo` and use a button for preset artwork. Place `SelectBtn` and `ResultName` side by side in a 1:3 width ratio.

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

### 3.4.1 - 2026-09-23

- Added ICY metadata retrieval for the active HTTP/HTTPS stream, with song title display and `StreamTitle`, `StreamUrl`, and `MetadataStatus` output pins.
- Added incremental metadata parsing, chunked transfer support, redirects, stale-response protection, and automatic reconnects using the last working stream URL with fallback to the original URL.
- Added hostname and connection-stage diagnostics for metadata failures. Live Core operation has been more reliable than Designer Emulate during testing.
- Added `codec=mp3` to station searches and merged duplicate resolved stream URLs, keeping the highest click count and then highest votes.
- Changed result-list selection to use the selected row so stations with identical names and different URLs remain selectable.
- Aligned the now-playing logo with the station and song-title rows.

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
- Combined each result's logo, wrapped SVG station name, and selection action into one `SelectBtn` button.
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
