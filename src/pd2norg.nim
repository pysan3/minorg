import std/tables
import std/options
import std/sequtils
import std/tables
import std/strutils
import std/strformat
import std/macros
import std/paths
import std/enumerate

import regex
import nim_pandoc

import str_utils
import log_utils
import config_utils
import file_utils
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

type
  ReplacePair = tuple
    src: string
    dst: string
  ObsLinkItem = tuple
    mdPath: Option[Path]
    rawPath: Option[Path]
    display: Option[string]
    items: seq[string]
  Coord = tuple
    row: int
    col: int
  Cell = tuple
    start: Coord
    until: Coord
    content: string
    attr: PDAttr
    align: PDAlignment
  CellManager = ref object of RootObj
    t: TableRef[int, seq[bool]]
    colCount: int

func chainReplace*(s: string, replaces: openArray[ReplacePair]): auto =
  unpackVarargs(s.multiReplace, replaces.mapIt((it.src, it.dst)))

func escapeSpaces*(s: string): auto =
  s.replace(" ", "\\ ")

func joinWithNewline*(strs: varargs[string, `$`]): auto =
  "\n" & strs.join("\n") & "\n"

func lstrip*(s: string, chars: set[char] = Whitespace): auto =
  s.strip(leading = true, trailing = false, chars = chars)

func rstrip*(s: string, chars: set[char] = Whitespace): auto =
  s.strip(leading = false, trailing = true, chars = chars)

func iterEnum*[T](arr: openArray[T]): seq[(int, T)] =
  for (i, e) in enumerate(arr):
    result.add((i, e))

proc toStr*(self: PDInline): string
proc toStr*(self: PDBlock, indent: int = 0): string

func c*(row, col: int): Coord =
  (row, col)

func `+`*(self, o: Coord): auto =
  c(self.row + o.row, self.col + o.col)

func `==`*(self, o: Coord): auto =
  self.row == o.row and self.col == o.col

func filterJoin*(self: openArray[string], sep: string = "\n"): auto =
  self.filterIt(it.len() > 0).join(sep)

proc attachAttr*(s: string, attr: PDAttr, global: bool = true): string =
  let tagChar = if global: "#" else: "+"
  result = s
  if attr.identifier.len() > 0:
    defer: result = &"\n{tagChar}id {attr.identifier}\n" & result.lstrip()
  if attr.classes.len() > 0:
    defer: result = tagChar & "class " & attr.classes.mapIt(it.strip().escapeSpaces()).join(" ") & "\n" & result.lstrip()
  if attr.pairs.len() > 0:
    defer:
      let pairs = attr.pairs.mapIt(&"{tagChar}{it.key.strip()} {it.value.strip().escapeSpaces()}").join("\n")
      result = pairs & "\n" & result.lstrip()

proc toStr*(self: seq[PDBlock], indent: int = 0): seq[string] =
  self.mapIt(it.toStr(indent))

proc toStr*(self: seq[PDInline]): string =
  result = self.map(toStr).join("")
  if result.startsWith("- ["):
    return result.replace(re2"- [(.)]", "- ($1)")

proc toStr*(self: PDTarget): string =
  self.url

proc toStr*(self: PDCaption, indent: int = 0): string =
  self[1].toStr().join("")

proc toStr*(self: PDInlineStr): string =
  result = self.c
  if result == "[x]" or result == "☒": # markdown style todo
    return "(x)"
  elif result == "☐": # markdown style todo
    return "( )"

proc toStr*(self: PDInlineSpace): string =
  case self.t:
    of "Space":
      result = " "
    of "SoftBreak":
      result = "\n"
    of "LineBreak":
      result = "\n\n"
    else:
      unreachable(&"PDInlineSpace: {self.t=}")

func linkMaybeMergeable*(tag: string, target: string): (bool, string) =
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
    elif noDashes.startsWith(re2"#h[1-6] ") and noDashes[2].isDigit():
      let headings = '*'.repeat(noDashes[2 ..< 3].parseInt()) & " "
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

proc generateImageTag(tag: string, url: string): string =
  result = &".image {url}\n"
  if tag.len() > 0:
    result = &".alt {tag}\n{result}"

proc toStr*(self: PDInlineLink): string =
  let (attr, inlines, target) = self.c
  defer: result = result.attachAttr(attr)
  let tag = inlines.toStr()
  case self.t:
    of "Link":
      let (skipTag, newTarget) = linkMaybeMergeable(tag, target.toStr())
      if newTarget.len() > 0:
        result = &"{{{newTarget}}}"
      if not skipTag and tag.len() > 0:
        result &= &"[{tag}]"
    of "Image":
      logWarn(&"I'm sure this is NOT the correct image syntax... Please help: {target}")
      return generateImageTag(tag, target.url)
    else:
      unreachable(&"PDInlineLink: {self.t=}")

proc escapeBar*(text: string): string =
  if text.startsWith('|') or text.endsWith('|'):
    return "|" & text & "|"
  return text

proc toStr*(self: PDInlineCode): string =
  let (attr, text) = self.c
  let lang = if attr.classes.len > 0: &"(code:{attr.classes[0]})" else: ""
  &"`{escapeBar(text)}`{lang}"

proc toStr*(self: PDInlineEmph): string =
  let symbol = symbols[self.t]
  defer: result = &"{symbol}{escapeBar(result)}{symbol}"
  result = self.c.toStr()
  if result[^1] == '\n':
    return result[0 ..< ^1]

proc rawEmbed*(s: string, lang: string): string =
  if s.find('\n') < 0:
    return &"`|{s}|`(embed:{lang})"
  else:
    return joinWithNewline("@embed " & lang, s.strip(), "@end")

proc parseHTML*(s: string): string =
  const html2symbols = {
    "sub": "Subscript",
    "sup": "Superscript",
    "u": "Underline",
    "!-- null modifier --": "NullModifier",
  }.toTable()
  var m: RegexMatch2
  if s.len() == 0:
    return s
  elif s.find(re2"^</?label>.*", m):
    let startFrom = m.boundaries.b + 1
    if startFrom >= s.len():
      return ""
    else:
      return s.substr(startFrom).parseHTML()
  elif s.match(re2"</?([a-z!\-\s]+)>", m) and html2symbols.hasKey(s[m.group(0)]):
    return symbols[html2symbols[s[m.group(0)]]]
  rawEmbed(s, "html")

proc toStr*(self: PDInlineQuoted): string =
  let (quoteType, inlines) = self.c
  let quote = if quoteType.t == "SingleQuote": "'" else: "\""
  quote & inlines.toStr() & quote

proc toStr*(self: PDCitation): string =
  logWarn("Cite is not fully implemented yet: ", self)
  &"[{self.citationId}]"

proc toStr*(self: PDInlineCite): string =
  let (cites, inlines) = self.c
  inlines.toStr() & " " & cites.map(toStr).join("")

proc toStr*(self: PDInlineSpan): string =
  let (attr, inlines) = self.c
  result = inlines.toStr()
  if result.len() > 0:
    return &"<{result}>"

proc toStr*(self: PDInlineMath): string =
  let (mathType, text) = self.c
  case mathType.t:
    of "DisplayMath":
      return joinWithNewline("@math", text, "@end")
    of "InlineMath":
      return &"${text}$"
    else:
      unreachable(&"PDBlockMath: unknown math type. {mathType.t=}")

proc toStr*(self: PDInlineRawInline): string =
  let (format, text) = self.c
  case format:
    of "html":
      return text.parseHTML()
    of "latex":
      if text == """$\square$""":
        logWarn("Detached modifier extension detected for heading. Pandoc looses information about the TODO status.")
        return "( )"
      return &"${text.replace('$', ' ').strip()}$"
    else:
      rawEmbed(text.strip(), format)

proc toStr*(self: PDInlineNote): string =
  self.c.toStr().join("")

proc toStr*(self: PDInline): string =
  case self.t:
    of "Space", "SoftBreak", "LineBreak":
      return cast[PDInlineSpace](self).toStr()
    of "Str":
      return cast[PDInlineStr](self).toStr()
    of "Emph", "Underline", "Strong", "Strikeout", "Superscript", "Subscript", "SmallCaps":
      return cast[PDInlineEmph](self).toStr()
    of "Note":
      return cast[PDInlineNote](self).toStr()
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
    return joinWithNewline(&"$ {inlineContent}", blockContent)
  else:
    return joinWithNewline(&"$$ {inlineContent}", blockContent, "$$")

proc toStr*(self: PDBlockDefinitionList, indent: int = 0): string =
  self.c.mapIt(it.compileDefinition(indent)).join("\n")

proc mergeObsidianTags*(strBlock: var string): seq[string] =
  var match: RegexMatch2
  while strBlock.find(re2"#label [^\n]+\n#label ([^\n]+)", match):
    let slice = match.group(0)
    let label = strBlock[slice].strip().escapeSpaces()
    const ignore = "\n#label ".len()
    result.add(label)
    strBlock = &"{strBlock[0 ..< slice.a - ignore]} {label} {strBlock.substr(slice.b + 1)}"

proc detectObsidianTags*(strBlock: var string): seq[string] =
  let tagMatches = strBlock.findAll(re2"#([a-zA-Z][\w\-_/]+)[\n\s]")
  if tagMatches.len() == 0:
    return
  let matches = tagMatches.mapIt(strBlock[it.group(0)])
  strBlock = strBlock.chainReplace(matches.mapIt((src: "#" & it, dst: "\n#label " & it)))
  result = strBlock.mergeObsidianTags()
  for match in strBlock.findAll(re2"\n(#+) "):
    strBlock[match.group(0)] = '*'.repeat(match.group(0).len())

proc parseObsidianLink*(link: string, workRootDir: Path): ObsLinkItem =
  var vertBar = link.find('|')
  if vertBar < 0:
    vertBar = link.len()
  else:
    result.display = some(link.substr(vertBar + 1))
  let items = link[0 ..< vertBar].split('#')
  if items.len() > 1:
    result.items.add(items[1 .. ^1].filterIt(not it.startsWith('^')))
  result.rawPath = workRootDir.bfsFileTree(items[0], some(""))
  if result.rawPath.isNone():
    result.mdPath = workRootDir.bfsFileTree(items[0], some(".md"))

proc detectObsidianLinks*(strBlock: var string): seq[string] =
  var replaces = newSeq[ReplacePair]()
  let workRootDir = getConfig().workRootDir
  for match in strBlock.findAll(re2"""\[\[([^\n]+)\]\]"""):
    let s = strBlock[match.group(0)]
    logDebug(s)
    let item = s.parseObsidianLink(workRootDir)
    let display = if item.display.isSome(): &"[{item.display.get()}]" else: ""
    if item.rawPath.isSome():
      let relative = item.rawPath.get().relativePath(workRootDir).string
      result.add(s)
      if match.group(0).a >= 3 and strBlock[match.group(0).a - 3] == '!': # Image
        let imgTagString = generateImageTag(item.display.get(""), escapeSpaces(&"$/{relative}"))
        replaces.add((src: &"""![[{s}]]""", dst: "\n" & imgTagString))
      else:
        replaces.add((src: &"""[[{s}]]""", dst: &"""{{/ $/{relative}}}{display}"""))
    elif item.mdPath.isSome():
      let relative = item.mdPath.get().relativePath(workRootDir).changeFileExt("").string
      var headers: string
      if item.items.len() == 1:
        headers = &"# {item.items[0]}"
      else:
        headers = item.items.zip(toSeq(1 .. item.items.len())).mapIt('*'.repeat(it[1]) & &" {it[0]}").join(" : ")
      result.add(s)
      replaces.add((src: &"""[[{s}]]""", dst: &"""{{:$/{relative}:{headers}}}{display}"""))
    else:
      logWarn(&"Found tag: '{s}' but reference not found in {workRootDir=}.")
  strBlock = strBlock.chainReplace(replaces)

proc toStr*(self: PDBlockPlain, indent: int = 0): string =
  result = self.c.mapIt(it.toStr()).join("") & " "
  let isObsidian = getConfig().isObsidian
  if isObsidian:
    let linkDetected = result.detectObsidianLinks()
    if linkDetected.len() > 0:
      logInfo(&"Obsidian link detected: {linkDetected}")
  if self.t == "Plain":
    discard
  elif self.t == "Para":
    if isObsidian:
      let tagDetected = result.detectObsidianTags()
      if tagDetected.len() > 0:
        logInfo(&"Obsidian tag detected: {tagDetected}")
    if indent == 0:
      result = "\n" & result & "\n"
  else:
    unreachable(&"PDBlockPlain: {self.t=}")

proc toStr*(self: PDBlockCodeBlock, indent: int = 0): string =
  let (attr, code) = self.c
  let lang = if attr.classes.len > 0: attr.classes[0] else: ""
  if lang == "norg":
    return joinWithNewline("|example", code.strip(chars = Newlines), "|end")
  else:
    return joinWithNewline("@code " & lang, code.strip(chars = Newlines), "@end")

proc toStr*(self: PDBlockHorizontalRule, indent: int = 0): string =
  "\n___"

proc toStr*(self: PDBlockLineBlock, indent: int = 0): string =
  logWarn(&"LineBlock is not supported in norg format for now. Using `chunk` tag.")
  joinWithNewline("|chunk", self.c.map(toStr).join("\n"), "|end")

proc toStr*(self: PDBlockBlockQuote, indent: int = 0): string =
  defer:
    if indent == 0:
      result &= "\n"
  self.c.mapIt(it.toStr(indent + 1)).mapIt(it.join("")).mapIt("\n" & ">".repeat(indent + 1) & &" {it}").join("")

proc toStr*(self: PDBlockFigure, indent: int = 0): string =
  let (attr, caption, blocks) = self.c
  defer: result = result.attachAttr(attr)
  let captionString = caption.toStr(indent)
  result = blocks.toStr().join("")
  if not result.contains(captionString):
    logWarn(&"Add caption: `{captionString}` to image. I don't know the syntax tho...")
    return ["|caption " & captionString, result.strip(), "|end"].join("\n")

proc toStr*(self: PDBlockRawBlock, indent: int = 0): string =
  let (format, text) = self.c
  case format:
    of "html":
      return text.parseHTML()
    else:
      rawEmbed(text.strip() & "\n", format)

proc toStr*(self: PDBlockDiv, indent: int = 0): string =
  let (attr, blocks) = self.c
  blocks.toStr().join("").attachAttr(attr)

proc calcTableColumnName*(num: int): string =
  if num < 0:
    return ""
  const
    a = int('A')
    n = UppercaseLetters.len()
  return calcTableColumnName(num div n - 1) & char(num mod n + a)

proc calcTableCellName*(coord: Coord): string =
  calcTableColumnName(coord.col) & $(coord.row + 1)

proc parseTableAlignment*(alignment: PDAlignment, col: int = -1, global: bool = false): string =
  const tableAlignmentLookup = {
    "AlignLeft": "left",
    "AlignCenter": "center",
    "AlignRight": "right",
  }.toTable()
  if not tableAlignmentLookup.hasKey(alignment.t):
    return ""
  let tagChar = if global: "#" else: "+"
  let alignWhat = if col < 0: "align" else: "align.columns"
  &"{tagChar}{alignWhat} {calcTableColumnName(col)} " & tableAlignmentLookup[alignment.t]

proc tableShortColSpec(specs: seq[PDColSpec]): string =
  specs.mapIt(it[0]).iterEnum().mapIt(it[1].parseTableAlignment(it[0], true)).join("\n")

proc bootstrapCell*(self: Cell): string =
  var cellCoord = self.start.calcTableCellName()
  let content = self.content.strip()
  if not (self.start == self.until):
    cellCoord.add("-" & self.until.calcTableCellName())
  if content.contains('\n'): # multi line cell
    result = [":: " & cellCoord, content, "::"].join("\n")
  else: # single line cell
    result = &": {cellCoord} : {content}"
  let alignText = self.align.parseTableAlignment()
  if alignText.len() > 0:
    result = alignText & "\n" & result
  return result.attachAttr(self.attr)

proc parseTableCell*(self: PDCell, useCoord: Coord): (Cell, int, int) =
  let until = useCoord + c(self[2] - 1, self[3] - 1)
  ((useCoord, until, self[4].toStr().join(""), self[0], self[1]), self[2], self[3])

proc setValue*(self: CellManager, coord: Coord, value: bool) =
  if coord.col >= self.colCount:
    return
  if not self.t.hasKey(coord.row):
    self.t[coord.row] = newSeq[bool](self.colCount)
  self.t[coord.row][coord.col] = value

proc getValue*(self: CellManager, coord: Coord): auto =
  if coord.col >= self.colCount:
    return false
  if not self.t.hasKey(coord.row):
    self.t[coord.row] = newSeq[bool](self.colCount)
  self.t[coord.row][coord.col]

proc getFirstEmpty*(self: CellManager, coord: Coord): auto =
  for i in coord.col ..< self.colCount:
    if not self.getValue(c(coord.row, i)):
      return i

proc occupyCells*(self: CellManager, start: Coord, useRows, useCols: int) =
  if useRows == 1 and useCols == 1:
    self.setValue(start, true)
    return
  for i in 0 ..< useRows:
    for j in 0 ..< useCols:
      self.setValue(start + c(i, j), true)

proc fillTable*(rows: seq[PDRow], colCount: int, startRow: int = 0): seq[Cell] =
  var cellManager = CellManager(t: newTable[int, seq[bool]](), colCount: colCount)
  let rowOffset = c(startRow, 0)
  for (i, row) in enumerate(rows):
    for (j, col) in enumerate(row[1]):
      let rowNum = i + startRow
      let coord = c(rowNum, cellManager.getFirstEmpty(c(rowNum, j)))
      let (cell, useRows, useCols) = col.parseTableCell(coord)
      cellManager.occupyCells(coord, useRows, useCols)
      if cell.content.len() > 0:
        result.add(cell)

func shiftSlice*[T](self: Slice[T], shift: T): auto =
  (self.a + shift) .. (self.b + shift)

proc parseTableBody*(self: PDTableBody, colCount: int, startRow: int): string =
  let bodySlice = (0 ..< self[3].len()).shiftSlice(startRow + self[2].len())
  let head = fillTable(self[2], colCount, startRow).map(bootstrapCell).join("\n")
  let body = fillTable(self[3], colCount, bodySlice.a).map(bootstrapCell).join("\n")
  if body.len() > 0:
    result.add(&"#table.head.columns {bodySlice.a + 1}")
    if bodySlice.b > bodySlice.a:
      result.add(&"-{bodySlice.b + 1}")
    result.add(&" {self[1]}\n")
  result.add([head, body].filterJoin("\n+hline\n"))

proc toStr*(self: PDBlockTable, indent: int = 0): string =
  let (attr, caption, col, head, body, foot) = self.c
  let captionString = caption.toStr(indent)
  let colCount = col.len()
  var rowCount = 0
  defer:
    if captionString.len() > 0:
      result = joinWithNewline("|caption " & captionString, result.strip(), "|end") & "\n"
  var accumulator = newSeq[string]()
  var headCounts = newSeq[int]()
  result.add("\n")
  result.add(tableShortColSpec(col))
  accumulator.add(fillTable(head[1], colCount, rowCount).map(bootstrapCell).join("\n"))
  rowCount += head[1].len()
  for tbody in body:
    accumulator.add(tbody.parseTableBody(colCount, rowCount))
    rowCount += tbody[2].len() + tbody[3].len()
  defer:
    result = result & "\n" & accumulator.join("\n+hline2\n") & "\n\n"

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
