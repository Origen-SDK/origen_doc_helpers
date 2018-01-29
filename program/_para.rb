# Parametric flow
#
# Blah blah, this is marked down:
#
# * blah
# * blah
Flow.create do
  # Measure the output of the vreg under no load, this is a simple
  # test to catch any gross defects that prevent the vreg from working
  #
  # Blah blah, this is marked down:
  #
  # * blah
  # * blah
  pp "No load tests" do
    para :vreg_meas, bin: 105, lo: 1.12, hi: 1.34

    para :vreg_meas, bin: 105, cz: true, if_enable: "vreg_cz"
  end

  # Measure the output of the vreg under the given load, this is approximately
  # equivalent to 1.5x the maximum load anticipated in a customer application.
  para :vreg_meas_loaded, vdd: :min, bin: 105, force: 5.mA, lo: 1.10, hi: 1.34, pattern: "vreg_meas"

  para :vreg_meas_loaded, vdd: :max, bin: 105, force: 5.mA, lo: 1.12, hi: 1.34, pattern: "vreg_meas"
end
