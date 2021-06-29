module OrigenDocHelpers
  MAJOR = 0
  MINOR = 8
  BUGFIX = 6
  DEV = nil
  VERSION = [MAJOR, MINOR, BUGFIX].join(".") + (DEV ? ".pre#{DEV}" : '')
end
