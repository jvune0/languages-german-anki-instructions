# CLAUDE.md — German Anki Card Generator

## Purpose
This project generates CSV files that can be imported into **AnkiDroid** to help me learn German vocabulary. I give you a German word; you produce a ready-to-import CSV with cloze-style flashcards.

## Card format

For each German word I provide, generate **3 cards** (= 3 rows in the CSV).

- **Front:** A natural German sentence with the target word replaced by `___`, followed by the English translation of the missing word in parentheses.
- **Back:** The German word as it should appear in the blank (correctly conjugated, declined, or inflected for the sentence).

### Example
Input word: `fahren`

| Front | Back |
|---|---|
| `Ich ___ jeden Tag mit dem Fahrrad zur Arbeit. (to drive/ride)` | `fahre` |
| `Wohin ___ du dieses Wochenende? (to drive/travel)` | `fährst` |
| `Letzten Sommer sind wir nach Italien ___. (driven — past participle)` | `gefahren` |

## CSV specification

- **Separator:** Tab (`\t`). Do not use commas — German sentences often contain them.
- **Encoding:** UTF-8.
- **No header row.**
- **Columns (in order):**
  1. Front (sentence with `___` + English hint in parens)
  2. Back (the German word/form filling the blank)
  3. Tags (space-separated, e.g. `german verb a2`)
- **Quoting:** Wrap a field in double quotes only if it contains a tab or newline. Escape internal `"` by doubling: `""`.

## File naming and folder structure

Files are organized into **weekly folders** at the project root.

- **Folder name:** `cards/week_<YYYY>-W<WW>/` using ISO 8601 week numbering — e.g. `cards/week_2026-W19/` for the week of Mon 4 May – Sun 10 May 2026.
- The week is determined by **today's date** when the file is generated (Monday is the first day of the week).
- Create the folder if it doesn't already exist.
- Single word: `<folder>/<word>_<YYYYMMDD>.csv` — e.g. `cards/week_2026-W19/fahren_20260508.csv`
- Multiple words in one run: `<folder>/batch_<YYYYMMDD>.csv`
- If a file with the same name already exists in the week folder, ask before overwriting.

## Word tracking (`words_log.csv`)

A log file `words_log.csv` lives at the **project root** (not inside a week folder) and records every word that has been turned into cards, across all weeks.

**Format:** Comma-separated CSV **with a header row**:

```
word,added_date,week,file
```

**Columns:**
1. `word` — the lemma / dictionary form (verbs in infinitive, nouns with their article, e.g. `fahren`, `der Hund`, `schön`).
2. `added_date` — `YYYY-MM-DD`.
3. `week` — ISO week, `YYYY-Www`.
4. `file` — relative path of the generated card CSV, e.g. `week_2026-W19/cards_fahren_20260508.csv`.

### Workflow integration

**Before generating** cards for a word:
- Read `words_log.csv` (create with the header row if it doesn't exist).
- Look up the word **case-insensitively** against the `word` column.
- If already present, tell me **when** and **in which file** it was added, then ask:
  - **(a)** skip — don't regenerate,
  - **(b)** generate fresh sentences anyway in this week's file (a new row gets appended to the log),
  - **(c)** show me the existing file first.

**After successfully writing** a card file:
- Append one row per newly-added word to `words_log.csv`.
- For batch runs: one row per word in the batch, all pointing to the same batch file.
- Never rewrite or reorder the log — only append.

## Sentence-writing rules

### Level
Default to **A2–B1** vocabulary and grammar. Keep sentences natural and conversational — not textbook-stilted, not literally translated from English.

### Variety across the 3 cards
The three sentences for a single word should differ meaningfully — different tense, case, register, or context — so the cards don't feel like duplicates.

### Word-type rules

**Verbs**
- Conjugate the verb to fit the subject; the Back is the conjugated form, not the infinitive.
- Across the 3 cards, vary the form: e.g. present tense, a question with `du`/`ihr`, perfect tense (where the participle goes in the blank), modal-verb construction, or subordinate clause.
- English hint: the infinitive, e.g. `(to go)`. For participles in perfect tense, hint as `(gone — past participle)`.
- For separable verbs, the Back contains whichever piece is in the blank; if the whole verb is blanked in a subordinate clause, include both pieces joined.

**Nouns**
- Prefer blanking the article + noun together so the case is part of the answer, e.g. Front: `Ich sehe ___. (the dog)` → Back: `den Hund`.
- Across the 3 cards, vary the case: nominative, accusative, dative (genitive only if natural).
- English hint: `(the X)` if the article is in the blank, otherwise `(X)`.

**Adjectives**
- Use the adjective in attributive position so the ending matters, e.g. Front: `Sie hat einen ___ Hund. (big)` → Back: `großen`.
- Vary the gender/case/article across cards so different endings appear.
- English hint: the base English adjective, e.g. `(big)`.

**Prepositions, adverbs, conjunctions, particles**
- Use in natural sentences; the Back is just the word.
- English hint: closest English equivalent, or a brief gloss if no clean one-word match exists, e.g. `(although)`, `(by the way)`.

### Hints
Keep the English hint **short** — one or two words, plus a brief note only when the form genuinely needs disambiguation (e.g. `— past participle`, `— dative`).

## Workflow when I send a word

1. I send one word, or a list of words.
2. **Check `words_log.csv`** for each word (case-insensitively). If any are already logged, follow the duplicate-handling steps in the *Word tracking* section before continuing.
3. You generate the rows following the rules above.
4. You write the CSV file into the current week's folder (creating it if needed) using the file-naming convention.
5. **Append a row to `words_log.csv`** for each newly added word.
6. You print the card-file path and show a preview of the rows in a small table so I can spot-check before importing.
7. You do **not** ask clarifying questions for normal vocabulary — just pick reasonable sentences. Only ask if the input is ambiguous (e.g. a word that's both a noun and a verb with very different meanings, like `Bank`), clearly mistyped, or already in the word log (per step 2).

## Importing into AnkiDroid (for reference)

1. Move/share the `.csv` to the device.
2. AnkiDroid → ⋮ menu → **Import** → select the file.
3. Field separator: **Tab**.
4. Map: field 1 → Front, field 2 → Back, field 3 → Tags.
5. Pick (or create) the deck `German` and import.
