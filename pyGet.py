import subprocess
import time
import pypruss
import sys

interval = 20

while 1:
	cmdstr = 'wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip 2>&1 | grep -o \'\([0-9.]\+ [KM]B/s\)\' | grep -o \'\([0-9.]\+\)\''
	#print cmdstr
	cmd = subprocess.Popen(cmdstr, shell=True, stdout=subprocess.PIPE)
	lines = [line.strip() for line in open('speed.txt')]
	#print lines
	#f = open('out.txt'), 'w')
	speed = [line.strip() for line in cmd.stdout]
	print lines[0] #need a file with a number in it for this to work
	print speed[0]
	percentChange = ( ( float(speed[0]) - float(lines[0])) / float(lines[0])) * 100 ##Calculate the new percent changed

	print percentChange
	#Now we've compared. Let's write the most recent speed to our file.
	f = open('speed.txt', 'w')
	f.write (speed[0])
	f.close()


	pypruss.modprobe() 			  				       	# This only has to be called once pr boot
	pypruss.init()										# Init the PRU
	pypruss.open(0)										# Open PRU event 0 which is PRU0_ARM_INTERRUPT
	pypruss.pruintc_init()								# Init the interrupt controller

	if percentChange < -5:
	  pypruss.exec_program(0,"./red.bin")
	else: 
          if percentChange < 0:
	    pypruss.exec_program(0,"./orange.bin")
	  else:
             if percentChange > 0:
	       pypruss.exec_program(0,"./green.bin")
	     else:
	       pypruss.exec_program(0,"./other.bin")   #should never hit this
		
	pypruss.wait_for_event(0)							# Wait for event 0 which is connected to PRU0_ARM_INTERRUPT
	pypruss.clear_event(0)								# Clear the event
	pypruss.pru_disable(0)								# Disable PRU 0, this is already done by the firmware
	pypruss.exit()									# Exits pypruss 
	time.sleep(interval)                        						# restarts speed evaluation after 'interval' seconds
