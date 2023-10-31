---
title: 
description: 
authors: 
categories: 
created: 
updated: 
version: 
---


# minorg


![Minimum supported Nim version](https://img.shields.io/badge/nim-2.0.0%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/pysan3/minorg?style=flat)](#license)

> MyNorg: Convert all _my_ notes into [`norg`](https://github.com/nvim-neorg/neorg/) format.

`Pandoc json` -> `norg` converter written in [Nim](https://nim-lang.org/) language.

*This README is generated from [./README.norg](#readmenorg).


## Get Started

- Download: [https://github.com/pysan3/minorg/releases](https://github.com/pysan3/minorg/releases)
- API documentation: [https://pysan3.github.io/minorg/](https://pysan3.github.io/minorg/)


## Usage

### Command

- Usage: [usage.txt](usage.txt)
    - `minorg help`


### Example

- Use `-i`, `-o` flags (`--input`, `--output`)
```bash
$ wget https://raw.githubusercontent.com/nvim-neorg/norg-specs/main/1.0-specification.norg
$ norganic json --input ./1.0-specifications.norg --output ./parsed.json
$ minorg generate -i ./parsed.json -o out.norg
$ nvim out.norg
```
- Use `stdin`, `stdout`
```bash
$ wget https://raw.githubusercontent.com/nvim-neorg/norg-specs/main/1.0-specification.norg
$ norganic json --input ./1.0-specifications.norg | minorg generate > out.norg
$ nvim out.norg
```


## Known Issues



### File Linking

It is very hard to distinguish what link pattern should be used.

- [x] URL: `{https://xxx.example.com}`
    - [x] URL with name: [Neorg GitHub](https://github.com/nvim-neorg/neorg/)
- [ ] Norg files
    - [ ] Relative to current file: `{:foo/bar:}` -> `foo/bar.norg`
    - [ ] Absolute path: `{:/tmp/foo/bar:}` -> `/tmp/foo/bar.norg`. (Also works with `~/` = `$HOME/`)
    - [ ] Relative to current workspace: `{:$/foo/bar:}` -> `~/Norg/Notes/foo/bar.norg`
    - [ ] Relative to different workspace: `{:$work/foo/bar:}` -> `~/Norg/work/foo/bar.norg`
- [ ] Usual files: `{/ /path/to/file}`
- [x] Headings: [Heading 1](#heading-1)
    - [x] Any level heading: [Heading 2](#heading-2)

**AND YOU CAN COMBINE THEM**
- [ ] `Heading 1` of `foo/bar.norg`: [Heading 1](foo/bar.md#heading-1)
- [ ] Line numbers: [4](foo/bar.md#4)


### `|example` Is Not Restored Correctly

This is a problem in `norganic` / `Norg.jl`.

- [x] I will make a PR later.
    - [https://github.com/Klafyvel/Norg.jl/issues/41](https://github.com/Klafyvel/Norg.jl/issues/41)
- [ ] He says he needs some help [here](https://github.com/Klafyvel/Norg.jl/issues/41#issuecomment-1784814268).
- [x] Auto convert `@code norg` -> `|example`


### Softbreak Not Preserved

When the original note (especially markdown) had softbreaks (single new
line to format the document but does not mean a new paragraph), that new line does not
get transferred to the generated file.

- [x] fix softbreak
- [x] Modifier chars (i.e. **bold**, _italic_, ...) cannot be escaped when they are used as a real symbol.


### Markdown TODO Not Working

According to `pandoc -f markdown -t json`, bullet list with todo (`- [ \]`) is treated as a simple
`["-", " ", "[", " ", "]"]` which cannot be converted to norg style (`- ( \)`).

- [x] Fix markdown style todo items


### Obsidian Style Tags Are Not Working

It seems that when the line above a header is not empty, pandoc does not recognize it as a header
but rather a paragraph.
```markdown
#obsidiantag1 #obsidiantag2
# A Header
```

- [x] Convert them to tags in `norg` format
    - Use the `--isObsidian` flag to enable this parse mode.


## Contribution

Any contribution is welcome!! And don't hesitate to send me an issue.

TODO: Write how to build nim project. 2023-10-31, pysan3


## License

All files in this repository without annotation are licensed under the **GPL-3.0 license** as detailed in [LICENSE](#license).
