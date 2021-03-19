onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+fifo_generator_0 -L xpm -L fifo_generator_v13_2_5 -L work -L unisims_ver -L unimacro_ver -L secureip -O5 work.fifo_generator_0 work.glbl

do {wave.do}

view wave
view structure

do {fifo_generator_0.udo}

run -all

endsim

quit -force
