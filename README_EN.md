# custombg
**Custom background for Dota 2 main menu** — via Panorama API, no VPK edits required.

📖 [Русская версия](https://github.com/benchmerge/custombg/blob/main/README.md)

![Badge](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2Fbenchmerge%2Fcustombg&label=&icon=check2&color=%23c29ffa&message=&style=flat&tz=Europe%2FMoscow)
---

## How it works

The script creates an HTML panel over the default background and loads any URL into it: website, video, gif, image. Works natively through the game engine — no mods, safe from updates.

---

## Features

- **Any URL** — website, YouTube, TikTok, mp4, jpg, png
- **Interactivity** — background is clickable and scrollable. Disable with one toggle
- **Blur** — adjustable slider from 0 to 30px
- **Hide chat / side panels** — optional
- **Presets** — built-in cloud library, updated via button
- **Custom presets** — add to `custom_presets` directly in the code
- **Custom libraries** — add JSON links to the `libs` array

---

## Direct file links

For mp4, jpg, png use the template:
```
https://braindead.cyou/?v=YOUR_FILE_URL
```

Requires a **direct** link to the file, not a page URL.

**Doesn't work:**
```
https://braindead.cyou/?v=https://pinterest.com/pin/...
```
**Works:**
```
https://braindead.cyou/?v=https://i.pinimg.com/736x/3b/b6/03/....jpg
```

To get a direct image link: right-click the image → "Copy image address".

---

## File hosting

| Service | Limit | Note |
|---|---|---|
| [filegarden.com](https://filegarden.com) | 100 MB | Works from Russia |
| [catbox.moe](https://catbox.moe) | 200 MB | Blocked for RU IPs |
| [imgur.com](https://imgur.com) | — | |

---

## Custom preset library

Create a JSON file (e.g. on GitHub Gist):
```json
{ "Name": "url", "Another": "url" }
```
Add the raw link to the `libs` array at the top of the script.
