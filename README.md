# Lecture notes for Computational Biology Course

Built with [Typst](https://typst.app) using the
[Touying](https://touying-typ.github.io/) presentation framework
(Metropolis theme, 16:9).

---

## Installing Typst

You only need the `typst` CLI. Pick the line for your platform.

| Platform | Command |
| --- | --- |
| Windows | `winget install --id Typst.Typst` |
| macOS | `brew install typst` |
| Linux | distro package where available — e.g. `pacman -S typst` on Arch, `nix-shell -p typst` on Nix |
| Any (via Rust) | `cargo install --locked typst-cli` |

If none of those fit, grab a prebuilt binary from the
[releases page](https://github.com/typst/typst/releases) and put it on your
`PATH`.

Confirm it worked:

```sh
typst --version     # this deck was last built with typst 0.14.2
```

### Fonts

The deck sets `Aptos` as its body font (line 6 of `src/BLAST.typ`). Aptos ships
with Microsoft 365, so it is usually already present on Windows and on machines
with Office installed. On a bare system Typst will warn about an unknown font
family and silently substitute another — the slides still build, they just look
different.

To check what your system has:

```sh
typst fonts | grep -i aptos
```

If it is missing, either install Aptos or change line 6 to a font you do have,
for example `#set text(font: "Fira Sans")`.

### Editing 

For live preview, use VS Code with the
[**Tinymist Typst**](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)
extension. Open *this folder* as the workspace — Tinymist then treats it as the
project root, which is what the asset paths expect (see below).

---

## Building the deck

From the repository root:

```sh
typst compile --root . src/BLAST.typ pdfs/BLAST.pdf
```

Or, to rebuild automatically on every save while you work:

```sh
typst watch --root . src/BLAST.typ pdfs/BLAST.pdf
```

### Why `--root .` is required

Typst refuses to read files outside the *project root*, and by default the root
is the input file's own folder — here that would be `src/`, which contains no
images. Because the assets live one level up, the deck refers to them with
root-relative paths (`/pictures/…`, `/references.bib`), and `--root .` tells
Typst that "root" means the repository root.

Omitting the flag produces:

```
error: failed to load file (access denied)
  = hint: cannot read file outside of project root
```

The fix is always to add `--root .`, not to change the paths.

---

## Repository contents

```
.
├── src/
│   └── BLAST.typ        the entire deck — one Typst source file
├── pictures/
│   ├── Blosum62.png     BLOSUM62 substitution matrix (source: LabXchange.com)
│   ├── WSAI Logo.png    title-slide branding
│   └── iitm.png         title-slide branding
├── pdfs/
│   └── BLAST.pdf        compiled pdf
├── references.bib       BibTeX bibliography, exported from Zotero
└── README.md            this file
```

A few notes on the pieces:

**`src/BLAST.typ`** — everything lives here: theme configuration, a small set of
custom helpers, and all slide content. The helpers worth knowing about are
`#question` / `#answer` / `#definition` (coloured callout boxes built on
`gentle-clues`), `#match` / `#mismatch` (green/red residue colouring), and
`alignment_grid` (the two-row grids used to draw sequence alignments).

**`references.bib`** — Zotero generated bibliography

---

