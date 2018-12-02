/** //<>//
 * Introduction to processing / OOP + inputs + libraries (peasycam/cp5)
 * 
 * 
 * by Claudio Campanile, 2017
 *
 */
 

import peasy.*;
import controlP5.*;

ControlP5 cp5;
PeasyCam cam;

int red_quantity;
int green_quantity;
int blue_quantity;

Walker[] drunk_people;
boolean run;

void setup() {
  size(800, 800, P3D);
  background(0);
  
  run = false;

  //instantiate the camera
  cam = new PeasyCam(this, width*.5,height*.5,0, 800);
  cam.setMinimumDistance(300);
  cam.setMaximumDistance(1500);
  //cam.setSuppressRollRotationMode();
  
  //instantiate Walker array
  drunk_people = new Walker[100];
  //for loop for each walker object
  for (int i = 0; i < drunk_people.length; i++) {
    //instantiate a walker per each position in the array
    drunk_people[i] = new Walker( (int)random(0, width-1), (int)random(0, height-1) ) ;
    drunk_people[i].visualise();
  }
  
  //instantiate graphical user interface (gui)
  gui();
}


void draw() {
  background(0);

  printMouseCoord();

  if (run) {
    //make it stepping a walker for each position in the array
    for (int i = 0; i < drunk_people.length; i++) {
      drunk_people[i].step();
      //drunk_people[i].visualise();
    }
  }
  for (int i = 0; i < drunk_people.length; i++) {
    drunk_people[i].visualise();
  }
  
  cam.beginHUD();
  
  cp5.setAutoDraw(false);
  cp5.draw();
  
  cam.endHUD();
  
}
