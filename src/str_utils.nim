import std/strutils

proc joinSepLn*(arr: openArray[string]; sep = " "): auto =
  "\n" & arr.join(sep)
