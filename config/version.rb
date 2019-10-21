module OrigenDocHelpers
  MAJOR = 0
  MINOR = 8
  BUGFIX = 2
  DEV = nil
  VERSION = [MAJOR, MINOR, BUGFIX].join(".") + (DEV ? ".pre#{DEV}" : '')
end
