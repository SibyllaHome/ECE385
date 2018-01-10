// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng
volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block
volatile unsigned int *SLIDER = (unsigned int*)0x30; // pointer to slider
volatile unsigned int *PUSH_BUTTON = (unsigned int*)0x20; // pointer to push button
int keyPressed = 0;
void runFlashLED() {
	*LED_PIO = 0; //clear all LEDs
	int i = 0;
	for (i = 0; i < 10000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
	for (i = 0; i < 10000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB
}
void accumulate() {
	if (*PUSH_BUTTON == 0x01) { // pressed key 3
		if (keyPressed == 0) { // handle toggle, don't do anything when downpressed, just save state
			keyPressed = 3;
		}
	}
	else if (*PUSH_BUTTON == 0x02) { // pressed key 2
		if (keyPressed == 0) { // handle toggle, don't do anything when downpressed, just save
			keyPressed = 2;
		}
	}
	else {
		if (keyPressed == 3) { // on release of button 3
			*LED_PIO = (*LED_PIO + *SLIDER) % 256; // set to overflow at 256
			keyPressed = 0;
		}
		else if (keyPressed == 2) { // on release of button 2
			*LED_PIO = 0x0; // clear to 0
			keyPressed = 0;
		}
	}
}
int main()
{
	while (1) //infinite loop
	{
		accumulate();
	}
	return 1; //never gets here
}
