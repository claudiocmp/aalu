void keyPressed() {
  if (key=='c') {
    //t.colourTerrain();
    thread("threadcall");
    println(t.getIJ(0));
    println(t.getIJ(150));
    println(t.getIndex(15, 20));
  }
}

void threadcall(){
 t.colourByStrings(t.Landuse, palette[0][0], palette[0][1]); 
}
