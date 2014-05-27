// Radioshack RGB LED driver attempt
// Tyler Worman, tsworman at novaslp.net
// Jon Karve, jkarve at gmail.com
// May 9th 2014
// 

// Make sure this is run on each boot:
// export PINS=/sys/kernel/debug/pinctrl/44e10800.pinmux/pins
// export SLOTS=/sys/devices/bone_capemgr.9/slots
// echo BB-BONE-PRU > $SLOTS


.origin 0
.entrypoint START

#include "led.hp"

#define GPIO1 0x4804c000
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT 0x194

START:
    //clear that bit
    LBCO r0,C4,4,4
    LBCO r0, C4, 4, 4
    CLR r0, r0, 4
    SBCO r0, C4, 4, 4	
    
    MOV r1, 3 //number of light segments to illuminate
RESET:
    //Loop 2400 times which is 4800 instructions 1 inst per 5ns equals a 24us delay
    MOV r0, 2400
RESETLP:
    SUB r0, r0, 1
    QBNE RESETLP, r0,0 
SENDRED:
    //SEND 24 bits equalling 111111110000000000000000 to turn on a red LED
    //Loop this 10 times to turn on 10 of them.
    //Instructions are based on time between raise and fall.
    //0 is .7us high followed by 1.8us low.
    //1 is 1.8us high followed by .7us low. 
    //Translation to assembler instruction counts.
    //.7us = 700 ns = 140 instructions = 70 in subtract then jmp loop
    //1.8us = 1800 ns = 360 instruction = 180 in subtract then jmp loop    

    SUB r1, r1, 1
    //Red
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    //Blue
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    CALL SEND0
    //Green
    CALL SEND1
    CALL SEND1
    CALL SEND1
    CALL SEND1
    CALL SEND1
    CALL SEND1
    CALL SEND1
    CALL SEND1
    
    QBNE SENDRED, r1,0 

    //Could call reset here and we'd clear and retransmit first idea 
    //Or Leave it loop a fixed amount of times (r1) and keep turning on lights.

    MOV r31.b0, PRU0_ARM_INTERRUPT+16  //tell the c program we are done 
					//(just remove it if your c program does not handle the interrupt)

    // Halt the processor
    HALT

SEND1:
    //This uses a JUMP to return so timing is off but tolerance says +/- 200ms is okay.
    //We used a jump to get here so 10NS total was lost.
    SET r30.t14 //Turn pin on 
    MOV r0, 180 //Loop 180 times which is 2 instructions each so 360 instructions which is 1800ns or 1.8us
SEND1D:
    SUB r0,r0,1
    QBNE SEND1D, r0, 0 //When it's 0 then progress
    CLR r30.t14 //Turn pin off
    MOV r0, 70 //Loop 70 times which is 2 instructions each loop so 140 instructions is 700ns or .7us
SEND1D2:
    SUB r0,r0,1
    QBNE SEND1D2, r0,0
    RET //Jump back to the last issue of CALL which was done to SEND1

SEND0:
    //This uses a JUMP to return so timing is off but tolerance says +/- 200ms is okay.
    //We used a jump to get here so 10NS total was lost.
    SET r30.t14 //Turn pin on 
    MOV r0, 70 //Loop 70 times which is 2 instructions each loop so 140 instructions is 700ns or .7us
SEND0D:
    SUB r0,r0,1
    QBNE SEND0D, r0, 0 //When it's 0 then progress
    CLR r30.t14 //Turn pin off
    MOV r0, 180 //Loop 180 times which is 2 instructions each so 360 instructions which is 1800ns or 1.8us
SEND0D2:
    SUB r0,r0,1
    QBNE SEND0D2, r0,0
    RET //Jump back to the last issue of CALL which was done to SEND0





