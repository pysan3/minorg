---
title: 
description: 
authors: 
categories: 
created: 
updated: 
version: 
---


# Nim Norg


![![CI status](https://github.com/alaviss/union/workflows/CI/badge.svg)](https://github.com/pysan3/nim_norg/actions?query=workflow%3ACI)
![Minimum supported Nim version](https://img.shields.io/badge/nim-2.0.0%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/pysan3/nim_norg?style=flat)](#license)

`Pandoc json` -> `norg` converter written in the [Nim](https://nim-lang.org/) language.

*This README is generated from [./README.norg](#readmenorg).


## Get Started

- Download: [https://github.com/pysan3/nim_norg/releases](https://github.com/pysan3/nim_norg/releases)
- API documentation: [https://pysan3.github.io/nim_norg/](https://pysan3.github.io/nim_norg/)


## Usage

### Command

- Usage: [./usage.txt](./usage.txt)
    - Generate: [./usage.generate.txt](./usage.generate.txt)
    - Parse:    **WIP**


### Example

- Use `-i`, `-o` flags (`--input`, `--output`)
```bash
$ wget https://raw.githubusercontent.com/nvim-neorg/norg-specs/main/1.0-specification.norg
$ norganic json --input ./1.0-specifications.norg --output ./parsed.json
$ nim_norg generate -i ./parsed.json -o out.norg
$ nvim out.norg
```
- Use `stdin`, `stdout`
```bash
$ wget https://raw.githubusercontent.com/nvim-neorg/norg-specs/main/1.0-specification.norg
$ norganic json --input ./1.0-specifications.norg | nim_norg generate > out.norg
$ nvim out.norg
```


## Known Issues



###  File Linking

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


###  Espace Modifiers

Modifier chars (i.e. **bold**, _italic_, ...) cannot be escaped when they are used as a real symbol.


###  `|example` Is Not Restored Correctly

This is a problem in `norganic` / `Norg.jl`.
- [ ] I will make a PR later.


## Contribution

Any contribution is welcome!! And don't hesitate to send me an issue.


## TODOs

This was created for a proof of concept. Everything is duct-taped together.
I really need to clean the code.


## License

All files in this repository without annotation are licensed under the **GPL-3.0 license** as detailed in [LICENSE](#license).
