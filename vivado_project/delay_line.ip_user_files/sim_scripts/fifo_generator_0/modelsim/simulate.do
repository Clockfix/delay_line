onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L xpm -L fifo_generator_v13_2_5 -L work -L unisims_ver -L unimacro_ver -L secureip -lib work work.fifo_generator_0 work.glbl

do {wave.do}

view wave
view structure
view signals

do {fifo_generator_0.udo}

run -all

quit -force
