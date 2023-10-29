import std/options
import std/syncio
import std/strformat

import src/pathlib

type
  PPath = PythonPath

proc getSomeFile*(path: string): auto =
  if path.len() == 0:
    return none(PPath)
  some(Path(path))

proc getFileContent*(file: File): auto =
  file.readAll()

proc getFileContent*(path: PPath): auto =
  if not path.exists():
    raise newException(IOError, &"{path} does not exist.")
  elif not path.is_file():
    raise newException(IOError, &"{path} is not a file.")
  path.open("r").getFileContent()

proc getFileContent*(path: Option[PPath]): auto =
  if path.isNone():
    return stdin.getFileContent()
  path.get().getFileContent()

proc isJson*(path: PPath): auto =
  path.suffix() == ".json"
