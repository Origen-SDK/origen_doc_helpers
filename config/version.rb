module OrigenDocHelpers
  MAJOR = 0
  MINOR = 4
  BUGFIX = 4
  DEV = nil

  VERSION = [MAJOR, MINOR, BUGFIX].join(".") + (DEV ? ".pre#{DEV}" : '')
end
