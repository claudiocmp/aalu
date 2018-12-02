/**
 * Terrain template (draft)
 * 
 * 
 * by Claudio Campanile, 2017-18
 *
 */
 
////////////////////////////Imports
//java objects to perform List<>Array<>ArrayList conversion
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;

//Camera
import peasy.*;

//Mesh objects
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.processing.*;
import wblut.math.*;

//PVector objects
import toxi.geom.*;

//peasycam camera
PeasyCam cam;

//here, to select anythin on XY plane
PVector floorPos = new PVector( 0, 0, 0 );
PVector floorDir = new PVector( 0, 0, -1 );
PVector mouseOnXY;

//terrain characteristics
TERRAIN t;
T_DOMAIN td;
//here, there are the bounds of the terrain
float Ax_ = 269287.5;
float Bx_ = 274787.5;
float Ay_ = 3115742.5;
float By_ = 3119942.5;
float Az_ = 0.0;
float Bz_ = 1081.6;
//scale to adapt to processing window
float scale_ = 0.3;

//utils
WB_Render render;

//-----------------------SETUP--------------------------
void setup() {
  //window properties
  size(1200, 720, P3D);
  background(17, 17, 17);

  /////////////////////////////////////////////////////////////////////////////////////TERRAIN
  td = new T_DOMAIN(Ax_, Ay_, Az_, Bx_, By_, Bz_, scale_);
  t = new TERRAIN("terrain_data.csv", td, "X", "Y", "Z");

  //start camera
  cam = new PeasyCam(this, t._td.centre.x, t._td.centre.y, t._td.centre.z, t._td.centre.z*15);
  cam.setYawRotationMode();
  cam.setSuppressRollRotationMode();
  //cam.setActive(false); //stops the camers from moving, but the camera still exists

  //renderer
  render=new WB_Render(this);
}

//-----------------------DRAW--------------------------
void draw() {
  background(0);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);

  //mouse on XY plane
  mouseOnXY = getUnProjectedPointOnFloor(mouseX, mouseY, floorPos, floorDir );
  pushMatrix();
  translate(mouseOnXY.x, mouseOnXY.y);
  noStroke();
  fill(200);
  sphere(3);
  popMatrix();

  t.display_bb();
  t.display();
  
  //end of 3D
  cam.beginHUD();
  //draw on screen
  pushStyle();
  noStroke();
  fill(255, 40);
  rectMode(CORNER);
  rect(0, 0, width*.16, height*.08);
  fill(255);
  textAlign(CENTER, CENTER);
  text("TERRAIN CLASS DEMO", width*.08, height*.04);
  popStyle();
  //end of draw-on-screen session
  cam.endHUD();
}
/// End Draw
