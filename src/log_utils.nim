import std/logging
import std/syncio

var logger: FileLogger

proc setLogger*(lvl: Level, file: File = stderr) =
  logger = newFileLogger(file, lvl)

template logDebug*(args: varargs[string, `$`]) =
  logger.log(lvlDebug, args)

template logInfo*(args: varargs[string, `$`]) =
  logger.log(lvlInfo, args)

template logWarn*(args: varargs[string, `$`]) =
  logger.log(lvlWarn, args)

template logError*(args: varargs[string, `$`]) =
  logger.log(lvlError, args)
