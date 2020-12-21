::Modelsim command
vsim -c -do modelsim.do

::Delete Modelsim generated files, except the work library folder
DEL transcript vsim.wlf modelsim.ini /q

::Debussy command
debussy -2001 ./../tb/diff_freq_serial_out_tb.v ^
              ./../rtl/diff_freq_serial_out.v   ^
              -ssf diff_freq_serial_out.fsdb    ^
              -sswr waveform.rc

::Delete waveform file
DEL *.fsdb /q

::Delete Debussy generated files
RD Debussy.exeLog /s /q
