import std/options
import std/syncio
import std/strformat
import std/paths
import std/dirs
import std/files

template f*(path: Path): auto =
  string(path)

func `$`*(path: Path): auto =
  path.f

proc bfsFileTree*(rootDir: Path, filename: string, suffix: Option[string] = none(string)): Option[Path] =
  for path in rootDir.walkDirRec({pcFile, pcLinkToFile}, {pcDir, pcLinkToDir}):
    let (dir, basename, ext) = path.splitFile()
    if basename.f == filename and ext == suffix.get(ext):
      return some(path)
    elif suffix.get("-").len() == 0 and (basename.f & ext) == filename:
      return some(path)
  none(Path)

func getSomePath*(path: string): auto =
  if path.len() == 0:
    return none(Path)
  some(Path(path))

proc prepareOutFile*(path: Path, force: bool = false): auto =
  if force or not path.fileExists():
    if not force and (path.parentDir.fileExists() or not path.parentDir.dirExists()):
      raise newException(OSError, &"{path.parentDir} does not exist or is a file. Use `-f` flag to force creatation.")
    path.parentDir.createDir()
  else:
    raise newException(OSError, &"{path} already exists. Use `-f` flag to overwrite.")
  path.f.open(fmWrite)

proc prepareOutFile*(path: Option[Path], force: bool = false): auto =
  if path.isNone():
    return stdout
  path.get().prepareOutFile(force)

proc getFileContent*(file: File): auto =
  defer: file.close()
  file.readAll()

proc getFileContent*(path: Path): auto =
  if not path.fileExists():
    raise newException(IOError, &"{path} does not exist or is not a file.")
  path.f.open(fmRead).getFileContent()

proc getFileContent*(path: Option[Path]): auto =
  if path.isNone():
    return stdin.getFileContent()
  path.get().getFileContent()

proc isJson*(path: Path): auto =
  path.splitFile().ext == ".json"
