//import libraries
import netP5.*;
import oscP5.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

Robot robot;

//Initialize OscP5
OscP5 oscP5;

//the prediction variable, initialized with a high value 
float prediction = 9;
int m = 0;

int delay = 100;

void setup() {
  size(512, 512);
  //inizialize with Wekinator port
  oscP5 = new OscP5(this, 12000);  
  background(0);

  //Let's get a Robot...
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }
}

void draw() {        

  if (millis() - m >delay) {
    //manage wekinator output predictions
    if (prediction == 1.0) {  
      //red background
      background(255, 0, 0);
      //neutral
      m = millis();
    } 

    if (prediction == 2.0) {
      //green background
      background(0, 255, 0);
      robot.keyPress(KeyEvent.VK_UP);
      //delay?
      robot.keyRelease(KeyEvent.VK_UP);
      m = millis();
    }

    if (prediction == 3.0) {
      //blue background
      background(0, 0, 255);  
      robot.keyPress(KeyEvent.VK_DOWN);
      //delay?
      robot.keyRelease(KeyEvent.VK_DOWN);
      m = millis();
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
