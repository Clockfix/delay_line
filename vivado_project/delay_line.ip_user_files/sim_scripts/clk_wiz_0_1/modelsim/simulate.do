onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -L xpm -L work -L unisims_ver -L unimacro_ver -L secureip -lib work work.clk_wiz_0 work.glbl

do {wave.do}

view wave
view structure
view signals

do {clk_wiz_0.udo}

run -all

quit -force
