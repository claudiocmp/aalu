void keyPressed() {
  if (key=='l') {
    //t.colourTerrain();
    thread("threadcall");
    println(t.getIJ(0));
    println(t.getIJ(150));
    println(t.getIndex(15, 20));
  }
  if (key=='n') {
    //t.colourTerrain();
    thread("thredRiver");
    println(t.getIJ(0));
    println(t.getIJ(150));
    println(t.getIndex(15, 20));
  }
  if (key=='r'){
  showRunOff = ! showRunOff;
  }
}

void threadcall(){
 t.colourByStrings(t.Landuse, palette[0][0], palette[0][1]); 
}

void thredRiver(){
t.colourByValues(t.River,0,1);
}

void threaddraw(){
  ps.update();
}
