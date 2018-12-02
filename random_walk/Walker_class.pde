class Walker {

  int x;
  int y;

  int d = 5;

  Walker(int _x, int _y) {
    x = _x;  
    y = _y;
  }

  void visualise() {
    // //point
    //stroke(255, 210, 180);
    //point(x, y);

    //ellipse
    fill(255, 210, 180);
    ellipseMode(CENTER);
    ellipse(x, y, d, d);
  }

  void step() {

    int choice = (int)random(4);

    if (choice == 0) {
      x++;
    } else if (choice == 1) {
      y++;
    } else if (choice == 2) {
      x--;
    } else {
      y--;
    }

    x = constrain(x, 0, width-1);
    y = constrain(y, 0, height-1);
  }
}
