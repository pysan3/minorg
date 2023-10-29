import std/macros
import std/sequtils
import std/options
import std/strutils
import std/sugar
import std/sets
import std/enumerate

macro mainExamples*(body: untyped): untyped =
  when defined(docgen):
    newCall("runnableExamples", newStrLitNode(""), body)
  else:
    quote do:
      when isMainModule:
        `body`

template todo*(): untyped =
  assert(false, "Not implemented")

template isAbstract*(): untyped =
  assert(false, "Abstract method called")

template unreachable*(s: string): untyped =
  assert(false, "Unreachable code: " & s)

func addUniq*[T](a: var seq[T], b: T) =
  if b notin a: a.add(b)

func addUniq*[T](a: var seq[T], b: seq[T]) = a.add(b.filterIt(it notin a))

func deleteIf*[T](a: var seq[T], i: int) =
  if a.low <= i and i <= a.high:
    a.delete(i)

func argsWithDefault*[T](args: seq[T], index: int, default: T): T =
  if index >= 0 and index < args.len:
    return args[index]
  return default

func findIf*[T](s: seq[T], pred: (T {.noSideEffect.} -> bool)): Option[T] =
  for x in s:
    if pred(x):
      return some(x)
  return none(T)

func findSubstr*(s: string, t: string, strFroms: seq[int]): bool =
  strFroms.anyIt((it == 0 and s == t) or s.substr(it) == t)

func toSeq*[T](s: Slice[T]): seq[T] =
  result = newSeq[T](ord(s.b) - ord(s.a) + 1)
  for (i, x) in enumerate(s.a .. s.b):
    result[i] = x
