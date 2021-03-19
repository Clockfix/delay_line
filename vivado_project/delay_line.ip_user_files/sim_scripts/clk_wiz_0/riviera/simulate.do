onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+clk_wiz_0 -L work -L unisims_ver -L unimacro_ver -L secureip -O5 work.clk_wiz_0 work.glbl

do {wave.do}

view wave
view structure

do {clk_wiz_0.udo}

run -all

endsim

quit -force
