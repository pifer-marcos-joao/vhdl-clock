# vhdl-clock

This project was made in Digital Electronics subject in Escola d'Enginyeria de Barcelona Est. The purpose of this project is to create a basic configurable clock using VHDL in order to implement this system to a FPGA BASYS 3.

## Requirements

- The architecture must have 4 inputs in order to configure and set the time: SET,OK,UP,DOWN.
- The time must be shown in HH:MM format.
- The seconds representation must be shown in the dot between the 2nd and 3rd digits.
- The clock must work cyclically, going from 23:59 to 00:00
- The clock must work according to the following FSM.

CLOCK FINITE STATES MACHINE
![](images/clock-FSM.PNG

## Specifications

SET BUTTON
- Sets the system to configuration state, making the display blink at 1Hz.
- The system will change to configuration state after holding the button for 5 seconds.

UP BUTTON
- Increments the time by 1 minute while pressing it. Minutes must be incremented in a factor of 3Hz if the button is held during 5 seconds.

DOWN BUTTON
- Decrements the time by 1 minute while pressing it. Minutes must be decremented in a factor of 3Hz if the button is held during 5 seconds.

OK BUTTON
- Validates the new configuration set by UP/DOWN buttons. In order to make the configuration effective, the button must be held during 5 seconds.

INPUT CLK
 - 100 MHz input system clock.
 
 OUTPUT SD
 - 4 bits output which indicated the correpondent digit on the display.
 - Active low.
 
 OUTPUT SSEG
 - 8 bits output which indicates active segment on each display.


## Architecture

TECLAT (KEYBOARD) subsystem

This block is in charge of managing each button FSM and sends the preprocessed input signals from the system inputs to the internal subsystem DISPLAY.

DISPLAY

This block is in charge of managing the pseudo decoder in order to show the correspondent number to each digit on its correspondent display.

RELLOTGE (CLOCK) subsystem

Higher system which manages all the subsystems signals.



* Some simulations included in images folder.
