import std/json
import std/syncio
import std/logging
import std/jsonutils
import std/options
import std/strformat

import nim_pandoc
import src/utils
import src/file_utils
import src/pathlib
import src/pd2norg

var logger = newFileLogger(stderr, lvlAll)

proc parse(input: string = "", output: string = ""): int =
  todo()

proc generate(input: string = "", output: string = ""): int =
  let
    inFile = getSomeFile(input)
    outFile = getSomeFile(output)
  logger.log(lvlInfo, "Output to: " & (if outFile.isSome(): $outFile.get() else: "stdout"))
  logger.log(lvlInfo, "Reading from: " & (if inFile.isSome(): $inFile.get() else: "stdin"))
  if inFile.isSome() and not inFile.get().isJson():
    raise newException(IOError, &"{inFile.get()} is not json.")
  let jobj = inFile.getFileContent().parseJson()
  let blocks = jsonTo(jobj["blocks"], seq[PDBlock])
  for blk in blocks:
    logger.log(lvlDebug, blk)
    echo blk.toStr()
  return 0

when isMainModule:
  import cligen
  const help = {
    "input": "Input file. Leave it blank to use stdin.",
    "output": "Output file. Leave it blank to use stdout."
  }
  dispatchMulti(
    [parse, help = help],
    [generate, help = help],
  )
