class Particle {

  PVector pos;
  PVector p_pos;
  PVector vel;
  PVector acc;
  float max_vel;
  float max_acc;

  WB_Coord meshPt;

  Particle(PVector p) {
    this.pos = p;
    this.p_pos = p.copy();
    this.vel = new PVector(0f, 0f, 0f);
    this.acc = new PVector(0f, 0f, 0f);
    this.max_acc = 5;
    this.max_vel = 5;
  }

  void flow(PVector force, Terrain t) {
    this.acc = PVector.add( acc.mult(.8), force.mult(.2) );
    this.acc.limit(max_acc);
    this.vel.add(acc);
    this.vel.limit(max_vel);
    this.p_pos = pos.copy();
    this.pos.add(vel);
    //TODO - resnap to terrain
    meshPt = t.mesh.getClosestPoint(new WB_Point(pos.x, pos.y, pos.z), t.mesh_topology_tree);
    this.pos = new PVector(meshPt.xf(), meshPt.yf(), meshPt.zf());
  }

  void display() {
    if (pos.z > 1.0) {
      pushMatrix();
      translate(this.pos.x, this.pos.y, this.pos.z+1);
      ellipseMode(CENTER);
      ellipse(0, 0, 4, 4);
      popMatrix();
    }
  }
}


class ParticleSystem {
  Particle[] particles;
  Terrain t;

  ParticleSystem(int no_p, Terrain t) {
    this.t = t;
    this.particles = new Particle[no_p];
    for (int i =0; i < no_p; i++) {
      int v_i = (int)random(0, t.mesh.getVerticesAsArray().length);
      WB_Coord c =t.mesh.getVertex(v_i);
      particles[i] = new Particle( new PVector(c.xf(), c.yf(), c.zf()) );
    }
  }

  void update() {
    for (Particle p : this.particles) {
      int f_i = Util.closestFace(p.pos, t.mesh.getFacesAsArray());
      //TODO replace particles that reaced the sea somewhere else
      if (p.pos.z < 1.0 || PVector.dist(p.pos, p.p_pos) < 0.1) {
        int v_i = (int)random(0, t.mesh.getVerticesAsArray().length);
        p.pos = new PVector( t.mesh.getVertex(v_i).xf(), t.mesh.getVertex(v_i).yf(), t.mesh.getVertex(v_i).zf() );
      }
      WB_Coord fn = t.mesh.getFaceNormal(f_i);
      PVector n = new PVector(fn.xf(), fn.yf(), fn.zf());
      PVector f = n.cross(new PVector(0., 0., -1.)).cross(n); //from normal to slope
      p.flow(f, t);
    }
  }

  void display() {
    pushStyle();
    noStroke();
    fill(200,210,250);
    for (Particle p : this.particles) {
      p.display();
    }
    popStyle();
  }
}
