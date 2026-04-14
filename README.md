# custombg
**Кастомный фон для главного меню Dota 2** — через Panorama API, без правки VPK-файлов.

📖 [English version](https://github.com/benchmerge/custombg/blob/main/README_EN.md)

![Badge](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2Fbenchmerge%2Fcustombg&label=&icon=check2&color=%23c29ffa&message=&style=flat&tz=Europe%2FMoscow)
---

## Как это работает

Скрипт создаёт HTML-панель поверх стандартного фона и загружает в неё любой URL: сайт, видео, гифку, картинку. Всё работает нативно через движок игры — никаких модов, никаких обновлений не страшно.

---

## Возможности

- **Любая ссылка** — сайт, YouTube, TikTok, mp4, jpg, png
- **Интерактивность** — фон кликабельный, можно скроллить. Отключается одной галочкой
- **Размытие** — ползунок от 0 до 30px
- **Скрыть чат / мелкие панели** — опционально
- **Пресеты** — встроенная база из облака, обновляется кнопкой
- **Свои пресеты** — добавляй в `custom_presets` прямо в коде
- **Свои библиотеки** — добавляй JSON-ссылки в массив `libs`

---

## Прямые ссылки на файлы

Для mp4, jpg, png используй шаблон:
```
https://benchmerge.github.io/custombg/?v=ССЫЛКА_НА_ФАЙЛ
```

Нужна **прямая** ссылка на файл, не на страницу.

**Не работает:**
```
https://benchmerge.github.io/custombg/?v=https://pinterest.com/pin/...
```
**Работает:**
```
https://benchmerge.github.io/custombg/?v=https://i.pinimg.com/....jpg
```

Прямую ссылку на картинку получить просто: правая кнопка мыши → «Копировать URL картинки».

---

## Хостинги для своих файлов

| Сервис | Лимит | Примечание |
|---|---|---|
| [filegarden.com](https://filegarden.com) | 100 МБ | Работает из России |
| [catbox.moe](https://catbox.moe) | 200 МБ | Не работает с RU IP |
| [imgur.com](https://imgur.com) | — | |

---

## Своя библиотека пресетов

Создай JSON-файл (например на GitHub Gist):
```json
{ "Название": "ссылка", "Ещё один": "ссылка" }
```
Добавь raw-ссылку на него в массив `libs` в начале скрипта.
