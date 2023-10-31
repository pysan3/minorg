type
  Config* = ref object of RootObj
    verbose*: bool = false
    isObsidian*: bool = false

var globalConfig = new Config

proc setConfig*(new: Config) =
  globalConfig = new

proc getConfig*(): auto =
  globalConfig
