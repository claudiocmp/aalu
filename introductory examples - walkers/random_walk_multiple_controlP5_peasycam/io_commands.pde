
void keyPressed() {
  if (key == 'r') {
    run = !run;
  }
}


void printMouseCoord() {
  pushStyle();
  fill(255);
  text(mouseX, 20, 20);
  text(mouseY, 20, 35);
  popStyle();
}


void mousePressed() {

  if ( cp5.isMouseOver()) {
    cam.setActive(false);
  }
}

void mouseReleased() {

  cam.setActive(true);
}
