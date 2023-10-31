# Nim module to wrap the procs in the os module and provide an
# interface as similar as possible to Python's pathlib.

# Written by Adam Chesak.
# Released under the MIT open source license.
# Modified by: pysan3 2023-10-31 and onwards


## pythonpathlib is a Nim module that provides an interface for working with paths that
## is as similar as possible to Python's ``pathlib`` module.
##
## Examples:
##
## .. code-block:: nimrod
##
##    # Create two paths, check if they are equal, and append another directory to the first path.
##    var path1 : PythonPath = Path("/home/adam/")
##    var path2 : PythonPath = Path("/home/user")
##    echo(path1 == path2) # false
##    path1 = path1 / "nim" / "pythonpathlib"
##    echo(path1) # "/home/adam/nim/pythonpathlib"
##
## .. code-block:: nimrod
##
##    # Create a path and output the parent directories of the path.
##    var path : PythonPath = Path("/home/adam/nim/pythonpathlib/pythonpathlib.nim")
##    var parents : seq[string] = path.parents
##    for i in parents:
##        echo(i)
##    # output:
##    # "/"
##    # "home"
##    # "adam"
##    # "nim"
##    # "pythonpathlib"
##
## .. code-block:: nimrod
##
##    # Create a path, get the name and suffix, and then change both.
##    var path : PythonPath = Path("code/example.nim")
##    echo(path.name) # "example.nim"
##    echo(path.suffix) # ".nim"
##    path = path.withName("newfile.nim")
##    echo(path) # "code/newfile.nim"
##    path = path.withSuffix(".py")
##    echo(path) # "code/newfile.py"
##
## .. code-block:: nimrod
##
##    # Create a path, check whether the path exists, and then see whether it is a file, directory, or symlink.
##    var path : PythonPath = Path("/home/adam")
##    echo(path.exists()) # true
##    echo(path.isFile()) # false
##    echo(path.isDir()) # true
##    echo(path.isSymlink()) # false
##
## .. code-block:: nimrod
##
##    # Create a path, rename the path it represents to something else, and then force another rename.
##    var path : PythonPath = Path("code/example.nim")
##    path.rename("code/newexample.nim")
##    # path.rename(Path("code/newexample.nim")) also works
##    path.replace("code/testing.nim")
##    # if "code/testing.nim" already existed, if would be overritten by the last method.
##
## .. code-block:: nimrod
##
##    # Create a path and get its representation as a file URI.
##    var path : PythonPath = Path("/home/adam/nim/code.nim")
##    var fileURI : string = path.asUri()
##    echo(fileURI) # "file:///home/adam/nim/code.nim"
##
## .. code-block:: nimrod
##
##    # Create a path and compute a version of this path relative to another.
##    var path : PythonPath = Path("/home/adam/nim/code.nim")
##    echo(path.relativeTo("home")) # "adam/nim/code.nim"
##    echo(path.relativeTo("nim")) # "code.nim"
##    echo(path.relativeTo("usr")) # can't do, not on path


import os
import strutils
import algorithm


type
  PythonPath* = ref object
    p*: string


proc Path*(p: string): PythonPath =
  ## Creates a new PythonPath representing the specified file or directory.

  var pypath: PythonPath = PythonPath(p: p)
  return pypath


proc PosixPath*(p: string): PythonPath =
  return Path(p)


proc WindowsPath*(p: string): PythonPath =
  return Path(p)


proc PurePath*(p: string): PythonPath =
  return Path(p)


proc PurePosixPath*(p: string): PythonPath =
  return Path(p)


proc PureWindowsPath*(p: string): PythonPath =
  return Path(p)


proc `$`*(path: PythonPath): string =
  ## String operator for PythonPath.

  return path.p


proc `==`*(path1: PythonPath, path2: PythonPath): bool =
  ## Equality operator for PythonPath.

  return path1.p == path2.p


proc `!=`*(path1: PythonPath, path2: PythonPath): bool =
  ## Inequality operator for PythonPath.

  return path1.p != path2.p


proc `/`*(path1: PythonPath, path2: string): PythonPath =
  ## Join operator for PythonPath.

  if path1.p.endsWith("/"):
    path1.p = path1.p[0..high(path1.p) - 1]

    return Path(path1.p & "/" & path2)


proc `/`*(path1: PythonPath, path2: PythonPath): PythonPath =
  ## Join operator for PythonPath.

  if path1.p.endsWith("/"):
    path1.p = path1.p[0..high(path1.p) - 1]

    return Path(path1.p & "/" & path2.p)


proc parts*(path: PythonPath): seq[string] =
  ## Returns a seq giving access to the path’s various components.

  var
    part: seq[string] = newSeq[string](0)
    (dir, name, ext) = splitFile(path.p)

  while dir.contains("/"):
    var (d1, d2) = splitPath(dir)
    part.add(d2)
    dir = d1
  part.add("/")
  part.reverse()

  if name != "":
    part.add(name)
  if ext != "":
    part.add(ext)

  return part


proc drive*(path: PythonPath): string =
  ## Returns a string representing the drive letter or name, if any.

  var info: FileInfo = getFileInfo(open(path.p))

  return intToStr(int(info.id.device))


proc root*(path: PythonPath): string =
  ## Returns a string representing the root directory, if any.

  if defined(windows):
    return "c:"
  else:
    return "/"


proc parents*(path: PythonPath): seq[PythonPath] =
  ## Returns a sequence providing access to the logical ancestors of the path.

  var
    part: seq[string] = newSeq[string](0)
    dir = splitFile(path.p)[0]

  while dir.contains("/"):
    var (d1, d2) = splitPath(dir)
    part.add(d2)
    dir = d1
  part.add("/")
  part.reverse()

  var part2: seq[PythonPath] = newSeq[PythonPath](len(part))
  for i in 0..high(part):
    part2[i] = Path(part[i])

  return part2


proc parent*(path: PythonPath): PythonPath =
  ## Returns the logical parent of the path.

  if path.p == "/" or path.p == "." or path.p == "..":
    return Path(path.p)

  var p1 = splitPath(path.p)[0]
  if p1 == "":
    p1 = "/"

  return Path(p1)


proc name*(path: PythonPath): string =
  ## Returns a string representing the final path component, excluding the drive and root, if any.

  var
    splitPath = splitFile(path.p)
    name = splitPath[1]
    ext = splitPath[2]

  if name == "":
    return ""

  name &= ext
  return name


proc suffix*(path: PythonPath): string =
  ## Returns the file extension of the final component, if any.

  return splitFile(path.p)[2]


proc suffixes*(path: PythonPath): seq[string] =
  ## Returns a sequence of the path’s file extensions, if any.

  var
    part: seq[string] = newSeq[string](0)
    splitPath = splitFile(path.p)
    name = splitPath[1]
    ext = splitPath[2]

  if ext == "":
    return part

  part.add(ext)
  while ext != "":
    var n: string = name
    name = splitFile(n)[1]
    ext = splitFile(n)[2]
    if ext != "":
      part.add(ext)
  part.reverse()

  return part


proc stem*(path: PythonPath): string =
  ## Returns the final path component, without its suffix.

  return splitFile(path.p)[1]


proc asPosix*(path: PythonPath): string =
  ## Returns a string representation of the path with forward slashes (/).

  if not defined(windows):
    return path.p

  return path.p.replace("\\", "/") # not perfect...


proc asUri*(path: PythonPath): string =
  ## Returns the path as a file URI. Will fail if the path is not absolute.

  doAssert(path.p.isAbsolute(), "asUri(): path must be absolute")

  return "file://" & path.p


proc isReserved*(path: PythonPath): bool =
  ## Returns true if the path is considered reserved under Windows, and false otherwise.

  return false


proc joinpath*(paths: varargs[PythonPath]): PythonPath =
  ## Joins the paths and returns a new PythonPath representing the joined paths.

  var p: seq[string] = newSeq[string](0)
  for i in paths:
    p.add(i.p)

  var newPath: string = p[0]
  for i in 1..high(p):
    newPath = joinPath(newPath, p[i])

  return Path(newPath)


proc relativeTo*(path: PythonPath, other: string): PythonPath =
  ## Returns a new path of this path relative to the path represented by other.

  var
    parents: seq[PythonPath] = path.parents()
    pIndex: int = -1
  for i in 0..high(parents):
    if parents[i].p == other:
      pIndex = i
      break

  doAssert(pIndex != -1, "relativeTo(): no relative path")

  var pStr: string = ""
  for i in pIndex..high(parents):
    pStr &= parents[i].p & "/"

  return Path(pStr)


proc relativeTo*(path: PythonPath, other: PythonPath): PythonPath =
  ## Returns a new path of this path relative to the path represented by other.

  return path.relativeTo(other.p)


proc withName*(path: PythonPath, newName: string): PythonPath =
  ## Returns a new path with the name changed.

  var
    splitPath = splitFile(path.p)
    dir = splitPath[0]
    name = splitPath[1]

  doAssert(name != "", "withName(): no name to change")

  var n: string = ""
  if dir != "":
    n &= dir & "/"

  return Path(n & newName)


proc withSuffix*(path: PythonPath, newSuffix: string): PythonPath =
  ## Returns a new path with the suffix changed.

  var
    splitPath = splitFile(path.p)
    dir = splitPath[0]
    name = splitPath[1]
    n: string = ""

  if dir != "":
    n &= dir & "/"

  doAssert(name != "", "withSuffix(): no name")

  return Path(n & name & newSuffix)


proc stat*(path: PythonPath): FileInfo =
  ## Returns information about this path.

  return getFileInfo(open(path.p))


proc chmod*(path: PythonPath, mode: set[FilePermission]) {.noreturn.} =
  ## Changes the file permissions.

  path.p.setFilePermissions(mode)


proc isDir*(path: PythonPath): bool =
  ## Returns true if the path points to an existing directory, and false otherwise.

  return path.p.dirExists()


proc isFile*(path: PythonPath): bool =
  ## Returns true if the path points to an existing file, and false otherwise.

  return path.p.fileExists()


proc isSymlink*(path: PythonPath): bool =
  ## Returns true if the path points to an existing symlink, and false otherwise.

  return path.p.symlinkExists()


proc exists*(path: PythonPath): bool =
  ## Returns true if the path points to an existing directory or file, and false otherwise.

  return path.isFile() or path.isDir()


proc open*(path: PythonPath, mode: string = "r", buffering: int = -1): File =
  ## Opens the file that the path represents.

  var m: FileMode = fmRead
  if mode == "r" or mode == "rb":
    m = fmRead
  elif mode == "w" or mode == "wb":
    m = fmWrite
  elif mode == "a" or mode == "ab":
    m = fmAppend
  elif mode == "r+" or mode == "rb+":
    m = fmReadWriteExisting
  elif mode == "w+" or mode == "wb+":
    m = fmReadWrite

  return open(path.p, m, buffering)


proc rename*(path1: PythonPath, path2: string) {.noreturn.} =
  ## Renames the path to the given new path. Updates the first path to point to the new path.

  path1.p.moveFile(path2)
  path1.p = path2


proc rename*(path1: PythonPath, path2: PythonPath) {.noreturn.} =
  ## Renames the path to the given new path. Updates the first path to point to the new path.

  path1.p.moveFile(path2.p)
  path1.p = path2.p


proc replace*(path1: PythonPath, path2: string) {.noreturn.} =
  ## Renames this file or directory to the given target. If target points to an existing file or directory, it will be unconditionally replaced.

  removeDir(path2)
  path1.rename(path2)


proc replace*(path1: PythonPath, path2: PythonPath) {.noreturn.} =
  ## Renames this file or directory to the given target. If target points to an existing file or directory, it will be unconditionally replaced.

  removeDir(path2.p)
  path1.rename(path2)


proc mkdir*(path: PythonPath) {.noreturn.} =
  ## Creates a new directory with the name of the path.

  createDir(path.p)


proc resolve*(path: PythonPath) {.noreturn.} =
  ## Sets the path to the full name of the path.

  path.p = expandFilename(path.p)


proc rmdir*(path: PythonPath) {.noreturn.} =
  ## Removes the directory specified by the path.

  removeDir(path.p)
