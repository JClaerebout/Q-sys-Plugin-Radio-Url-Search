# Q-SYS Plugin - Radio URL Search

## Overview

The **Radio URL Search Q-SYS Plugin** searches online radio stations and sends the selected stream URL to a Q-SYS URL Receiver component.

The plugin uses the public Radio Browser API to retrieve countries and station results. It is designed as a simple operator tool for finding internet radio streams by country and station name directly inside Q-SYS.

---

## Features

- Search internet radio stations by name
- Filter station searches by country
- Retrieve up to 20 matching stations
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
| Version | 1.0.0 |
| Author | Jens Claerebout |
| Protocol | HTTPS / Radio Browser API |
| Required Q-SYS Component | URL Receiver |

---

## Configuration

### Properties

This plugin does not define configurable plugin properties.

---

### Control Pins

#### Inputs

| Control | Type | Description |
| --- | --- | --- |
| `StrSearch` | Text | Station name search text |

#### Internal / UI Controls

These controls are used inside the plugin UI and are not exposed as user pins:

| Control | Type | Description |
| --- | --- | --- |
| `ReceiverComponent` | ComboBox | Selects the Q-SYS URL Receiver component that will receive the stream URL |
| `Country_Code` | ComboBox | Selects the country used to filter station searches |
| `StrSearchResult` | ListBox | Displays matching radio stations returned by the search |
| `NowPlaying` | Text Indicator | Shows the selected or restored station name |
| `code` | Text | Plugin code/debug text control |

---

## UI Layout

The plugin UI contains a single page with:

- URL Receiver component selection
- Country selection
- Station search field
- Search result list
- Now playing display

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
- result limit of 20 stations
- broken stations hidden
- results ordered by station name

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

- station names are shown in the result list
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
- Search defaults to country code `BE` until a country is selected
- Only Q-SYS components of type `URL_receiver` are listed in the receiver dropdown
- The URL Receiver component must have a writable `url` control and have script acces

---

## Known Limitations

- Search results are limited to 20 stations

---

## Future Improvements

- Add favorites or presets
- Add clearer UI feedback for failed searches or unavailable API responses

---

## License

MIT License

---

## Author

Jens Claerebout
