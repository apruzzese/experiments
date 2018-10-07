/**
* SERVER SIDE
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
import java.util.Map;

final int  PORT        = 19335;
final char TERMINATOR  = '\n';
final String SEPARATOR = " ";
final int  CANVAS_W    = 800;
final int  CANVAS_H    = 500;
final int NUM_BOXES    = 30;

Server s;
ArrayList <Box> objects;
HashMap <String, Client> clients;
color[] backcolors = {color(193, 170, 191), color(215, 170, 191), color(176, 149, 218), color(160, 199, 218), color(174, 227, 218)}; 
color backcolor;
String[] words = {"Dog", "Face", "Sky", "House", "T-Shirt", "Sky", "Bear", "Flower", "Heart", "Cat", "Butterfly", "Tree", "Fish"}; 
String word = "";  
int timer = 0;

void setup() {
  //fullScreen();
  size(500, 500);

  PFont f = loadFont ("Avenir-Medium-15.vlw");
  textFont(f);

  s = new Server(this, PORT);

  clients = new HashMap();
  objects = new ArrayList();
}

void draw() {

  // ---- TIMER ---------
  timer--;
  if (timer <= 0) {
    timer = 10000;
    word = words[int(random(words.length))];
    backcolor = backcolors[int(random(backcolors.length))];
    s.write("WORD" + SEPARATOR + word + TERMINATOR);
    objects.clear();
    for (int i=0; i<NUM_BOXES; i++) {
      int box_unique_id = i;
      int x = (int)random(100, CANVAS_W-100); 
      int y = (int)random(100, CANVAS_H-100); 
      int w = (int)random(50, 200);
      int h = (int)random(50, 200);
      // float r = random(TWO_PI);
      Box b = new Box(box_unique_id, x, y, w, h);  
      objects.add(b);
    }

    String message = "UPDATE" + SEPARATOR; // 
    for (Box b : objects) {
      message += b.serialize() + SEPARATOR;
    }
    message = trim(message) + TERMINATOR; // ...add a terminator!
    s.write(message);    
    s.write("COLOR" + SEPARATOR + backcolor + TERMINATOR);
  } 

  s.write("TIMER" + SEPARATOR + timer + TERMINATOR);

  // ---- SERVER DATA ---------
  for (int k=0; k<20; k++) {
    Client c = s.available();
    if (c != null) {
      if (c.available() > 0) {
        String message = c.readStringUntil(TERMINATOR);
        try {               
          String[] chunks = split(trim(message), SEPARATOR);
          if (chunks!= null) {
            String label = chunks[0];
            // An 'UPDATE' message: means we need to update a single square:
            if (label.equals("UPDATE")) {
              for (int i=1; i<chunks.length; i++) {
                int id = extractId(chunks[i]);
                if (id >= 0 && id < objects.size()) { // id is valid...
                  Box b = objects.get(id);
                  b.deserialize(chunks[i]);
                }
              }
              // ECHO to all the clients:
              echo(c, message);
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
  }


  background(200);

  // ------ INFO -------------
  String info = "";
  info += "Server IP: " + Server.ip() + "\n";
  info += "Timer: " + timer + "\n";
  info += "Challenge: " + word + "\n";
  info += "Clients:\n";
  int i = 0;
  for (Map.Entry<String, Client> entry : clients.entrySet()) {
    Client c = entry.getValue();                  
    info += "[" + i++ + "] " + c.ip() + "\n";
  }
  text(info, 30, 300);

  // ------ BOXES -------------
  scale(0.3);
  noFill();
  stroke(0);
  for (Box o : objects) {
    o.paint();
  }
}

void keyPressed(){
  timer=0;
}
