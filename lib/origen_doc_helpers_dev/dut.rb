module OrigenDocHelpersDev
  class DUT
    include Origen::TopLevel

    # Example to test a real life use case with backslashes in the descriptions which
    # led to rendering issues
    class SubModule
      include Origen::Model

      def initialize
        reg :debug_18, 0xf44, 32, bit_order: 'lsb0', ip_base_address: 0x1080000, description: '' do
          bit 31..0, :placeholder, reset: 0b0, access: :rw
        end
        reg :debug_19, 0xF48, size: 32, bit_order: :lsb0 do |reg|
          # When this bit is set, the controller\'s state machines and queues will be reset. Software then needs to clear this bit to allow the controller to function. This bit can only be set when DDR\_SDRAM\_CFG\[MEM\_EN\] is cleared.
          #
          # 0 | Memory controller is not reset.
          # 1 | Memory controller is reset.
          reg.bit 31, :mcsr, reset: 0b0, access: :rw
          # These are spare configuration bits that can be written or read. However, they are not currently used by the controller.
          reg.bit 30, :spare_cnfg3, reset: 0b0, access: :rw
          # This bit can be set to force the controller to start write leveling. This bit will be cleared by hardware after write leveling is complete.
          reg.bit 29, :frc_wrlvl, reset: 0b0, access: :rw
          # If this bit is cleared and automatic CAS to Preamble is used, then the DDR controller will calculate the write leveling start values for DQS\[1:8\] based on the CAS to Preamble results and the start value for DQS\[0\]. If this bit is set, then the automatic calculation of the start value is disabled.
          reg.bit 28, :wrc_dis, reset: 0b0, access: :rw
          # These are spare configuration bits that can be written or read. However, they are not currently used by the controller.
          reg.bit 27, :spare_cnfg2, reset: 0b0, access: :rw
          # If this bit is set, then the chip select specified by CSWL will be used during write leveling.
          reg.bit 26, :cswlo, reset: 0b0, access: :rw
          # This field represents the chip select that will be used during write leveling if CSWLO is set.
          reg.bit 25..24, :cswl, reset: 0b0, access: :rw
          # This can be set to use an internally generated VRef.
          #
          # 0 | Default.
          # 1 | Use internal VRef.
          reg.bit 23, :int_ref_sel, reset: 0b0, access: :rw
          reg.bit 22, :ign_cas_full, reset: 0b0, access: :rw
          # This bit can be set to override the perfmon enable to the controller.
          #
          # 0 | Use ipm_plus_perfmon_en.
          # 1 | Ignore ipm_plus_perfmon_en and collect perfmon events.
          reg.bit 21, :perf_en_ovrd, reset: 0b0, access: :rw
          # If this bit is set, then the bit deskew results will not be averaged across the enabled ranks. Instead, the address determined by DDR\_INIT\_ADDR will be used for bit deskew.
          reg.bit 20, :bdad, reset: 0b0, access: :rw
          # This field specifies how many taps will be incremented for each sample during RX bit deskew training. Note that this can be used to improve simulation times when validating the DDR controller RX deskew training.
          #
          # 000 | Increment 1 tap at a time
          # 001 | Increment 2 taps at a time
          # 010 | Increment 4 taps at a time
          # 011 | Increment 6 taps at a time
          # 100 | Increment 8 taps at a time
          # 101 | Increment 10 taps at a time
          # 110 | Increment 12 taps at a time
          # 111 | Increment 14 taps at a time
          reg.bit 19..17, :rx_skip_tap, reset: 0b0, access: :rw
          # If this bit is set, then the MCK gating during self refresh will be disabled.
          reg.bit 16, :mck_dis, reset: 0b0, access: :rw
          # This is the value sent to the IOs for the p\_gnd\_curr\_adj\[0:1\] and n\_gnd\_curr\_adj\[0:1\]
          reg.bit 15..12, :curr_adj, reset: 0b0, access: :rw
          # This is the enable for the TPA pin.
          reg.bit 11, :en_tpa, reset: 0b0, access: :rw
          # This 4-bit value represents the 4-bit MUX select to the TPA pin for.
          reg.bit 10..6, :tpa_mux_sel, reset: 0b0, access: :rw
          # This bit can be set to override the counter free-list group. It can be used to force a certain group only to be enabled.
          reg.bit 5, :cntr_ovrd, reset: 0b0, access: :rw
          # This is the value that will be overridden to the counter logic if CNTR\_OVRD is set. Note that values of 3\'b110 and 3\'b111 are illegal, and the will prevent the controller from finding an available counter to use.
          reg.bit 4..2, :cntr_ovrd_val, reset: 0b0, access: :rw
          # This bit can be set to force the transmit bit deskew to be enabled, regardless of the value of SLOW\_EN.
          reg.bit 1, :tx_bd_en, reset: 0b0, access: :rw
          reg.bit 0, :spare_cnfg, reset: 0b1, access: :rw
        end
        reg :debug_20, 0xf4c, 32, bit_order: 'lsb0', ip_base_address: 0x1080000, description: '' do
          bit 31..0, :placeholder, reset: 0b0, access: :rw
        end
        reg :debug_21, 0xf50, 32, bit_order: 'lsb0', ip_base_address: 0x1080000, description: '' do
          bit 31..0, :placeholder, reset: 0b0, access: :rw
        end
        reg :debug_22, 0xf54, 32, bit_order: 'lsb0', ip_base_address: 0x1080000, description: '' do
          bit 31..0, :placeholder, reset: 0b0, access: :rw
        end
      end
    end

    def initialize(_options = {})
      sub_block :sub_module, class_name: 'SubModule'

      # **The Long Name of the Reg**
      #
      # The MCLKDIV register is used to divide down the frequency of the HBOSCCLK input. If the MCLKDIV
      # register is set to value "N", then the output (beat) frequency of the clock divider is OSCCLK / (N+1). The
      # resulting beats are, in turn, counted by the PTIMER module to control the duration of Flash high-voltage
      # operations.
      #
      # This is just a test that paragraphs work.
      add_reg :mclkdiv, 0x0003, size: 16 do
        # **Oscillator (Hi)** - Firmware FMU clock source selection. (Note that in addition to this firmware-controlled bit, the
        # FMU clock source is also dependent on test and power control discretes).
        #
        # 0 | FMU clock is the externally supplied bus clock ipg_clk
        # 1 | FMU clock is the internal oscillator from the TFS hardblock
        bit 15, :osch, reset: 1
        # **Mode Ready** - A Synchronized version of the *ftf_mode_ready[1:0]* output from the flash analog hard block.
        # See the TFL3 Hard Block Creation Guide for more details.
        #
        # 0 | Analog voltages have not reached target levels for the specified mode of operation
        # 1 | Analog voltages have reached target levels for the specified mode of operation
        bit 13..12, :mode_rdy, writable: false
        # **IFR and FW ECC Enable for LDM** - On / off control for UIFR, RIFR, and FW when reading with the MGATE's
        # Load Memory (LDM) instruction. The setting of this bit only makes a difference when reading with LDM, all other
        # MGATE reads from UIFR/RIFR will always have ECC disabled and reads from FW will have ECC enabled.
        #
        # 0 | ECC is disabled for UIFR, RIFR, and FW reads when using the LDM instruction
        # 1 | ECC is enabled for all UIFR, RIFR, and FW reads when using the LDM instruction
        bit 10, :eccen, reset: 1
        # **MGATE Command Location Code** - A 2-bit code that tells the MGATE where to go for its instruction fetches
        # (location of command definitions). These bits are used to form different MGATE command request IDs from a
        # falling CCIF, one request ID for each of the possible locations of the MGATE executable. If this field is changed,
        # all subsequent command launches (falling CCIF) will execute from the new area. Note that the MGATE also has
        # a reset request ID. The reset request ID always targets the Boot Code and is unaffected by the CMDLOC setting.
        #
        # 00 | Execute from the Beginning of the MGRAM + 256B (the normal location)
        # 01 | Execute from the Beginning of the MGRAM
        # 10 | Execute from the Stack start at the end of MGRAM
        # 11 | Reserved
        bit 9..7, :cmdloc, reset: :undefined
        # **Clock Divider Bits** - DIV[7:0] must be set to effectively divide HBOSCCLK down to a known beat frequency
        # having acceptable resolution and dynamic range for timing high-voltage operations on the Flash hardblocks
        # during algorithms with timed events. Table 1-50 shows the range of timed events (i.e. pulse widths) that can be
        # achieved with 8-bit and 16-bit PTIMER loads for various input clock frequencies and clock divider settings.
        bit 6..2, :div, reset: :memory
      end

      # **Protection High**
      #
      # A simple register definition to test that reset values assigned to bytes
      # of a 32-bit register work
      reg :proth, 0x0024 do
        bits 31..24,   :fprot7,  reset: 0xFF
        bits 23..16,   :fprot6,  reset: 0xEE
        bits 15..8,    :fprot5,  reset: 0xDD
        bits 7..0,     :fprot4,  reset: 0x11
      end

      # **Protection Low**
      #
      # A simple register definition to test that memory dependent bits display
      # correctly
      reg :protl, 0x0028 do
        bits 31..24,   :fprot3,  nvm_dep: true
        bits 23..16,   :fprot2,  reset: :memory
        bits 15..8,    :fprot1,  nvm_dep: true
        bits 7..0,     :fprot0,  nvm_dep: true
      end

      add_mode :default
      add_mode :low_power
      add_mode :high_performance

      # SMcG, removing as does not work with latest Origen, can be reintroduced
      # when the Origen spec API is stable
      # modes.each do |mode|
      #  case mode
      #  when :default
      #    vdd_nom = 1.0.V
      #  when :low_power
      #    vdd_nom = 0.95.V
      #  when :high_performance
      #    vdd_nom = 1.05.V
      #  end
      #  spec :soc_vdd, mode do
      #    symbol 'Vdd'
      #    description 'Soc Core Power Supply'
      #    min "#{vdd_nom} - 50.mV"
      #    max "#{vdd_nom} + 50.mV"
      #    audience :external
      #  end
      # end
      # spec :soc_io_vdd do
      #  symbol 'GVdd'
      #  description 'Soc IO Power Supply'
      #  min 1.35.v
      #  max '1.50.v + 150.mv'
      #  audience :external
      # end
      # spec :soc_pll_vdd do
      #  symbol 'AVdd'
      #  description 'Soc PLL Power Supply'
      #  min :soc_vdd
      #  max :soc_vdd
      #  audience :external
      # end
    end
  end
end
