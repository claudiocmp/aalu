// declare one Walker, call it jack
Walker jack;

void setup() {
  size(800, 800);
  background(0);

  //instantiate walker object
  jack = new Walker( (int)random(0,width) ,  (int)random(0,height) );
  //visualise the walker object
  jack.visualise();
}


void draw() {
  // these are called @ each frame
  background(0);
  //make it stepping
  jack.step();
  jack.visualise();
}
