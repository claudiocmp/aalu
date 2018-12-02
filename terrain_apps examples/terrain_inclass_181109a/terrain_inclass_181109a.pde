/**
 * Terrain template (in class)
 * 
 * 
 * by Claudio Campanile, 2017-18
 *
 */
 
 //HE_Mesh stuff
import wblut.hemesh.*;
import wblut.core.*;
import wblut.geom.*;
import wblut.processing.*;
import wblut.math.*;
//peasycam
import peasy.*;
//java stuff
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;
import java.util.HashSet;

//HE_mesh helper
WB_Render render;
HE_Vertex selected_v;

//Particle system
ParticleSystem ps;

//terrain domain
TerrainDomain terrainDomain;
PVector A = new PVector(269287.5, 3115743, 0);
PVector B = new PVector( 274787.5, 3119943, 1081.651 );
float S = 0.1;

//Terrain
Terrain t;

//camera
PeasyCam cam;

void setup() {
  size(1280, 720, P3D);

  //HE_mesh helpers
  render = new WB_Render(this);

  //terrain domain
  terrainDomain = new TerrainDomain(A.x, B.x, A.y, B.y, A.z, B.z, S);
  //terrain
  t = new Terrain("terrain_data.csv", "X", "Y", "Z", terrainDomain);

  ps = new ParticleSystem(150, t);

  //camera
  cam = new PeasyCam(this, t.td.centre.x, t.td.centre.y, t.td.centre.z, width*.5);
  cam.setMinimumDistance(width*.15);
  cam.setMaximumDistance(width*.85);
}


void draw() {
  background(0);
  //lights();
  directionalLight(230, 230, 230, 1, -1, -1);

  t.visualise();
  thread("updateParticles");
  ps.display();


  // //test on nodes
  //for (Node n : t.nodes) {
  //  pushMatrix();
  //  translate(n.x, n.y, 0);
  //  ellipse(0, 0, 5, 5);
  //  popMatrix();
  //}
  // //test on nmap
  //  for (int i=0; i<t.nmap.length; i++) {
  //    for (int j=0; j<t.nmap[i].length; j++) {
  //      if (t.nmap[i][j]>=0) {
  //        pushMatrix();
  //        translate(t.nodes.get( t.nmap[i][j]).x, t.nodes.get( t.nmap[i][j]).y, 0);
  //        ellipse(0, 0, 5, 5);
  //        popMatrix();
  //      }
  //    }
  //  }
}


void updateParticles() {
  ps.update();
}
