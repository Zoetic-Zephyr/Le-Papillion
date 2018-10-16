var speed = 12.5
var spritesheet
var spritesheetWidth
var spritesheetHeight
var frameWidth
var frameHeight
var along = 0
var down = 0
var numberAcross = 9
var numberDown = 4
var XPos = 500
var YPos = 100
var IncrementMove = 10;
var SpriteSize = 200;

function preload() {
	spritesheet = loadImage("Man2.png")

}

function setup() {
	createCanvas(windowWidth, windowHeight);

	spritesheetWidth = spritesheet.width
	spritesheetHeight = spritesheet.height
	frameWidth = spritesheetWidth / numberAcross
	frameHeight = spritesheetHeight / numberDown
	frameRate(speed)

}

function draw() {
	background(255);
	
	stroke(0, 255, 0)
	strokeWeight(2)
	fill(0, 0)
	rect(along * (width / 2 / numberAcross), down * (height / 2 / numberDown), (width / 2 / numberAcross), (height / 2 / numberDown))
	image(spritesheet, 0, 0, width / 2, height / 2)
	fill(255);
	stroke(255);
	rect(0,0, 1000, 1000);
	image(spritesheet, XPos, YPos, SpriteSize,SpriteSize, frameWidth * along, frameHeight * down, frameWidth, frameHeight)
	
	if(keyIsPressed === true){ 
		along++
	}
	
	if (along == numberAcross) {
		along = 0
	}
	
	if (keyIsDown(LEFT_ARROW)) {
    down = 1;
		XPos-=IncrementMove;
  } else if (keyIsDown(DOWN_ARROW)) {
		YPos+=IncrementMove;
    down = 2;
  } else if (keyIsDown(UP_ARROW)) {
		YPos-=IncrementMove;
    down = 0;
  } else if (keyIsDown(RIGHT_ARROW)) {
		XPos+=IncrementMove;
    down = 3;
  }
}