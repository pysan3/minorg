# Package

version = "2.0.1" # {x-release-please-version}
author = "pysan3"
description = "Norg Pandoc Bridge written in Nim"
license = "GPL-3.0-or-later"
srcDir = "."
skipDirs = @["tests", "tmp"]
bin = @["minorg"]

# Dependencies

requires "nim >= 2.0.0"
requires "nim_pandoc >= 3.0.0"
requires "cligen >= 1.6.15"
