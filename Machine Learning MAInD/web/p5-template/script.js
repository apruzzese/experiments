function setup() {
  createCanvas(windowWidth, windowHeight)
  background(255,0,0)
}

function draw() {
  // background(255,0,0)
  line(mouseX, mouseY, pmouseX, pmouseY)
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
}
