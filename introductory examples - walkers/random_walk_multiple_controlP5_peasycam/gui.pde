void gui() {
  
  cp5 = new ControlP5(this);
  Accordion accordion;
  
  Group colours_group = cp5.addGroup("colurs!")
    .setBackgroundColor(color(255,64))
    .setBackgroundHeight(150);
  
  int h_offset = 20;


  cp5.addBang("move_particles")
    .setPosition(h_offset, 100)
    .setSize(100, 20)
    .setLabel("Make all the LU friends to run!");


  cp5.addSlider("red_quantity")
    .setPosition(10, 20)
    .setRange(0, 255)
    .setValue(100)
    .setNumberOfTickMarks(5)
    .moveTo(colours_group)
    
    ;

  cp5.addSlider("green_quantity")
    .setPosition(10, 40)
    .setRange(0, 255)
    .setValue(100)
    .setNumberOfTickMarks(5)
    .moveTo(colours_group)
    ;

  cp5.addSlider("blue_quantity")
    .setPosition(10, 60)
    .setRange(0, 255)
    .setValue(100)
    .setNumberOfTickMarks(5)
    .moveTo(colours_group)
    ;
   
   accordion = cp5.addAccordion("acc")
   .setPosition(h_offset,150)
   .setWidth(120)
   .setHeight(80)
   .addItem(colours_group)
   ;
    
    accordion.open(0);
}


void move_particles() {
  run =! run;
}
