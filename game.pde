// ------------------------------------------
// Global Variables
// ------------------------------------------

// Level Stories
String intro_story = "In this game, your goal is to avoid the falling blocks by moving your mouse. There are ten levels, and you advance to the next level by surviving for fifteen seconds. Just fifteen seconds, that's easy right? Well.. maybe not, and to help you out, we've given you some power-ups, which move horizontally across the screen. Move into a power-up, and you'll get a special ability: either you'll become smaller, the blocks will become smaller, or the blocks will fall more slowly.. all of which help you dodge them! If the power-up is glowing in random colors as it moves, you really want that one: that will make you invincible for a short period of time! And if the power-up is flickering black and white, you really really want it: it will give you an extra life! A few more things: if you get hit, you'll have to start that level over again, and if you  lose all your lives, you'll have to start ALL the way back from Level 1. Bummer! To help you some more though, once you finish a level, we'll give you an additional life! That's all the rules, let's play!";
String level1_story = "Level 1";
String level2_story = "Level 2";
String level3_story = "Level 3";
String level4_story = "Level 4";
String level5_story = "Level 5";
String level6_story = "Level 6";
String level7_story = "Level 7";
String level8_story = "Level 8";
String level9_story = "Level 9";
String level10_story = "Level 10: FINAL";
String game_end_story = "Congratulations, you've completed the game! Play again!";
String lost_all_lives_story = "Looks like you're out of lives! Play again!";

// Canvas Parameters
int canv_w = 700;
int canv_h = 640;

// Background Color
int bg_color = 0;

// Text Box
float text_r = 255;
float text_g = 20;
float text_b = 20;

// Initial Conditions
int default_lives = 5;
int lives_left = default_lives; 
float default_r = 20;
float game_speed = 15; 
float obstacle_height = 20;
float obstacle_max_speed = 1;

// Game States
boolean collision_state = false; 
boolean power_state = false; 
int current_level = 1;
boolean lost_all_lives = false;

// Level Timers
boolean level_timer_is_on = false; 
var level_start_stamp = 0; 
int level_start_time = 1.5;
var level_timeout = 0; 
var level_complete_timeout = 0; 
int level_complete_time = 15; 
int level_time_remaining = level_complete_time; 
boolean level_ready = false; 

// Powered-Up Variables
var power_start = 0;
var power_timer = 0;
boolean power_applied = false; 
boolean invincibility = false; 

// Set Up Game
Player p1 = new Player(canv_w/2,canv_h-default_r,default_r);
Obstacle[] obstacles = new Obstacle[22];
PowerUp pu1 = new PowerUp(canv_w, canv_h); 

// ------------------------------------------
// Main Game Loop
// ------------------------------------------
void setup() {
	// Establish Canvas
	size(canv_w,canv_h);
	
	bootbox.alert(intro_story,function() {
		finishSetup();
	});
}

void finishSetup() {
	// Start at Level 1
	startLevel(1);	
	
	// Set Frame Rate
	frameRate(60);
}

void draw() {
	if (!level_ready) {return;}

	// Make background
	background(bg_color);
	
	// Show Text
	fill(text_r,text_g,text_b);
	textSize(20);
	text("Level: "+current_level,10,60)
	text("Lives Left: "+lives_left,10,30);
	level_time_remaining = level_complete_time - floor(((new Date()).getTime() - level_start_stamp)/1000);
	text("Time Left: "+level_time_remaining,canv_w-150,30);
	
	// Update All
	for (int i = 0; i<game_speed; i++) {	
		if (!collision_state) {		
			// Update Player
			p1.update();						
			
			// Update All Obstacles and Check Collisions
			collision_state = false; 
			for (int o = 0; o<obstacles.length; o++) {
				obstacles[o].update();
				collision_state = collision_state || checkCollision(p1,obstacles[o]);
			}
			
			// Update Power-Up and Check Collisions
			pu1.update();
			if (checkPowerUp(p1,pu1)) {
				power_state = true; 
				power_start = new Date();
				pu1.exists = false; 
				power_applied = false; 
			}			
		}		
		
		if (collision_state) {
			playerDied();
			return;
		}
	}
	
	// Check if Powered-Up
	if (power_state) {		
		if (invincibility) {
			p1.r = random(255);
			p1.g = random(255);
			p1.b = random(255);
		}
		power_timer = new Date();	
		if (power_timer-power_start <= pu1.effect_length*1000) {
			applyPower();			
		}
		else {
			resetPower();
			power_state = false; 
			pu1 = new PowerUp(canv_w,canv_h);
		}
	}
	
	// Draw Player, Power-Up, and All Obstacles
	p1.draw();
	pu1.draw();
	for (int o = 0; o<obstacles.length; o++) {
		obstacles[o].draw();
	}
}

void levelMessage() {
	if (level_timer_is_on) {
		clearTimeout(level_complete_timer);
	}
	
	String alert_msg;
	
	switch(current_level) {
		case 1: alert_msg = level1_story; break;
		case 2: alert_msg = level2_story; break;
		case 3: alert_msg = level3_story; break;
		case 4: alert_msg = level4_story; break;
		case 5: alert_msg = level5_story; break;
		case 6: alert_msg = level6_story; break;
		case 7: alert_msg = level7_story; break;
		case 8: alert_msg = level8_story; break;
		case 9: alert_msg = level9_story; break;
		case 10: alert_msg = level10_story; break;		
		case 11: alert_msg = game_end_story; current_level = 1; break;
	}		
	
	if (lost_all_lives) {		
		alert_msg = lost_all_lives_story; 
	}	
	lost_all_lives = false; 
	
	bootbox.alert(alert_msg,function() {
		startLevelTimer();
	});
}

void playerDied() {
	lives_left--;
	
	if (lives_left < 0) {
		lost_all_lives = true; 
		restartGame();		
	}
	else {
		restartLevel();
	}
}

void restartLevel() {
	collision_state = false; 
	startLevel(current_level);
}

void restartGame() {
	collision_state = false; 
	lives_left = default_lives; 	
	startLevel(1);
}


void applyPower() {
	if (power_applied) {return;}
	
	switch (pu1.effect) {
		case 1: // Smaller Player
			p1.radius = default_r-10;
			break;
		case 2: // Reduced Speed
			for (int i = 0; i<obstacles.length; i++) {
				obstacles[i].max_speed = 0.6*obstacle_max_speed;
			}
			break;
		case 3: // Smaller Obstacles
			for (int i = 0; i<obstacles.length; i++) {
				obstacles[i].h = 0.4*obstacle_height;				
			}
			break;
		case 4: // Invincibility
			invincibility = true; 			
			break;
		case 5: // Extra Life
			lives_left++;
			break;
	}
	
	power_applied = true; 
}

void resetPower() {
	switch (pu1.effect) {
		case 1: // Smaller Player
			p1.radius = default_r;
			break;
		case 2: // Reduced Speed
			for (int i = 0; i<obstacles.length; i++) {
				obstacles[i].max_speed = obstacle_max_speed;			
			}
			break;	
		case 3: // Smaller Obstacles
			for (int i = 0; i<obstacles.length; i++) {
				obstacles[i].h = obstacle_height;				
			}
			break;
		case 4: // Invincibility
			invincibility = false;
			p1.r = 255;
			p1.g = 0;
			p1.b = 0;
			break;		
		case 5: // Extra Life
			break; 
	}	
}

void startLevel(int new_level) {
	// Reset Obstacles
	if (power_state) {resetPower();}

	current_level = new_level; 	
	if (current_level == 11) {
		setupObstacles(2);
	}
	else {
		setupObstacles(current_level+1);
	}

	levelMessage();
	level_ready = false;
}

void startLevelTimer() {	
	level_timeout = setTimeout(afterLevelStartTimer,level_start_time*1000);
}
	
void afterLevelStartTimer() {		
	// Initialize Power-Up
	pu1 = new PowerUp(canv_w,canv_h);	
	
	// Level Fully Initialized
	level_ready = true; 
	
	// Start Level Complete Timer
	level_timer_is_on = true; 
	level_complete_timer = setTimeout(levelCompleted,level_complete_time*1000);	
	level_start_stamp =  (new Date()).getTime();
}

void levelCompleted() {
	if (current_level != 10) {lives_left++;}
	startLevel(current_level+1);	
}

void setupObstacles(num_obstacles) {	
	// Initialize All Obstacles
	for (int i = 0; i<obstacles.length; i++) {
		if (i <= num_obstacles-1) {
			obstacles[i] = new Obstacle(i*canv_w/num_obstacles,(i+1)*canv_w/num_obstacles,canv_h,1);
		}
		else {		
			obstacles[i] = new Obstacle();
		}	
	}
}

boolean checkCollision(Player p, Obstacle o) {
	// Check if Exists
	if (!o.exists) {return false;}
	
	// If Invincible, False
	if (invincibility) {return false;}
	
	// Check for Collision with Player
	if (p.x+p.radius/2 < o.x) {return false;}
	if (p.x-p.radius/2 > o.x+o.w) {return false;}
	if (p.y+p.radius/2 < o.y) {return false;}
	if (p.y-p.radius/2 > o.y+o.h) {return false;}
	return true;
}

boolean checkPowerUp(Player p, PowerUp pu) {
	// Check if Exists
	if (!pu.exists) {return false;}
	
	// Check for Collision with Player
	if (p.x+p.radius/2 < pu.x-pu.radius_x/2) {return false;}
	if (p.x-p.radius/2 > pu.x+pu.radius_x/2) {return false;}
	if (p.y+p.radius/2 < pu.y-pu.radius_y/2) {return false;}
	if (p.y-p.radius/2 > pu.y+pu.radius_y/2) {return false;}
	return true;	
}

void mouseMoved() {
	if (!collision_state) {
		p1.x = mouseX;
		p1.y = mouseY;
	}
}

void keyPressed() {
	// Cheat codes for debugging :p
	// Note that they do not stop the level timers
	// and weird things will happen... so don't cheat!
	switch (key) {
		case '1': startLevel(1); break;
		case '2': startLevel(2); break;
		case '3': startLevel(3); break;	
		case '4': startLevel(4); break;
		case '5': startLevel(5); break;
		case '6': startLevel(6); break;
		case '7': startLevel(7); break;
		case '8': startLevel(8); break;	
		case '9': startLevel(9); break;
		case '0': startLevel(10); break;
	}
	collision_state = false; 
}

// ------------------------------------------
// Player Class 
// ------------------------------------------
class Player {	 
	float r,g,b;
	float x,y,radius;
	
	Player(float x_pos, float y_pos, float rad) {
		// Initial Color
		r = 255;
		g = 0;
		b = 0;
		
		// Initial Position and Size
		x = x_pos;
		y = y_pos;
		radius = rad; 
	}
	
	void update() {
		
	}
	
	void draw() {		
		fill(r,g,b);
		ellipse(x,y,radius,radius);
	}
}

// ------------------------------------------
// Obstacle Class
// ------------------------------------------
class Obstacle {	
	float min_width = 50;	
	float max_speed = 1;
	float speed;
	float h = 20; 
	float r,g,b;
	float x, y, w;
	float left_x,right_x,canv_h;
	boolean exists = true; 
	
	Obstacle() {
		exists = false; 		
	}
	
	Obstacle(float l_x, float r_x, float c_h, float sp) {
		exists = true; 
	
		left_x = l_x;
		right_x = r_x;
		canv_h = c_h;
		
		max_speed = min(1,sp);
		max_speed = max(0,max_speed);
		
		reset();
	}
	
	void reset() {
		if (!exists) {return;}
	
		// Reset Color
		recolor();
		
		// Set Position
		w = random(min_width,(right_x-left_x)-min_width);				
		x = random(left_x,right_x-w);
		y = 0;
		
		// Set Speed
		speed = random(max_speed*0.75,max_speed);
	}
	
	void recolor() {
		r = random(10,255);
		g = random(10,255);
		b = random(10,255);	
	}
	
	void update() {
		if (!exists) {return;}
		
		y += speed;		
		if (y+h >= canv_h) {
			reset();
		}
	}

	void draw() {
		if (!exists) {return;}
	
		fill(r,g,b);
		rect(x,y,w,h);
	}
}

// ------------------------------------------
// PowerUp Class
// ------------------------------------------
class PowerUp {
	float canv_w,canv_h;
	float y_min,y_max;
	float r,g,b;
	float x,y;
	float radius_x = 32; 
	float radius_y = 14; 
	float speed = 0.25;
	int effect;
	float effect_length = 6;
	boolean exists = true; 
	
	PowerUp() {
		exists = false; 
	}
	
	PowerUp(float c_w, float c_h) {
		canv_w = c_w;
		canv_h = c_h;
		
		y_min = 0.25*c_h;
		y_max = 0.60*c_h;
		
		reset();
	}
	
	void determineEffect() {
		effect = floor(random(1,6));				
	}
	
	void reset() {
		// Effect of Power-Up
		determineEffect();
		
		// Set Color
		r = random(10,255);
		g = random(10,255);
		b = random(10,255);
		
		// Randomize Start
		if (random(0,1) <= 0.5) {
			x = 0;
			speed = abs(speed);
		}
		else {
			x = canv_w;
			speed = -abs(speed);
		}
		
		y = random(y_min,y_max);		
	}
	
	void update() {
		if (!exists) {return;}
	
		x += speed;
		
		if (x >= canv_w) {reset();}
		else if (x <= 0) {reset();}			
	}
	
	void draw() {
		if (!exists) {return;}		
		
		if (effect == 4) {
			// Invincibility
			r = random(255);
			g = random(255);
			b = random(255);
		}
		else if (effect == 5) {
			// Extra Life
			r = (millis()*5) % 255;
			g = r;
			b = r;
		}
		
		fill(r,g,b);
		ellipse(x-radius_x/2,y-radius_y/2,radius_x,radius_y);
	}
}
