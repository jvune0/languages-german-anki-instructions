# German Anki Card Generator

A small [Claude Code](https://docs.claude.com/en/docs/claude-code) project for building a personal German vocabulary deck for AnkiDroid, organized into weekly blocks.

## Philosophy

Read something in German that actually interests you — articles, fiction, lyrics, forum threads, anything. Whenever a word trips you up, hand it to Claude Code. Over the course of a week you'll collect cards tied to the things you were really reading, not to an abstract textbook list, and at the end of the week that block of cards goes into Anki as one cohesive unit.

The point of the **weekly block** is that the words you learn together share a context — the texts you happened to read in those seven days — which is much stickier than memorising 200 unrelated entries from a frequency list. One small block per week, then move on.

## How it works

The `CLAUDE.md` file at the root of this repo is the spec Claude Code follows. In short:

- You give it a German word.
- It generates 3 cloze-style cards (German sentence with the target word blanked, English hint in parens, German answer on the back).
- Each card file lands in `cards/week_YYYY-Www/` (ISO week numbering), created automatically.
- A `words_log.csv` at the project root tracks every word you've ever added, so duplicates get flagged before generation.

See `CLAUDE.md` for the full rules — CSV format, sentence-writing guidelines, handling of nouns/adjectives/separable verbs, and so on.

## Importing into AnkiDroid

AnkiDroid only lets you import one file at a time, so each week folder also contains an auto-generated bundle `_all.csv` that concatenates every card in that week. Claude Code keeps it in sync — every time it adds a card, it rebuilds the bundle. At the end of the week you just import that one file.

1. Move `cards/week_YYYY-Www/_all.csv` to your phone (cloud sync, USB, GitHub clone — whatever you use).
2. Open **AnkiDroid** → ⋮ menu → **Import**.
3. Select `_all.csv`.
4. Set **field separator** to **Tab**.
5. Map: field 1 → Front, field 2 → Back, field 3 → Tags.
6. Pick (or create) your `German` deck and confirm.

Desktop Anki works the same way (File → Import).

### Rebuilding `_all.csv` manually

You normally don't need to — Claude Code does it for you. But if you've edited cards by hand or are working outside Claude Code, regenerate the bundle yourself.

From the project root (replace the week with the one you want):

```bash
rm -f cards/week_2026-W19/_all.csv \
  && cat cards/week_2026-W19/*.csv > cards/week_2026-W19/_all.csv
```

Or from inside the week folder:

```bash
cd cards/week_2026-W19
rm -f _all.csv && cat *.csv > _all.csv
```

The `rm` step is important: without it the previous bundle gets included in the new one and grows on every rebuild.

## Using this repo for your own deck

The contents of `cards/` and `words_log.csv` are **personal** — they're my words from my week.

If you fork or clone this repo to use for yourself, **delete first**:

```bash
rm -rf cards/
rm -f words_log.csv
```

Then start fresh: open Claude Code in the project and send it your first German word. Your own weekly folders and log will be created automatically as you go.

## Requirements

- [Claude Code](https://docs.claude.com/en/docs/claude-code)
- [AnkiDroid](https://github.com/ankidroid/Anki-Android) on your phone (or desktop [Anki](https://apps.ankiweb.net/))
