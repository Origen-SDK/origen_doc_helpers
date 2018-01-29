# HVST
Flow.create do
  # Check if this device has already had the Vreg HVST
  func :rd_vreg_hvst_passcode, bin: 50, vdd: :nom, id: :vreg_hvst_done

  # Apply HVST to the vreg module
  func :vreg_hvst, bin: 101, hv: 10.V, vdd: :max, unless_passed: :vreg_hvst_done

  # Program a passcode to the device to record that the HVST
  # has been applied
  func :pgm_vreg_hvst_passcode, bin: 51, vdd: :nom, unless_passed: :vreg_hvst_done
end
