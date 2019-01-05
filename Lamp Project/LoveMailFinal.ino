
//**********LED RINK*******************

//#define MASTER
#ifdef MASTER
#define MY_ADDRESS 0x01
#define YOUR_ADDRESS 0x02
#else
#define MY_ADDRESS 0x02
#define YOUR_ADDRESS 0x01
#endif
#include <Wire.h>
#include <Adafruit_NeoPixel.h>


#define PIN            6
#define NUMPIXELS      16

Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
//*********************************************
#define PIN2            3
#define NUMPIXELS2      16

Adafruit_NeoPixel pixels2 = Adafruit_NeoPixel(NUMPIXELS2, PIN2, NEO_GRB + NEO_KHZ800);
//*********************************************

#define SENSOR_PIN A2
#define SENSOR_PIN2 A3
#define PRESSURE_IDLE 0
#define PRESSURE_MIN 100
#define PRESSURE_MID 600
#define PRESSURE_MAX 800

bool messageReceived = false;
bool messageType;
int messageValue;
int lightReceived = 0;
int lightSent = 0;
int brightnessValue, lastBrightnessValue;
enum STATES {
  ST_OFF = 0,
  ST_IDLE,
  ST_AWAKE,
  ST_SLEEP,
  ST_LIGHT_INPUT,
  ST_LIGHT_OUTPUT,
  ST_HEARTBEAT_INPUT,
  ST_HEARTBEAT_OUTPUT,
  ST_SENDING,
  ST_PLAYBACK
};

enum MESSAGE_TYPE {
  MSG_LIGHT,
  MSG_HEARTBEAT
};
int currentState = ST_OFF;
// time tracking
unsigned long lastTimeCheck;
unsigned int timeout;
unsigned long timeAwake;
int sensorValue;

void setup() {
  // put your setup code here, to run once:
  Wire.begin(MY_ADDRESS);
  Wire.onReceive(receiveMessage);
  pixels.begin();
  Serial.begin(9600);
  changeState(ST_IDLE);
}

void loop() {
  
  sensorValue = analogRead(SENSOR_PIN);
  // Serial.println(sensorValue);
  // Serial.println(currentState);
  if (currentState == ST_IDLE) {
    loopIdle();
  }

  if (currentState == ST_AWAKE) {
    loopAwake();
  }

  if (currentState == ST_SLEEP) {
    loopSleep();
  }

  if (currentState == ST_HEARTBEAT_INPUT) {
    loopHeartbeatInput();
  }
  if (currentState == ST_HEARTBEAT_OUTPUT) {
    loopHeartbeatOutput();
  }

  if (currentState == ST_LIGHT_INPUT) {
    loopLightInput();
  }

  if (currentState == ST_LIGHT_OUTPUT) {
    loopLightOutput();
  }
  if (currentState == ST_SENDING) {
    loopSending();
  }
}

void loopIdle() {
  Serial.println("ST_IDLE");
 
  if (sensorValue > PRESSURE_MIN) {
    if(messageReceived){
      playbackMessage();
      }
     else{
      changeState(ST_AWAKE);
    }
  }
}

void loopSleep() {
  Serial.println("loopSleep");
  unsigned long now = millis();
  if (now - lastTimeCheck > timeout) {
    changeState(ST_IDLE);
    lastTimeCheck = now;

    if (sensorValue > 50) {
      changeState(ST_AWAKE);
    }
  }
}

void loopAwake() {
  Serial.println("ST_AWAKE");
  unsigned long now = millis();
  if (messageReceived) {
    changeState(ST_PLAYBACK);
  }
  if (now - lastTimeCheck > timeout) {
    changeState(ST_IDLE);
    lastTimeCheck = now;
  }
  if (now - timeAwake > 2000) {
    changeState(ST_LIGHT_INPUT);
  }
  if (sensorValue > 50) {
    lastTimeCheck = now;
  }
  if(sensorValue > PRESSURE_MAX ){
    changeState(ST_HEARTBEAT_INPUT);
  }
  //analogWrite(10, 255);
}


void loopLightInput() {
  unsigned long now = millis();
  //Serial.println("ST_LIGHT_INPUT");
  brightnessValue = map(analogRead(SENSOR_PIN), 0, PRESSURE_MAX + 100, 0, 255 );
  if (brightnessValue < 16) brightnessValue = 16;
  if (brightnessValue > 255) brightnessValue = 255;
  //Serial.println(brightnessValue);

  if (abs(brightnessValue - lastBrightnessValue) > 15) {
    
    setAllLEDs(255, 255, 255, brightnessValue);
    /*for (int i = 0; i < NUMPIXELS; i++) {
      pixels.setPixelColor(i, pixels.Color(255, 255, 255));
      pixels.setBrightness(brightnessValue);
      pixels.show();

    }*/
    
    lastTimeCheck = now;
    lastBrightnessValue = brightnessValue;
  } else {

  }
  if (now - lastTimeCheck > 2000) {
    changeState(ST_SENDING);
  }
}

void loopLightOutput() {

  //    changeState(ST_LIGHT_OUTPUT);
  
  setAllLEDs(255, 255, 255, messageValue);
  delay(3000);
  changeState(ST_IDLE);
}

void loopSending() {
  Serial.println("ST_SENDING");
  unsigned long now = millis();

  
  //haptic();
  if (now - lastTimeCheck > timeout) {
    changeState(ST_IDLE);
  }

}
void loopHeartbeatInput() {
  Serial.println("ST_HEARTBEAT_INPUT");
  for (int i = 0; i < 3 ; i++) {
    setAllLEDs(190, 0, 0, 200);
    analogWrite(10, 180);
    delay(200);
    setAllLEDs(0, 0, 0, 0);
    analogWrite(10, 0);
    delay(100);
    setAllLEDs(190, 0, 0, 140);
    analogWrite(10, 120);
    delay(200);
    setAllLEDs(0, 0, 0, 0);
    analogWrite(10, 0);
    delay(400);
  }
  changeState(ST_SENDING);
}
void loopHeartbeatOutput() {
  Serial.println("ST_HEARTBEAT_INPUT");
  for (int i = 0; i < 3 ; i++) {
    setAllLEDs(190, 0, 0, 200);
    analogWrite(10, 180);
    delay(200);
    setAllLEDs(0, 0, 0, 0);
    analogWrite(10, 0);
    delay(100);
    setAllLEDs(190, 0, 0, 140);
    analogWrite(10, 120);
    delay(200);
    setAllLEDs(0, 0, 0, 0);
    analogWrite(10, 0);
    delay(400);
  }
  changeState(ST_IDLE);
}

void changeState(int newState) {
  //Serial.println(currentState);
  //Serial.println(newState);
  if(currentState == newState){
    return;
  }
  if (newState == ST_IDLE) {
    if(messageReceived) messageReceived = false;
    setAllLEDs(0, 0, 0, 0);
    //Serial.println("NEW STATE IS ST_IDLE");
    //return;
  }
  if (newState == ST_AWAKE) {
    //Serial.print("new state: ");
    // Serial.println(newState);
    // Serial.println(currentState);
    timeout = 1000;
    lastTimeCheck = millis();
    timeAwake = lastTimeCheck;
  }
  
  if (newState == ST_SENDING) {
    if(currentState == ST_HEARTBEAT_INPUT){
      sendMessage(MSG_HEARTBEAT, 0);
    }else{
      sendMessage(MSG_LIGHT, brightnessValue);
      haptic();
    }
    timeout = 3000;
    lastTimeCheck = millis();

  }
  currentState = newState;
  
}
void sendMessage(int _msgType, int _value){
  Wire.beginTransmission(YOUR_ADDRESS); // transmit to device #8
  Wire.write(_msgType);      // sends five bytes
  Wire.write(_value);        // sends one byte
  Wire.endTransmission();    // stop transmitting
}
void receiveMessage(int bytes){
  Serial.println("NEW MESSAGE");
  //delay(5000);
  while (Wire.available() > 1) { // loop through all but the last
    char msgType = Wire.read(); // receive byte as a character
    char msgValue = Wire.read();
    messageType = msgType;
    if(msgType == MSG_HEARTBEAT){
      //changeState(ST_HEARTBEAT_OUTPUT);
      
    }else{
      messageValue = msgValue;
      //changeState(ST_LIGHT_OUTPUT);
      
    }
    messageReceived = true;
    changeState(ST_IDLE);
  }
}
void playbackMessage(){
  if(messageType == MSG_HEARTBEAT){
      changeState(ST_HEARTBEAT_OUTPUT);
    }else{
      changeState(ST_LIGHT_OUTPUT);
    }
}
void setAllLEDs(int r, int g, int b, int br) {
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setPixelColor(i, pixels.Color(r, g, b));
    pixels.setBrightness(br);
    pixels.show();
  }
}
void setAllLEDsBrightness(int br) {
  for (int i = 0; i < NUMPIXELS; i++) {
    pixels.setBrightness(br);
    pixels.show();
  }
}

void haptic() {
  analogWrite(10, 180);
  delay(200);
  analogWrite(10, 0);
  delay(100);
}
