import std/logging
import std/syncio

var logger: FileLogger

proc setLogger*(lvl: Level, file: File = stderr) =
  logger = newFileLogger(file, lvl)

proc logDebug*(args: varargs[string, `$`]) {.inline.} =
  logger.log(lvlDebug, args)

proc logInfo*(args: varargs[string, `$`]) {.inline.} =
  logger.log(lvlInfo, args)

proc logWarn*(args: varargs[string, `$`]) {.inline.} =
  logger.log(lvlWarn, args)

proc logError*(args: varargs[string, `$`]) {.inline.} =
  logger.log(lvlError, args)
