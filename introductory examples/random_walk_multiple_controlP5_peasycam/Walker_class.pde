/**
 * Random walker class
 * 
 * Re-coded from D. Shiffmann's Nature of Code
 *
 */
 
 
class Walker {

  int x;
  int y;

  int d = 10;

  Walker(int _x, int _y) {
    this.x = _x;  
    this.y = _y;
  }

  void visualise() {
    pushStyle();
    
    //stroke(255, 210, 180);
    //point(x, y);
    
    noStroke();
    fill(red_quantity, green_quantity, blue_quantity);
    ellipseMode(CENTER);
    ellipse(x, y, d, d);
    popStyle();
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
