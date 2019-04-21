//import libraries
import netP5.*;
import oscP5.*;

//Initialize OscP5
OscP5 oscP5;
int loopDelay = 2000;  
int screenDelay = 5000;
int m = 0;
int n = 0;

boolean handlePrediction = true;

float msgReceivedTimer = 0;
float startingTime =0;


//the prediction variable, initialized with a high value 
float prediction = 9;

void setup() {
  size(512, 512);
  //inizialize with Wekinator port
  oscP5 = new OscP5(this, 12000);
}



void draw() {        

  //background(0); 
  if (millis() - startingTime > loopDelay) {

    startingTime = millis();


    if (millis() - msgReceivedTimer > screenDelay) {

      //manage wekinator output predictions
      msgReceivedTimer = millis();

      if (prediction == 1.0) {  
        //red background
        background(255, 0, 0);
      } 

      if (prediction == 2.0) {
        //green background
        background(0, 255, 0);
      }

      if (prediction == 3.0) {
        //blue background
        background(0, 0, 255);
      }
    }
  }
  //...
}


//function that gets the prediction from OSC
void oscEvent(OscMessage theOscMessage) {
  if (millis() - n > screenDelay) {
    if (theOscMessage.addrPattern().equals("/wek/outputs")) {
      prediction = theOscMessage.get(0).floatValue();
    }
  }
}
