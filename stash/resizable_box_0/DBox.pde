/*******************************************************************************************
 *
 *                                   DBOX CLASS
 *
 *  DBox or Detection Box is a custom class used to have a specific editable area
 *  where users are detected. It uses the point2line library for polygone detection,
 *  i.e. a tool to know if a point is inside a polygon
 *
 *  relies on Handle class (see below)
 *******************************************************************************************/

class DBox {
  int id;                             // dbox id
  int opacity = 50;                   // display opacity
  int population = 0;                 // detection state
  float distance = -1;
  float hsize = 10;                   // handle size
  Handle[] handles = new Handle[4];   // handles declaration

  //-----------------------------------------------------------------------------
  //                      DBOX CONSTRUCTOR
  DBox(int id, float dsize) {
    this.id = id;

    // read data from previous session
    handles[0] = new Handle(getDBoxDataCoor(id, 0).x, getDBoxDataCoor(id, 0).y, 0, 0, hsize, handles);
    handles[1] = new Handle(getDBoxDataCoor(id, 1).x, getDBoxDataCoor(id, 1).y, 0, 0, hsize, handles);
    handles[2] = new Handle(getDBoxDataCoor(id, 2).x, getDBoxDataCoor(id, 2).y, 0, 0, hsize, handles);
    handles[3] = new Handle(getDBoxDataCoor(id, 3).x, getDBoxDataCoor(id, 3).y, 0, 0, hsize, handles);
  }

  // read database (roomProfile.json)
  PVector getDBoxDataCoor(int id, int ihandle) {
    return new PVector(data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("x"), 
    data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("y"));
  }


  //---------------------------------------------------------------------------
  //                      OUTPUT FUNCTIONS


  
  //----------------------------------------------------------------------------
  //                       DBOX UPDATE 
  void update() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].update();
    }
  }

  //---------------------------------------------------------------------------
  //                      DBOX DISPLAY
  void display() {

    // vertex for polygon shape
    fill(255, 255, 255, opacity);
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < handles.length; i++) {
      vertex(handles[i].getX(), handles[i].getY());
    }
    endShape(CLOSE);

    stroke(255, 0, 0);
    strokeWeight(2);
    beginShape();
    vertex(handles[0].getX(), handles[0].getY());
    vertex(handles[1].getX(), handles[1].getY());
    endShape();

    // display handles
    for (int i = 0; i < handles.length; i++) {
      handles[i].display(i);
    }

    // display dbox id
    fill(255);
    textSize(70);
    //    float tempX = handles[0].getX();
    //    float tempY = handles[0].getY();
    text("ID "+ id + " / population: " + population + " / distance: " + distance, 30, height-250 +80*id);
  }

  //---------------------------------------------------------------------------
  //                      MOUSE EVENT
  void releaseEvent() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].releaseEvent();
    }
  }

  // TO-DO
  int numberOfDetections() {
    return 0;
  }
  float nearestDetection() {
    return 0;
  }
  //coordinates of people in DBox
  float[] getCoordinates() {
    return new float[0];
  }

  //--------------------------------------------------------------------------
  //                      GETTERS AND SETTERS
  Handle[] getHandles() {
    return handles;
  }
}

/*******************************************************************************************
 *
 *                                   HANDLE CLASS
 *
 *******************************************************************************************/
class Handle {
  float x_init, y_init;         // initial position
  float boxx, boxy;             // box real time position
  float xs, ys;                 // movement
  float size;                   // box size
  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state
  boolean otherslocked = false; // true when at least one of the handles is locked
  Handle[] others;              // list of handles

    Handle(float ix, float iy, float il, float ih, float is, Handle[] o) {
    x_init = ix;
    y_init = iy;
    xs = il;
    ys = ih;
    size = is;
    boxx = x_init+xs - size/2;
    boxy = y_init+ys - size/2;
    others = o;
  }

  //-----------------------------------------------------------------
  //                          UPDATE
  void update() {
    boxx = lock(x_init+xs, 20, width -20);
    boxy = lock(y_init+ys, 20, height-20);

    // othersLocked is true when at least one of the handles is locked
    for (int i=0; i<others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } else {
        otherslocked = false;
      }
    }

    // if no handles is locked, see if a handle is clicked
    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }
    if (press) {
      xs = mouseX-x_init-size/2;
      ys = mouseY-y_init-size/2;
    }
  }


  //-----------------------------------------------------------------
  //                          DISPLAY
  void display(int i) {

    // display handle
    fill(255);
    stroke(0);
    strokeWeight(1);
    rect(boxx, boxy, size, size);

    //display number
    fill(#000000);
    textSize(8);
    text(i, boxx, boxy);

    // display a cross when pressed
    fill(#FFFFFF);
    if (over || press) {
      line(boxx, boxy, boxx+size, boxy+size);
      line(boxx, boxy+size, boxx+size, boxy);
    }
  }


  //---------------------------------------------------------------------------
  //                      MOUSE EVENT

  void overEvent() {
    if (overRect(boxx, boxy, size, size)) {
      over = true;
    } else {
      over = false;
    }
  }

  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }

  void releaseEvent() {
    locked = false;
  }


  boolean overRect(float x, float y, float w, float h) {
    if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }

  //---------------------------------------------------------------------------
  //                      GETTERS & SETTERS

  float getX() {
    return boxx+size/2;
  }

  float getY() {
    return boxy+size/2;
  }

  //---------------------------------------------------------------------------
  //                      MATH FUNCTIONS

  // limits
  float lock(float val, float minv, float maxv) { 
    return  min(max(val, minv), maxv);
  }
}