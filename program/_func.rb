# Functional test of the Vreg
Flow.create do
  # This test verifies that the following things work:
  #
  # * The vreg can be disabled
  # * The trim register can be written to and read from
  func :vreg_functional, vdd: :min, bin: 101

  func :vreg_functional, vdd: :max, bin: 101, continue: true

  import "hvst"
end
