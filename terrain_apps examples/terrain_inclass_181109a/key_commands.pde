//<>// //<>// //<>//
void keyPressed() {
  if (key == 'c') {
    thread("colorTerrain_1");
  }
  if (key == 'r') {
    t.colourByValues(t.river, color(255, 40, 51), color(132, 40, 255));
  }
}

void colorTerrain_1() {
  t.colourByString(t.landuse, color(255, 40, 51), color(132, 40, 255));
}
void colorTerrain_2() {
  t.colourByValues(t.river, color(255, 40, 51), color(132, 40, 255));
}


void mousePressed() {
  //thread("selV");
  selected_v = render.pickVertex(t.mesh, mouseX, mouseY);

  if (selected_v != null  && keyPressed) {
    cam.setActive(false);
    String text = t.getLandUse(selected_v);
  }

  //command for A* search
  if (selected_v != null && keyPressed && key == 'a' && mouseButton == LEFT) {
    runAStar();
  }
}


void runAStar() {
  if (t.is_start) {
    int p_i = t.getIndex(selected_v);
    t.path.clear();
    t.from =-1;
    t.to = -1;
    if (p_i >= 0) { //make sure you selected a valid point
      int[] closest_node = Util.closestNode(t.points[p_i], t.nmap, 100, t);
      t.from = t.nmap[closest_node[0]][closest_node[1]];
      if (t.from >=0) {
        t.is_start = !t.is_start;
      }
    }
  } else {
    int p_i = t.getIndex(selected_v);
    t.to = -1;
    if (p_i >= 0) { //make sure you selected a valid point
      int[] closest = Util.closestNode(t.points[p_i], t.nmap, 100, t); //get closest node to 
      t.to = t.nmap[closest[0]][closest[1]];
      if (t.to >=0) {
        t.is_start = !t.is_start;
      }
    }
  }
  println(t.from);
  println(t.to);
  println(t.is_start);
  println();
  if ( t.from >=0 && t.to >=0) {
    t.path.clear();
    println( t.aStar(t.from, t.to) );
  }
}




void mouseReleased() {
  cam.setActive(true);
}


void selV() {
  selected_v = render.pickVertex(t.mesh, mouseX, mouseY);
}
