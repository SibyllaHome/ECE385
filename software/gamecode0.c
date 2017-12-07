#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#define player_sizeX 106/2
#define player_sizeY 160/2
#define screenWidth 640
#define screenHeight 480

volatile unsigned int * VGA_VS = (volatile unsigned int *) 0x00000040;
volatile unsigned int * PIO = (volatile unsigned int *) 0x00000080;

enum mvt_state {Standing, Move_Left, Move_Right, Jump_Up, Jump_Left, Jump_Right, Landing};
enum act_state {None, Punching, Blocking, Taking_Damage};

typedef struct Player_Software {
    unsigned int x;
    unsigned int y;
    unsigned int health;
    enum mvt_state last_movement_state, movement_state;
    enum act_state last_action_state, action_state;
    unsigned int animation_cycle;
} Player_Software;

void setDefaultSW(int x, Player_Software * player) {
	player->x = x;
	player->y = 400;
	player->health = 100;
	player->last_movement_state = player->movement_state = Standing;
	player->last_action_state = player->action_state = None;
	player->animation_cycle = 0;
}

typedef struct Player_Hardware {
    volatile unsigned int keycode;
    /** Keycode Map:
    1) W
    2) A
    3) A+W
    4) S
    5) S+W
    6) S+A
    7) S+A+W
    8) D
    9) D+W
    **/
    volatile unsigned int x;
    volatile unsigned int y;
    volatile unsigned int width;
    volatile unsigned int height;
    volatile unsigned int health;
    volatile unsigned int animation;
    /** Animation Code:
    0) Standing 1
    1) Walking
    2) Standing 2
    3) Jump (up)
    4) Jump (down)
    5) Jump (landing)
    6) Punching
    7) Blocking
    **/
} Player_Hardware;

void setDefaultHW(unsigned width, unsigned height, Player_Hardware * hardware) {
	hardware->width = 106/2;
	hardware->height = 160/2;
	hardware->health = 100;
	hardware->animation = 0;
}

void updateMovement(Player_Software * player, Player_Hardware * hardware) {
    if (player->movement_state == Standing || player->movement_state == Move_Left || player->movement_state == Move_Right) { // only allow new movements when on the ground
        if(hardware->keycode == 8) { // only D being pressed
            player->movement_state = Move_Left;
        }
        else if(hardware->keycode == 2) { // only A being pressed
            player->movement_state = Move_Left;
        }
        else if(hardware->keycode == 1) { // only W being pressed
            player->movement_state = Jump_Up;
        }
        else if(hardware->keycode == 3) { // WA pressed
            player->movement_state = Jump_Left;
        }
        else if(hardware->keycode == 9) { // WD pressed
            player->movement_state = Jump_Right;
        }
    }
}
void performMovement(Player_Software * player, Player_Hardware * hardware) {
    if ((player->movement_state == Move_Right) || (player->movement_state == Jump_Right) && (hardware->animation != 5)) {
        if (player->x + 5 < screenWidth - player_sizeX) player->x += 5;
    }
    else if ((player->movement_state == Move_Left) || (player->movement_state == Jump_Left) && (hardware->animation != 5)) {
        if (player->x + 5 > player_sizeX) player->x -= 5;
    }
    else if ((player->movement_state == Jump_Up) || (player->movement_state == Jump_Left) || (player->movement_state == Jump_Right) && (hardware->animation != 5)) {
        player->y -= player->animation_cycle - 15;
    }
}
void drawMovementAnimation(Player_Software * player, Player_Hardware * hardware) {
    // set x and y
    hardware->x = player->x;
    hardware->y = player->y;

    // set different animations if movement didnt change
    if (player->last_movement_state == player->movement_state) {
        if (player->animation_cycle == 30) { // set a new animation every .5 seconds
            if (player->movement_state == Standing) {
                if (hardware->animation == 0) hardware->animation = 2;
                else hardware->animation = 0;
            }
            if (player->movement_state == Move_Left || player->movement_state == Move_Right) {
                if (hardware->animation == 1) hardware->animation = 0; // swap between standing and moving when moving
                else hardware->animation = 1;
            }
            if (player->movement_state == Jump_Up || player->movement_state == Jump_Right || player->movement_state == Jump_Left) {
                if (hardware->animation == 3) hardware->animation = 4; // change from going up to going down
                if (hardware->animation == 4) hardware->animation = 5; // perform landing
            }
            player->animation_cycle = 0; // reset animation counter at end of .5 seconds
        }
        else if (player->animation_cycle == 10 && hardware->animation == 5) { // reset from landing to standing after .2 seconds
            player->movement_state = Standing;
            hardware->animation = 0;
            player->animation_cycle = 0; // reset animation counter at end of .5 seconds
        }
        else player->animation_cycle++;
    }
    else { // a new movement this cycle
        if (player->movement_state == Standing) hardware->animation = 0;
        if (player->movement_state == Move_Right || player->movement_state == Move_Left) hardware->animation = 1;
        if (player->movement_state == Jump_Up || player->movement_state == Jump_Left || player->movement_state == Jump_Right) hardware->animation = 3;
        player->last_movement_state = player->movement_state;
    }
}


int main() {
//    Player_Software p1s(100);
//    Player_Hardware * p1h = (Player_Hardware *) 0x131231; // change
    while (1) {
    	int v_counter = 0;
    	int test = 5;
    	*PIO = test;
    	printf("%d\n", *VGA_VS);
        while (*VGA_VS == 0) {
        	v_counter++;
        	usleep(5);
        } // wait for a new frame from hardware
		printf("%d+\n", v_counter);
//			updateMovement(&p1s, p1h);
//			performMovement(&p1s, p1h);
//			drawMovementAnimation(&p1s, p1h);
    }
}
