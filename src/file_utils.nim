import std/options
import std/syncio
import std/strformat

import src/pathlib

type
  PPath = PythonPath

proc getSomePath*(path: string): auto =
  if path.len() == 0:
    return none(PPath)
  some(Path(path))

proc prepareOutFile*(path: PPath, force: bool = false): auto =
  if force or not path.exists():
    if not force and not (path.parent.exists() and path.parent.isDir()):
      raise newException(OSError, &"{path.parent} does not exist or is a file. Use `-f` flag to force creatation.")
    path.parent.mkdir()
  else:
    raise newException(OSError, &"{path} already exists. Use `-f` flag to overwrite.")
  path.open("w")

proc prepareOutFile*(path: Option[PPath], force: bool = false): auto =
  if path.isNone():
    return stdout
  path.get().prepareOutFile(force)

proc getFileContent*(file: File): auto =
  defer: file.close()
  file.readAll()

proc getFileContent*(path: PPath): auto =
  if not path.exists():
    raise newException(IOError, &"{path} does not exist.")
  elif not path.isFile():
    raise newException(IOError, &"{path} is not a file.")
  path.open("r").getFileContent()

proc getFileContent*(path: Option[PPath]): auto =
  if path.isNone():
    return stdin.getFileContent()
  path.get().getFileContent()

proc isJson*(path: PPath): auto =
  path.suffix() == ".json"
