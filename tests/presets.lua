-- Run from the repository root with Lua 5.3 or fengari.
-- Q-SYS controls, HTTP, timers, and rapidjson are mocked; test in Designer too.
local plugin = "Radio Url Search.qplug"
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local encoded, serial = {}, 0
package.preload.rapidjson = function()
    return {
        encode = function(value)
            serial = serial + 1
            local key = "encoded:" .. serial
            encoded[key] = copy(value)
            return key
        end,
        decode = function(value)
            assert(encoded[value], "invalid JSON")
            return copy(encoded[value])
        end,
    }
end
local json = require("rapidjson")
local function control()
    return { String = "", Value = 0, Boolean = false, Choices = {} }
end
local requests, downloads
local function boot(count, saved, favicons)
    Controls = nil
    dofile(plugin)
    Properties = {}
    for _, prop in ipairs(GetProperties()) do Properties[prop.Name] = copy(prop) end
    Properties["Preset Count"].Value = count
    Properties["Enable Logo Pages"].Value = favicons or false
    Controls = {}
    for _, definition in ipairs(GetControls(Properties)) do
        if (definition.Count or 1) > 1 then
            Controls[definition.Name] = {}
            for i = 1, definition.Count do Controls[definition.Name][i] = control() end
        else
            Controls[definition.Name] = control()
        end
    end
    Controls.PresetData.String = saved or ""
    _Media_Stream_Receiver = { url = control(), enable = control(), status = control(), interface = control() }
    for channel = 1, 2 do
        for _, suffix in ipairs({ "gain", "invert", "mute", "peak.level" }) do
            _Media_Stream_Receiver["channel." .. channel .. "." .. suffix] = control()
        end
    end
    Controls.ReceiverComponent.String = "Receiver A"
    Component = {
        GetComponents = function() return {{Name = "Receiver A", Type = "URL_receiver"}} end,
        New = function(name) if name == "Receiver A" then return _Media_Stream_Receiver end end,
    }
    requests = {}
    downloads = {}
    Network = { Interfaces = function() return {} end }
    Timer = { CallAfter = function() end }
    HttpClient = {
        Get = function(request) table.insert(requests, request) end,
        Download = function(request) table.insert(downloads, request) end,
    }
    Crypto = { Base64Encode = function(value) return "base64:" .. value end }
    dofile(plugin)
end
local function slot(index)
    Controls.PresetList.String = Controls.PresetList.Choices[index]
    Controls.PresetList.EventHandler(Controls.PresetList)
end
local a = { url = "https://radio.test/a", name = "Station A", favicon = "https://radio.test/a.png" }
local b = { url = "https://radio.test/b", name = "Station B", favicon = "" }
boot(10)
assert(PluginInfo.Version == "2.3.0")
assert(#GetComponents(Properties) == 0 and #GetPins(Properties) == 0 and #GetWiring(Properties) == 0)
assert(#Controls.PresetList.Choices == 10)
assert(Controls.PresetRecall.IsDisabled)
Controls.PresetSave.EventHandler()
assert(Controls.PresetData.String == "")
assert(tuneStation(a))
Controls.PresetSave.EventHandler()
local data = json.decode(Controls.PresetData.String)
assert(data["1"].url == a.url and data["1"].name == a.name and data["1"].favicon == a.favicon)
assert(tuneStation(b))
Controls.PresetRecall.EventHandler()
assert(_Media_Stream_Receiver.url.String == a.url)
assert(Controls.NowPlaying.String == a.name and _Media_Stream_Receiver.enable.Boolean)
assert(tuneStation(b))
Controls.PresetSave.EventHandler()
assert(json.decode(Controls.PresetData.String)["1"].name == b.name)
slot(10)
assert(tuneStation(a))
Controls.PresetSave.EventHandler()
local saved = Controls.PresetData.String
boot(1, saved)
assert(#Controls.PresetList.Choices == 1 and Controls.PresetName.String == b.name)
assert(tuneStation(b))
Controls.PresetSave.EventHandler()
boot(40, Controls.PresetData.String, true)
slot(10)
assert(Controls.PresetName.String == a.name)
Controls.PresetRecall.EventHandler()
Controls.PresetDelete.EventHandler()
assert(_Media_Stream_Receiver.url.String == a.url)
assert(Controls.PresetRecall.IsDisabled and Controls.PresetDelete.IsDisabled)
assert(json.decode(Controls.PresetData.String)["10"] == nil)
local afterDelete = Controls.PresetData.String
_Media_Stream_Receiver.url.String = "https://radio.test/external"
Controls.PresetSave.EventHandler()
assert(Controls.PresetData.String == afterDelete)
assert(tuneStation(a))
funcGetCurrentStation()
local request = requests[#requests]
assert(tuneStation(b))
request.EventHandler(request, 200, json.encode({a}), nil, {})
assert(Controls.NowPlaying.String == b.name)
funcGetCurrentStation()
request = requests[#requests]
request.EventHandler(request, 200, json.encode({b}), nil, {})
Controls.PresetSave.EventHandler()
assert(json.decode(Controls.PresetData.String)["10"].name == b.name)
selectedreceiver = nil
Controls.PresetRecall.EventHandler()
assert(Controls.PresetStatus.String:find("unavailable"))
boot(10, "broken JSON")
assert(Controls.PresetStatus.String:find("could not be read"))
assert(Controls.PresetData.String == "broken JSON")
boot(10, json.encode({ ["1"] = { url = 42 }, ["2"] = a }))
assert(Controls.PresetRecall.IsDisabled)
slot(2)
assert(Controls.PresetName.String == a.name)
for _, enabled in ipairs({ false, true }) do
    for _, resultCount in ipairs({ 1, 10, 11, 40 }) do
        Properties["Enable Logo Pages"].Value = enabled
        Properties["Result Count"].Value = resultCount
        local pages = GetPages(Properties)
        assert(pages[#pages].name == "Presets")
        for i, page in ipairs(pages) do
            Properties.page_index = { Value = i }
            local layout = GetControlLayout(Properties)
            if page.name == "Presets" then
                assert(layout.PresetList and layout.PresetSave and layout.PresetRecall and layout.PresetDelete)
                assert((layout.PresetFavicon ~= nil) == enabled)
            elseif page.name == "Search" then
                assert(layout.StrSearch)
            else
                assert(layout["SelectBtn " .. ((i - 2) * 10 + 1)])
            end
        end
    end
end
print("PASS: preset actions, reload, count changes, invalid data, stale lookup, and page layouts")

-- Small PNG fixture; Base64Encode is mocked so the embedded SVG can be inspected.
boot(10)
assert(tuneStation(a))
Controls.PresetSave.EventHandler()
funcGetCurrentStation()
local pending = requests[#requests]
Controls.ReceiverComponent.String = ""
Controls.ReceiverComponent.EventHandler()
pending.EventHandler(pending, 200, json.encode({a}), nil, {})
assert(Controls.NowPlaying.String == "")
Controls.PresetRecall.EventHandler()
assert(Controls.PresetStatus.String:find("unavailable"))
Controls.ReceiverComponent.String = "Receiver A"
Controls.ReceiverComponent.EventHandler()
Controls.PresetRecall.EventHandler()
assert(selectedreceiver.url.String == a.url)
print("PASS: V2 external receiver selection and stale receiver lookup")

-- Small PNG fixture; Base64Encode is mocked so the embedded SVG can be inspected.
local png = ("89504e470d0a1a0a0000000d4948445200000001000000010804000000b51c0c02"
    .. "0000000b4944415478da6364f80f00010501012718e3660000000049454e44ae426082")
    :gsub("..", function(hex) return string.char(tonumber(hex, 16)) end)
local function finish(index, code, data, err, headers)
    local request = downloads[index]
    request.EventHandler(request, code or 200, data or png, err, headers or { ["Content-Type"] = "image/png" })
end
local function fallback()
    local legend = json.decode(Controls.StationLogo.Legend)
    assert(legend.DrawChrome == false and legend.IconData:find("<circle", 1, true))
end
boot(10, nil, true)
fallback()
assert(not Controls.StationLogo.IsDisabled and not Controls.StationLogo.Boolean)
assert(tuneStation(a) and #downloads == 1)
assert(downloads[1].Url:find("images.weserv.nl", 1, true))
assert(downloads[1].Url:find("&output=png&w=300&h=300", 1, true))
setNowPlayingFavicon(a.favicon)
assert(tuneStation(a) and #downloads == 1)
finish(1)
local successfulLegend = Controls.StationLogo.Legend
local svg = json.decode(successfulLegend).IconData
assert(svg:find('preserveAspectRatio="xMidYMid meet"', 1, true))
assert(svg:find('data:image/png;base64,base64:' .. png, 1, true))
assert(tuneStation(b))
fallback()
assert(tuneStation(a) and #downloads == 1)
assert(json.decode(Controls.StationLogo.Legend).IconData == json.decode(successfulLegend).IconData)
Controls.StationLogo.Boolean = true
Controls.StationLogo.EventHandler(Controls.StationLogo)
assert(not Controls.StationLogo.Boolean and _Media_Stream_Receiver.url.String == a.url)

local c = { url = "https://radio.test/c", name = "Station C", favicon = "https://radio.test/c.ico" }
boot(10, nil, true)
assert(tuneStation(a))
assert(tuneStation(c) and #downloads == 1)
finish(1) -- Stale A must not render or enter the cache; C starts only now.
fallback()
assert(#downloads == 2)
finish(1) -- Duplicate callback must not release C's active request.
assert(#downloads == 2)
assert(tuneStation(b))
finish(2)
fallback()
assert(tuneStation(a) and #downloads == 3)
finish(3)
setNowPlayingFavicon(c.favicon) -- Changed favicon on the same station.
assert(#downloads == 4)
finish(4)
setNowPlayingFavicon(c.favicon)
assert(#downloads == 4)

for _, failure in ipairs({
    { 404, png }, { 200, "" }, { 200, "<html>Error</html>" },
    { 200, png, "timeout" }, { 200, png, nil, { ["content-type"] = "text/html" } },
    { 200, string.rep("x", 512 * 1024 + 1) }, { 200, png:sub(1, -5) },
    { 200, png, nil, { ["Content-Length"] = "524289" } },
    { 200, png:sub(1, 16) .. string.char(0, 0, 2, 1) .. png:sub(21) },
}) do
    boot(10, nil, true)
    tuneStation(a)
    finish(1, failure[1], failure[2], failure[3], failure[4])
    fallback()
    setNowPlayingFavicon(a.favicon)
    assert(#downloads == 1) -- No retry storm during Now Playing updates.
end
for _, headers in ipairs({ {}, { ["CONTENT-TYPE"] = { "image/png; charset=binary" } },
    { ["content-type"] = "application/octet-stream" } }) do
    boot(10, nil, true)
    tuneStation(a)
    finish(1, 200, png, nil, headers)
    assert(json.decode(Controls.StationLogo.Legend).IconData:find("<image", 1, true))
end
boot(10, nil, true)
setFaviconControl(1, a.favicon)
setFaviconControl(2, c.favicon)
tuneStation(c)
assert(#downloads == 1)
finish(1)
assert(#downloads == 2 and downloads[2].Url:find("c.ico", 1, true))
finish(2)
assert(#downloads == 2) -- Queued result uses the active-station cache.
assert(json.decode(Controls.SelectBtn[2].Legend).IconData:find("<image", 1, true))
Controls.PresetSave.EventHandler()
assert(#downloads == 2 and json.decode(Controls.PresetFavicon.Legend).IconData == json.decode(Controls.StationLogo.Legend).IconData)
boot(10, nil, false)
tuneStation(a)
setFaviconControl(1, a.favicon)
assert(#downloads == 0)
boot(10, nil, true)
tuneStation({ url = a.url, favicon = "file:///bad.png" })
fallback()
assert(#downloads == 0)
HttpClient.Download = function() error("download unavailable") end
tuneStation(a)
fallback()
print("PASS: SVG legends, fallback validation, caching, serialized downloads, stale responses, artwork controls")

boot(10, nil, true)
for _, definition in ipairs(GetControls(Properties)) do
    assert(definition.Name ~= "NowPlayingFavicon")
    if definition.Name == "favicon" or definition.Name == "StationLogo" or definition.Name == "PresetFavicon" then
        assert(definition.ControlType == "Button" and definition.ButtonType == "Momentary")
    end
end
local results = {
    { name = a.name, url = a.url, favicon = a.favicon, codec = "MP3", clickcount = 10 },
    { name = b.name, url = b.url, favicon = "", codec = "MP3", clickcount = 5 },
}
funcGetRadio(searchRequestId, { Url = "mock search" }, 200, json.encode(results), nil, {})
assert(#Controls.StrSearchResult.Choices == 2 and #downloads == 1)
assert(not Controls.SelectBtn[2].IsInvisible and not Controls.SelectBtn[2].IsInvisible)
assert(Controls.SelectBtn[3].IsInvisible and Controls.SelectBtn[3].IsInvisible)
Controls.SelectBtn[2].EventHandler()
assert(Controls.NowPlaying.String == b.name and _Media_Stream_Receiver.url.String == b.url)
fallback()
Controls.SelectBtn[1].EventHandler()
finish(1) -- Selection reuses the search result's downloaded artwork.
assert(#downloads == 1)
local cachedLegend = Controls.StationLogo.Legend
setFaviconControl(3, c.favicon)
tuneStation(b)
tuneStation(a)
assert(json.decode(Controls.StationLogo.Legend).IconData == json.decode(cachedLegend).IconData) -- Immediate cache hit while another request runs.
funcResetUI()
finish(2)
assert(Controls.SelectBtn[3].IsInvisible)
print("PASS: search result selection, no-favicon tiles, UI reset, immediate cache reuse")

boot(10, nil, true)
assert(Controls.favicon == nil and Controls.Name == nil)
Properties.page_index = { Value = 2 }
local tileLayout = GetControlLayout(Properties)
assert(tileLayout["SelectBtn 1"] and not tileLayout["favicon 1"] and not tileLayout["Name 1"])
stations = {
    { name = "Jazz & <Soul>", url = a.url, favicon = a.favicon },
    { name = "Café Radio", url = c.url, favicon = a.favicon },
}
setFaviconControl(1, a.favicon)
setFaviconControl(2, a.favicon)
local function tileLegend(i) return json.decode(Controls.SelectBtn[i].Legend) end
local function tileSvg(i) return tileLegend(i).IconData end
assert(Properties["Result Color"] == nil)
assert(tileLegend(1).Legend == "")
assert(Controls.ResultName[1].Legend == stations[1].name)
assert(not tileSvg(1):find("<text", 1, true))
assert(tileLayout["SelectBtn 1"].Size[1] == 62)
assert(tileLayout["ResultName 1"].Size[1] == 186)
assert(tileLayout["ResultName 1"].Position[1] == tileLayout["SelectBtn 1"].Position[1] + 62)
assert(tileLayout["ResultName 1"].HTextAlign == "Center" and tileLayout["ResultName 1"].WordWrap)
finish(1)
assert(#downloads == 1)
assert(Controls.ResultName[2].Legend == stations[2].name)
Controls.ResultName[2].EventHandler()
assert(_Media_Stream_Receiver.url.String == c.url and not Controls.ResultName[2].Boolean)
assert(not json.decode(Controls.StationLogo.Legend).IconData:find("<text", 1, true))
stations[2] = { name = "Missing Logo", url = b.url, favicon = "" }
setFaviconControl(2, "")
assert(Controls.ResultName[2].Legend == "Missing Logo" and tileSvg(2):find("<circle", 1, true))
stations[2].name = string.rep("Long station name ", 10)
setFaviconControl(2, "")
assert(Controls.ResultName[2].Legend == stations[2].name)
assert(not tileSvg(2):find("<text", 1, true))
funcResetUI()
assert(Controls.SelectBtn[2].IsInvisible and Controls.ResultName[2].IsInvisible)
assert(Controls.ResultName[2].Legend == "")
local previousUrl = _Media_Stream_Receiver.url.String
Controls.ResultName[2].EventHandler()
assert(_Media_Stream_Receiver.url.String == previousUrl)
for _, page in ipairs({1, #GetPages(Properties)}) do
    Properties.page_index.Value = page
    local layout, graphics = GetControlLayout(Properties)
    for _, item in pairs(layout) do
        if item.Position then assert(item.HTextAlign == "Center") end
    end
    assert(graphics[2].HTextAlign == "Left")
end
print("PASS: native station text, quarter-width artwork, either-side selection, paired visibility and alignment")
