#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#define player_sizeX 106/2
#define player_sizeY 160/2
#define screenWidth 640
#define screenHeight 480

typedef struct Player_Software {
    Player_Software(int x) : player_x(x), player_y(400), health(100), movement_state(Standing), jump_timer(500), animation_cycle(0), action_state(None) {}
    unsigned int x;
    unsigned int y;
    unsigned int health;
    enum last_movement_state, movement_state {Standing, Move_Left, Move_Right, Jump_Up, Jump_Left, Jump_Right, Landing};
    int jump_timer; // will stay jumping for 1000 cycles 500->-500
    enum last_action_state, action_state {None, Punching, Blocking, Taking Damage};
    unsigned int animation_cycle;
} Player_Software;

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
    volatile unsigned int width = 106/2;
    volatile unsigned int height = 160/2;
    volatile unsigned int health = 100;
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

void updateMovement(Player_Software * player, Player_Hardware * hardware) {
    if (player->movement_state == Standing || player->movement_state == Move_Left || player->movement_state == Move_Right) { // only allow new movements when on the ground
        if(hardware->keycode == 8) { // only D being pressed
            player->movement_state = Move_Left;
        }
        else if(player->keycode == 2) { // only A being pressed
            player->movement_state = Move_Left;
        }
        else if(player->keycode == 1) { // only W being pressed
            player->movement_state = Jump_Up;
        }
        else if(player->keycode == 3) { // WA pressed
            player->movement_state = Jump_Left;
        }
        else if(player->keycode == 9) { // WD pressed
            player->movement_state = Jump_Right;
        }
    }
}
void performMovement(Player_Software * player, Player_Hardware * hardware) {
    if (player->movement_state == Move_Right || player->movement_state == Jump_Right && hardware->animation != 5) {
        if (player->x + 5 < screenWidth - player_sizeX) player->x += 5;
    }
    else if (player->movement_state == Move_Left || player->movement_state == Jump_Left && hardware->animation != 5) {
        if (player->x + 5 > player_sizeX) player->x -= 5;
    }
    else if (player->movement_state == Jump_Up || player->movement_state == Jump_Left || player->movement_state == Jump_Right && hardware->animation != 5) {
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


void main() {
    Player_Software p1s(100);
    Player_Hardware * p1h = (Player_Hardware *) 0x131231; // change
    while (1) {
        while (V_Sync == 0) {} // wait for a new frame from hardware
	V_Sync = 0; // set vsync flag back to 0
        updateMovement(&p1s, p1h);
        performMovement(&p1s, p1h);
        drawMovementAnimation(&p1s, p1h);
    }
}
