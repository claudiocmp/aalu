class TERRAIN {
  /////////////////////////////////////////////////////////////////////////////////////variables declaration
  //domain and bounding box
  T_DOMAIN _td;
  HE_Mesh bbox;
  int t_len;
  int x_ext;
  int y_ext;

  //points and mesh
  PVector[] points;
  HE_Mesh mesh;

  //topographical layers
  ArrayList<String> topo_layers_names;
  ArrayList<Object[]> topo_layers;
  //single topo layers
  int[] landuse;
  int[] river;

  /////////////////////////////////////////////////////////////////////////////////////constructor
  TERRAIN(String csv_data_path, T_DOMAIN td, String x_header, String y_header, String z_header) {
    //import domain
    _td = td;
    //initialise bounding box from domain
    HEC_Box creator=new HEC_Box();
    creator.setFromAABB(new WB_AABB(0, 0, 0, _td.delta_x*td.scale, _td.delta_y*_td.scale, _td.delta_z*_td.scale));
    creator.setWidthSegments(1).setHeightSegments(1).setDepthSegments(1);
    bbox=new HE_Mesh(creator); 
    HET_Diagnosis.validate(bbox);

    //here, points, mesh and data are initialised
    initialise_terrain(csv_data_path, x_header, y_header, z_header);
  }

  void initialise_terrain(String csv_data_path, String x_header, String y_header, String z_header)
  {
    //load table and its characteristics
    Table t = loadTable(csv_data_path, "header");
    t_len = t.getRowCount();
    //find column indices for columns X and Y
    List<String> headersList = Arrays.asList(t.getColumnTitles());
    if (!(headersList.contains(x_header) && headersList.contains(y_header) && headersList.contains(z_header))) 
    {
      throw new RuntimeException("The headers spcified are not the headers for the X,Y,Z coordinates of your points. Check your csv and type the correct headers");
    }
    int x_col_i = t.checkColumnIndex(x_header);
    int y_col_i = t.checkColumnIndex(y_header);
    //get terrain extent
    x_ext = t.getUnique(x_col_i).length;
    y_ext = t.getUnique(y_col_i).length;
    //check that the total amount of points correspond to x_extend*y_extent
    if (!(x_ext*y_ext==t_len))
    {
      throw new RuntimeException("Your CSV does not contain consistent data for your terrain");
    }

    //initialise the PVector[]
    points = new PVector[t_len];
    //initialise mesh containers
    float[][] vertices = new float[t_len][3]; 
    int[][] faces = new int[(y_ext-1)*(x_ext-1)][];

    //initialise data

    //Load table data into containers
    int k = 0;
    for (TableRow row : t.rows())
    {
      //extract x,y,z
      float x = row.getFloat(x_header);
      float y = row.getFloat(y_header);
      float z = row.getFloat(z_header);
      //retrieve processing coordinates (move, scale)
      PVector rw_pt = new PVector(x, y, z);
      PVector tmp = PVector.sub(rw_pt, _td.rw_trans);
      tmp = new PVector(tmp.x, td.delta_y -tmp.y, tmp.z); //flip Y
      tmp.mult(_td.scale);
      //assign to points[][] at i,j position
      points[k] = tmp.copy();
      //assign to vertices for mesh
      vertices[k][0] = tmp.x;
      vertices[k][1] = tmp.y;
      vertices[k][2] = tmp.z;
      k++;
    }

    /*
    TO DO:
     built the vertices[][] array after the csv has been read.
     introduce a sort(by x, by y) to have a horizontal scanning of the terrain automatically 
     */


    //create faces indices
    int index = 0;
    for (int j=0; j<y_ext-1; j++) {
      for (int i=0; i<x_ext-1; i++) {
        faces[index]=new int[4];
        faces[index][0] = i + x_ext * j;
        faces[index][1] = i + x_ext * (j + 1);
        faces[index][2] = i + 1 + x_ext * (j + 1);
        faces[index][3] = i + 1 + x_ext * j;
        if (j==0) {
          println("index: "+index);
          println(faces[index][0]);
          println(faces[index][1]);
          println(faces[index][2]);
          println(faces[index][3]);
        }
        index++;
      }
    }

    //create mesh
    //HEC_Facelist uses the vertices and the indexed faces to create a mesh with all connectivity.
    HEC_FromFacelist facelistCreator=new HEC_FromFacelist().setVertices(vertices).setFaces(faces).setDuplicate(false);
    mesh=new HE_Mesh(facelistCreator);
    mesh.validate();
    mesh.subdivide(new HES_Smooth());
  }

  void display_bb() {
    pushStyle();
    noFill();
    strokeWeight(.8);
    stroke(255);
    render.drawEdges(bbox);
    popStyle();
  }

  void display() {
    for (int i = 0; i < points.length; i++) {

      pushStyle();
      pushMatrix(); 
      stroke(255);
      fill(255);
      translate(  
        points[i].x, 
        points[i].y, 
        points[i].z);
      //ellipse(0, 0, 2, 2);
      //text( i, 0, 0);
      popMatrix();
      popStyle();
    }
    render.drawFacesVC(mesh);
    pushStyle();
    stroke(0);
    strokeWeight(.5);
    render.drawEdges(mesh);
    popStyle();
  }

  void colourTerrain() {
    println("colouring terrain");
    HE_VertexIterator vitr=mesh.vItr();
    while (vitr.hasNext()) {
      vitr.next().setColor(color(random(255), random(80), random(80, 180)));
    }
  }

  int[] getIJ(int index) {
    int[] res = {ceil(index/x_ext), index%x_ext};
    return res;
  }

  int getIndex(int i, int j) {
    return i + (j * x_ext);
  }
}

//Terrain domain class
class T_DOMAIN {
  //Real world coordinates
  float rw_min_x;
  float rw_max_x;
  float rw_min_y;
  float rw_max_y;
  float rw_min_z;
  float rw_max_z;
  //translation from origin
  PVector rw_trans;
  //real world domain
  float delta_x;
  float delta_y;
  float delta_z;

  //Processing coordinates
  float scale;
  PVector centre;

  //constructor
  T_DOMAIN(float _x_min, float _y_min, float _z_min, float _x_max, float _y_max, float _z_max, float _scale) 
  {
    //real world bounds
    rw_min_x = _x_min;
    rw_max_x = _x_max;
    rw_min_y = _y_min;
    rw_max_y = _y_max;
    rw_min_z = _z_min;
    rw_max_z = _z_max;

    //real world translation vector => (x,y,z)min to (0,0,0)
    rw_trans = new PVector(_x_min, _y_min, _z_min);

    //real dimensions in metres
    delta_x = _x_max - _x_min;
    delta_y = _y_max - _y_min;
    delta_z = _z_max - _z_min;

    //scale and centre in processing bbox
    scale = _scale;
    centre = new PVector(delta_x*scale*.5, delta_y*scale*.5, delta_z*scale*.5);
  }
}
