import std/sequtils
import std/syncio
import std/strutils
import std/strformat
import std/tables
import std/re
import std/logging

import nim_pandoc

import str_utils
import utils

const symbols = {
  "Emph": "/",
  "Underline": "_",
  "Strong": "*",
  "Strikeout": "-",
  "Superscript": "^",
  "Subscript": ",",
  "SmallCaps": "/",
  "NullModifier": "%",
}.toTable()

var logger = newFileLogger(stderr, lvlAll)

proc toStr*(self: PDInline): string
proc toStr*(self: PDBlock, indent: int = 0): string
proc toStr*(self: seq[PDBlock], indent: int = 0): seq[string] =
  self.mapIt(it.toStr(indent))

proc toStr*(self: seq[PDInline]): string =
  self.map(toStr).join("")

proc toStr*(self: PDTarget): string =
  self.url

proc toStr*(self: PDInlineStr): string =
  self.c

proc toStr*(self: PDInlineSpace): string =
  case self.t:
    of "Space":
      result = " "
    of "SoftBreak":
      result = ""
    of "LineBreak":
      result = "\n\n"
    else:
      unreachable(&"PDInlineSpace: {self.t=}")

func linkMaybeMergeable*(tag: string, target: string): (bool, string) =
  # debugEcho &"`{tag=}`"
  # debugEcho &"`{target=}`"
  # defer:
  #   debugEcho &"`{result=}`"
  if target.len() == 0:
    return (true, &"# {tag}")
  var noDashes = target.replace('-', ' ')
  if noDashes.startsWith("##"):
    noDashes = noDashes.substr(1)
  if noDashes.startsWith('#'):
    if noDashes == "#":
      return (false, "")
    elif tag.toLower() == noDashes.substr(1).toLower():
      return (true, &"# {tag}")
    elif noDashes.startsWith(re"#h[1-6] ") and noDashes[2].isDigit():
      let headings = '*'.repeat(noDashes[2..<3].parseInt()) & " "
      if noDashes.substr(4).toLower() == tag.toLower():
        return (true, headings & tag)
      else:
        return (false, headings & noDashes.substr(4).toLower())
    elif noDashes.startsWith("#def_"):
      return (true, &"$ {tag}")
    elif noDashes.startsWith("#fn_"):
      return (true, &"^ {tag}")
    else:
      return (false, target)
  # let hashPlace = noDashes.find('#')
  # let heading = linkMaybeMergeable()
  # let maybePath = if hashPlace < 0: target else: target.substr(0, hashPlace)
  # if maybePath.startsWith('/') or maybePath.endsWith('/'):
  #   return (true, &"/ {maybePath}")
  (false, &"{target}")

proc toStr*(self: PDInlineLink): string =
  let (attr, inlines, target) = self.c
  let tag = inlines.toStr()
  case self.t:
    of "Link":
      let (skipTag, newTarget) = linkMaybeMergeable(tag, target.toStr())
      if newTarget.len() > 0:
        result = &"{{{newTarget}}}"
      if not skipTag and tag.len() > 0:
        result &= &"[{tag}]"
    of "Image":
      logger.log(lvlWarn, "I'm sure this is NOT the correct image syntax... Please help!!")
      return [&"Alt text: {tag}", &".image {target}", ""].join("\n")
    else:
      unreachable(&"PDInlineLink: {self.t=}")

proc toStr*(self: PDInlineCode): string =
  let (attr, text) = self.c
  &"`{text}`"

proc toStr*(self: PDInlineEmph): string =
  symbols[self.t] & self.c.toStr() & symbols[self.t]

proc parseHTML*(s: string): string =
  const html2symbols = {
    "sub": "Subscript",
    "sup": "Superscript",
    "u": "Underline",
    "!-- null modifier --": "NullModifier",
  }.toTable()
  var matches: array[1, string]
  if s.match(re"</?([a-z!\-\s]+)>", matches) and html2symbols.hasKey(matches[0]):
    return symbols[html2symbols[matches[0]]]
  elif s.startsWith("<!--"):
    logger.log(lvlWarn, &"Could not parse {s}. Possibly a comment.")
    return s
  unreachable(&"parseHTML: {s=}")

proc toStr*(self: PDInlineRawInline): string =
  let (format, text) = self.c
  case format:
    of "html":
      return text.parseHTML()
    else:
      unreachable(&"PDInlineRawInline: {format=}, {text=}")

proc toStr*(self: PDInlineQuoted): string =
  let (quoteType, inlines) = self.c
  let quote = if quoteType.t == "SingleQuote": "'" else: "\""
  quote & inlines.toStr() & quote

proc toStr*(self: PDCitation): string =
  logger.log(lvlWarn, "Cite is not fully implemented yet: ", self)
  &"[{self.citationId}]"

proc toStr*(self: PDInlineCite): string =
  let (cites, inlines) = self.c
  inlines.toStr() & " " & cites.map(toStr).join("")

proc toStr*(self: PDInlineSpan): string =
  let (attr, inlines) = self.c
  &"<{inlines.toStr()}>"

proc toStr*(self: PDInlineMath, indent: int = 0): string =
  let (mathType, text) = self.c
  case mathType.t:
    of "DisplayMath":
      logger.log(lvlError, "Do we have norg syntax for math block??")
      unreachable(&"PDBlockMath: math block unparsable. {mathType.t}: {text=}")
    of "InlineMath":
      return &"${text}$"
    else:
      unreachable(&"PDBlockMath: unknown math type. {mathType.t=}")

proc toStr*(self: PDInline): string =
  case self.t:
    of "Space", "SoftBreak", "LineBreak":
      return cast[PDInlineSpace](self).toStr()
    of "Str":
      return cast[PDInlineStr](self).toStr()
    of "Emph", "Underline", "Strong", "Strikeout", "Superscript", "Subscript", "SmallCaps":
      return cast[PDInlineEmph](self).toStr()
    of "Quoted":
      return cast[PDInlineQuoted](self).toStr()
    of "Cite":
      return cast[PDInlineCite](self).toStr()
    of "Code":
      return cast[PDInlineCode](self).toStr()
    of "Math":
      return cast[PDInlineMath](self).toStr()
    of "RawInline":
      return cast[PDInlineRawInline](self).toStr()
    of "Span":
      return cast[PDInlineSpan](self).toStr()
    of "Link", "Image":
      return cast[PDInlineLink](self).toStr()
    else:
      unreachable(&"PDInline: {self.t=}")

proc toStr*(self: PDBlockHeader, indent: int = 0): string =
  let (level, key, text) = self.c
  joinSepLn([
    "*".repeat(level),
    text.map(toStr).join(""),
  ])

proc toStr*(self: PDBlockBulletList, indent: int = 0): string =
  defer:
    if indent == 0:
      result &= "\n"
  self.c.mapIt(it.toStr(indent + 1)).mapIt(it.join("")).mapIt("\n" & "-".repeat(indent + 1) & &" {it}").join("")

proc toStr*(self: PDBlockOrderedList, indent: int = 0): string =
  let (_, blocks) = self.c
  defer:
    if indent == 0:
      result &= "\n"
  blocks.mapIt(it.toStr(indent + 1)).mapIt(it.join("")).mapIt("\n" & "~".repeat(indent + 1) & &" {it}").join("")

proc compileDefinition*(item: (seq[PDInline], seq[seq[PDBlock]]), indent: int = 0): string =
  let (inlines, blocks) = item
  let
    inlineContent = inlines.toStr()
    blockContent = blocks.mapIt(it.toStr(indent + 1)).mapIt(it.join("")).join("")
  if blockContent.find('\n') < 0:
    return &"\n$ {inlineContent}\n{blockContent}\n"
  else:
    return ["", &"$$ {inlineContent}", blockContent, "$$"].join("\n")

proc toStr*(self: PDBlockDefinitionList, indent: int = 0): string =
  self.c.mapIt(it.compileDefinition(indent)).join("\n")


proc toStr*(self: PDBlockPlain, indent: int = 0): string =
  result = self.c.map(toStr).join("")
  if self.t == "Plain":
    discard
  elif self.t == "Para":
    if indent == 0:
      result = "\n" & result & "\n"
  else:
    unreachable(&"PDBlockPlain: {self.t=}")

proc toStr*(self: PDBlockCodeBlock, indent: int = 0): string =
  let (attr, code) = self.c
  let lang = if attr.classes.len > 0: attr.classes[0] else: ""
  [&"\n@code {lang}", code, "@end\n"].join("\n")

proc toStr*(self: PDBlockHorizontalRule, indent: int = 0): string =
  "\n___"

proc toStr*(self: PDBlockLineBlock, indent: int = 0): string =
  unreachable(&"LineBlock: {self.t=}, {self.c=}")
  "LineBlock"

proc toStr*(self: PDBlockBlockQuote, indent: int = 0): string =
  unreachable(&"BlockQuote: {self.t=}, {self.c=}")
  "BlockQuote"

proc toStr*(self: PDBlockRawBlock, indent: int = 0): string =
  unreachable(&"RawBlock: {self.t=}, {self.c=}")
  "RawBlock"

proc toStr*(self: PDBlockDiv, indent: int = 0): string =
  let (attr, blocks) = self.c
  blocks.toStr().join("")

proc toStr*(self: PDBlockFigure, indent: int = 0): string =
  unreachable(&"Figure: {self.t=}, {self.c=}")
  "Figure"

proc toStr*(self: PDBlockTable, indent: int = 0): string =
  unreachable(&"Table: {self.t=}, {self.c=}")
  "Table"

proc toStr*(self: PDBlock, indent: int = 0): string =
  case self.t:
    of "HorizontalRule":
      return cast[PDBlockHorizontalRule](self).toStr(indent)
    of "Plain", "Para":
      return cast[PDBlockPlain](self).toStr(indent)
    of "LineBlock":
      return cast[PDBlockLineBlock](self).toStr(indent)
    of "BlockQuote":
      return cast[PDBlockBlockQuote](self).toStr(indent)
    of "BulletList":
      return cast[PDBlockBulletList](self).toStr(indent)
    of "DefinitionList":
      return cast[PDBlockDefinitionList](self).toStr(indent)
    of "CodeBlock":
      return cast[PDBlockCodeBlock](self).toStr(indent)
    of "RawBlock":
      return cast[PDBlockRawBlock](self).toStr(indent)
    of "OrderedList":
      return cast[PDBlockOrderedList](self).toStr(indent)
    of "Div":
      return cast[PDBlockDiv](self).toStr(indent)
    of "Header":
      return cast[PDBlockHeader](self).toStr(indent)
    of "Figure":
      return cast[PDBlockFigure](self).toStr(indent)
    of "Table":
      return cast[PDBlockTable](self).toStr(indent)
    else:
      unreachable(&"PDBlock: {self.t=}")
