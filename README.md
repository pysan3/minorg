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


## Table of Contents

- [Get Started](#get-started)
- [Usage](#usage)
    - [Command](#command)
    - [Example](#example)
- [Known Issues](#known-issues)
    - [Obsidian](#obsidian)
- [Compile From Source](#compile-from-source)
- [Contribution](#contribution)
- [License](#license)


## Get Started

- Download: [https://github.com/pysan3/minorg/releases](https://github.com/pysan3/minorg/releases)
- API documentation: [https://pysan3.github.io/minorg/](https://pysan3.github.io/minorg/)


## Usage

### Command

- Usage: [usage.txt](usage.txt)
    - `minorg help`


### Example

#### Basic Usage

- Use `-i`, `-o` flags (`--input`, `--output`)
```bash
$ pandoc -f markdown -t json -o parsed.json ./your/markdown/file.md
$ minorg generate -i parsed.json -o output.norg
```
- Use `stdin`, `stdout`
```bash
$ pandoc -f markdown -t json ./your/markdown/file.md | minorg generate > output.norg
```


#### Other Useful Flags

- `-v`, `--verbose`
    - Please use this flag to report issues.
- `-f`, `--force`
    - Force overwrite output file if exists.
    - Also automatically creates parent directories if not exists.


#### Recursive Directory of Markdown

```bash
command find . -type f -name '*.md' | while read f; do
  pandoc -f markdown -t json "$f" | minorg generate -o "${f}.norg"
done
```


#### Recursive Directory of Obsidian Notes

This parser also takes some amount of care of obsidian specific format.
Please use the `--isObsidian` flag and read [Obsidian Style Tags Are Not Working](#obsidian-style-tags-are-not-working) section for more information.


#### Test It's Capability Against Norg Specification File

```bash
$ wget https://raw.githubusercontent.com/nvim-neorg/norg-specs/main/1.0-specification.norg
$ norganic json --input ./1.0-specifications.norg --output ./parsed.json
$ minorg generate -i ./parsed.json -o out.norg
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


### Obsidian

#### Obsidian Style Tags Are Not Working

It seems that when the line above a header is not empty, pandoc does not recognize it as a header
but rather a paragraph.
```markdown
#obsidiantag1 #obsidiantag2
# A Header
```

- [x] Convert them to tags in `norg` format
    - ❗ Use the `--isObsidian` flag to enable this parse mode.
    - Also pass `--workRootDir=/path/to/workspace` to link with other files (Required).


#### Wikilinks Are Not Working

Obsidian uses its own format to link to other files in the directory.
Obviously this is not an official markdown syntax, and pandoc cannot parse it.
```markdown
[[file name]] -> `./somewhere/in/the/directory/file\ name.md`
![[file name]] -> `./somewhere/in/the/directory/file\ name.png` # Image support
```

- [x] Implement a workaround
    - See [Obsidian Style Tags Are Not Working](#obsidian-style-tags-are-not-working) for the fix.
        - `--isObsidian` and `--workRootDir` required.
    - TODOs
        - [x] `[[file name]]` -> `{:$/somewhere/in/workspace/file name:}` (norg file)
        - [x] `[[file name.txt]]` -> `{/ $/somewhere/in/workspace/file name.txt}` (normal file)
        - [x] `![[file name.png]]` -> `.image $/somewhere/in/workspace/file name.png` (image file)
        - [x] `[[file name#header]]` -> `{:$/somewhere/in/workspace/file name:# head1}` (norg file with any level heading)
        - [x] `[[file name#head1#head2]]` -> `[head2]($/somewhere/in/workspace/file%20name.mdhead1#head2)` (norg file with chained headings)
        - [x] `[[file name|display name]]` -> `{:$/somewhere/in/workspace/file name:}[display name]` (norg file with display name)
        - [x] `[[file name.txt|display name]]` -> `{/ $/somewhere/in/workspace/file name.txt}[display name]` (normal file with display name)
        - [x] `![[file name.png|display name]]` -> `.alt display namen.image $/somewhere/in/workspace/file name.png` (image file with alt text)
        - [x] `[[unknown]]` -> `[[unknown]]` (file not found: do nothing)


## Compile From Source

This project is written in [nim](https://nim-lang.org/) language.
You will need the nim compiler and the package manager `nimble`.


#### Install `choosenim` and `nim` Compiler

If you don't have nim installed yet, I strongly suggest using [choosenim](https://github.com/dom96/choosenim)
to install the required toolkit.
Please read [Choosenim Installation](https://github.com/dom96/choosenim#installation).
Below is the instruction for unix systems.
```bash
$ curl https://nim-lang.org/choosenim/init.sh -sSf | sh
$ export PATH="$HOME/.nimble/bin:$PATH"
$ choosenim stable
# install stable version of nim and nimble
# ... this may take a while
$ nim -v
# ! check nim version >= 2.0.0
```


#### Setup `nimble` and Compile

`nimble` is the packages manager for nim (should be installed into `$HOME/.nimble/bin` by choosenim).
Setup for this repo is very easy.
```bash
$ git clone https://github.com/pysan3/minorg.git
$ cd minorg/
$ nimble sync
# ... Downloads dependencies
$ nim r ./minorg.nim help
# Compiles and runs ./minorg.nim. Passes `help` as an argument to the generated binary.
```


## Contribution

Any contribution is welcome! And don't hesitate to send me an issue.


#### Fix Code and Recompile

```bash
$ pandoc -f markdown -t json -o parsed.json your-test-markdown-file.md
$ nim r ./minorg.nim generate -i parsed.json -v
```

Run `nim r ./minorg.nim help` for more options.


## License

All files in this repository without annotation are licensed under the **GPL-3.0 license** as detailed in [LICENSE](#license).
