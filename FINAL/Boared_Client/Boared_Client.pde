/**
 * CLIENT SIDE
 * Boared (Board for the Bored), is a social tool which allow you to spend 
 * some time together with others. 
 * The mission is to create together a draw based on random rectangles. 
 * Each user can drag elements on the screen and see feedback when other 
 * users make changes in real-time.
 * The type of communication is purely visual and playful. It express an idea 
 * of something you and other can create together, in your spare time or during 
 * any boring time.
 * Boared fits both children and adults, it is easy to use only by mouse gestures 
 * and you can drag and drop elements on the screen.
 * 
 * @title:  Boared
 * @author: Shiran Hirshberg & Caterine Apruzzese
 * @date:   5 October 2018
 */

import processing.net.*;
import processing.sound.*;

final int  PORT        = 19335;
final char TERMINATOR  = '\n';
final String SEPARATOR = " ";
final int NUM_BOXES    = 30;

Client c;
ArrayList <Box> objects;

String word = "";
int timer = 0;

Box selected;
// Two variables to "fix" the drag offest:
int dragOffsetX, dragOffsetY;

SoundFile[] files = new SoundFile[2];
boolean[] plays = new boolean[2];

PImage img;

PImage mouseCursor;


color currentColor;

void setup() {
  //fullScreen();
  size(900, 700);

  currentColor = color(255, 0, 0);

  img = loadImage("Logo_White.png");

  PFont f = loadFont ("Avenir-Medium-30.vlw");
  textFont(f);

  c = new Client(this, "10.14.90.228", PORT);
  objects = new ArrayList();
  for (int i=0; i<NUM_BOXES; i++) {
    objects.add(new Box(i));
  }

  files[0] = new SoundFile(this, "sound.wav");
  files[1] = new SoundFile(this, "alarm.wav");
  for (int i = 0; i<plays.length; i++) {
    plays[i] = true;
  }
}


void mousePressed() {
  for (Box d : objects) {
    if (d.isInside(mouseX, mouseY)) {
      selected = d;
      dragOffsetX = mouseX - d.x;
      dragOffsetY = mouseY - d.y;
      files[0].play();
      break;
    }
  }
}

void mouseDragged() {
  if (selected != null) {
    selected.x = mouseX - dragOffsetX;
    selected.y = mouseY - dragOffsetY;
    String message = "UPDATE " + selected.serialize() + TERMINATOR;
    c.write(message);
  }
}

void mouseMoved() {
  cursor(ARROW);
  for (Box d : objects) {
    if (d.isInside(mouseX, mouseY)) {
      cursor(HAND); 
      break;
    }
  }
}

void mouseReleased() {
  selected = null;
}

void draw() {

  for (int k=0; k<20; k++) {

    if (c.available() > 0) {
      String message = c.readStringUntil(TERMINATOR);
      try {               
        String[] chunks = split(trim(message), SEPARATOR);
        if (chunks!= null) {

          String label = chunks[0];
          // -----------------------------------------
          // An 'UPDATE' message: means we need to update a single square:
          if (label.equals("UPDATE")) {
            for (int i=1; i<chunks.length; i++) {
              int id = extractId(chunks[i]);
              if (id >= 0 && id < objects.size()) { // id is valid...
                Box b = objects.get(id);
                b.deserialize(chunks[i]);
              }
            }

            // -----------------------------------------
            // A 'WORD' message
          } else if (label.equals("COLOR")) {
            currentColor = parseInt(chunks[1]);
        } else if (label.equals("WORD")) {
            word = chunks[1];
            files[1].play();
          } else if (label.equals("TIMER")) {
            timer = parseInt(chunks[1]);
          }
        }
      } 
      catch (Exception e) {
        println(e);
        println("-- message --");
        println(message);
      }
    }
  }

  background(currentColor);
  img.resize (189, 65);
  image(img, width-200, height-70);


  noStroke();
  for (Box o : objects) {   
    o.paint();
  }

  fill(0);
  textAlign(CENTER, CENTER);
  text("Draw a " + word, width/2, 50);
  fill(255);
  textAlign(LEFT, LEFT);
  text("Next Challenge: " + timer/100, width/35, height-30);
}
