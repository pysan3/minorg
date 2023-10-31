import std/json
import std/syncio
import std/logging
import std/jsonutils
import std/options
import std/strformat

import nim_pandoc
import src/utils
import src/file_utils
import src/pd2norg
import src/log_utils

proc parse(input: string = "", output: string = "", verbose: bool = false, force: bool = false): int =
  todo()

proc generate(input: string = "", output: string = "", verbose: bool = false, force: bool = false): int =
  let
    inPath = getSomePath(input)
    outPath = getSomePath(output)
  setLogger(if verbose: lvlDebug else: lvlInfo)
  logInfo("Output to: " & (if outPath.isSome(): $outPath.get() else: "stdout"))
  logInfo("Reading from: " & (if inPath.isSome(): $inPath.get() else: "stdin"))
  if inPath.isSome() and not inPath.get().isJson():
    raise newException(IOError, &"{inPath.get()} is not json.")
  let jobj = inPath.getFileContent().parseJson()
  let blocks = jsonTo(jobj["blocks"], seq[PDBlock])
  let outFile = outPath.prepareOutFile(force)
  defer: outFile.close()
  for blk in blocks:
    logDebug(blk)
    outFile.writeLine(blk.toStr())
  return 0

when isMainModule:
  import cligen
  const help = {
    "input": "Input file. Leave it blank to use stdin.",
    "output": "Output file. Leave it blank to use stdout.",
    "verbose": "Outputs debug info to stderr.",
    "force": "Overwrite files and create parent folders if needed.",
  }
  dispatchMulti(
    [parse, help = help],
    [generate, help = help],
  )
