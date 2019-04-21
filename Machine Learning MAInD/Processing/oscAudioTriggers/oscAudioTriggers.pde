//import libraries
import netP5.*;
import oscP5.*;
import processing.sound.*;

//Initialize OscP5
OscP5 oscP5;

//the prediction variable, initialized with a high value 
float prediction = 9;

//create sound file
SoundFile drumloop;

void setup() {
  size(512, 512);
  //inizialize with Wekinator port
  oscP5 = new OscP5(this, 12000);  
  background(0);  

  //Load a soundfile
  drumloop = new SoundFile(this, "loop.mp3");
}

void draw() {        

  //manage wekinator output predictions
  if (prediction == 1.0) {  
    //red background
    background(255, 0, 0);
  } 

  if (prediction == 2.0) {
    //green background
    background(0, 255, 0);
    drumloop.stop();
  }

  if (prediction == 3.0) {
    //blue background
    background(0, 0, 255);
    if (drumloop.isPlaying() == 0) {
      drumloop.play();
    }
  }

  //...
}


//function that gets the prediction from OSC
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.addrPattern().equals("/wek/outputs")) {
    prediction = theOscMessage.get(0).floatValue();
  }
}
