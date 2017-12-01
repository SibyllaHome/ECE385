f = open('t.txt', 'w')

for i in xrange(0,20):
    f.write("set_output_delay -add_delay  -clock [get_clocks {main_clk_50}]  2.000 [get_ports {SRAM_ADDR["+str(i)+"]}]\n")
    
f.close()
