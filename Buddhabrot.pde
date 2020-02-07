// Buddhabrot
//   Jared S Tarbell
//   Albuquerque, New Mexico, USA
//   February 4, 2020
//
//   Processing 3.5.3
//
// Based on early work by Paul Bourke and others
//   http://astronomy.swin.edu.au/~pbourke/fractals/buddhabrot/

int bailout = 15000;           // number of iterations before bail
int plots = 500000;            // number of plots to execute per frame
int exposureLimit = 1000000;   // maximum number of exposures allowed at a single pixel

int blowout = 1000;    // blowout bright whites, the higher this is the more detail is exposed, highlights are lost

int mult = 2;          // exposure multiplier, final image will be dimensions of sketch times multiplier
int dimx;
int dimy;
PImage exposure;

int[][] img;              // 2D array to hold exposure values
int maximg;               // maximum exposure value for each cell

boolean drawing = false;  // rendering flag

void setup() {
  // set up drawing area
  size(1400,1400);
  background(0);
  
  // calculate the actual dimensions of the exposure plate as a multiple of the viewing area
  dimx = width*mult;
  dimy = height*mult;
  exposure = createImage(dimx,dimy,RGB);
  
  // initialize exposure array
  img = new int[dimx][dimy];
  for (int i=0;i<dimx;i++) {
    for (int j=0;j<dimy;j++) {
      img[i][j] = 0;
    }
  }
  
}

void draw() {
  plot();              // transform some particles through the system
  findMaxExposure();   // calculate highest exposure value
  renderBrot();        // draw the pixels of the fractal
  displayBrot();       // display the exposure in the viewing area
  
  // move to next bailout tier
  //bailout+=20;
  
  // when sufficiently exposed, save the image and end program
  //if (bailout>20000) {
  //  saveExposure();
  //  bailout = 100;
  //  noLoop();
  //}

}

void plot() {
  print("Plotting "+plots+"...");
  // iterate through some plots
  for (int n=0;n<plots;n++) {
    // choose a random point in sweet range 
    float x = random(-2.0,1.0);
    float y = random(-1.5,1.5);
    // compute location, if it escapes compute it again this time exposing it
    if (iterate(x,y,false)) iterate(x,y,true);
  }
}

void findMaxExposure() {
  print("finding max exposure:");
   // assume no exposure
   maximg=0;
   // find the largest density value 
   for (int i=0;i<dimx;i++) {
     for (int j=0;j<dimy;j++) {
       maximg = max(maximg,img[i][j]);
     }
   }
   print(maximg+"   ");
}

void renderBrot() {
  print("rendering...");
  // draw to screen
  exposure.loadPixels();
  for (int i=0;i<dimx;i++) {
    for (int j=0;j<dimy;j++) {
      float b = floor(map(img[i][j],0,maximg,0,blowout));
      if (b>255) b = 255;
      color c = color(b);
      exposure.set(j,i,c);
    }
  }
  exposure.updatePixels();
}

void displayBrot() {
  float dx = floor(-(mouseX*mult-width));
  float dy = floor(-(mouseY*mult-height));
  if (dx>0) dx = 0;
  if (dy>0) dy = 0;
  image(exposure,dx,dy);
  println("bailout: "+bailout);
}


//   iterate the Mandelbrot and return TRUE if the point exits
//   also handle the drawing of the exit points
boolean iterate(float x0, float y0, boolean drawIt) {
  float x = 0;
  float y = 0;
  float xnew, ynew;
  int ix,iy;
   
  for (int i=0;i<bailout;i++) {
    // calculate next location
    xnew = x0 + x*x - y*y;
    ynew = y0 + 2*x*y;
    if (drawIt && (i > 2)) {
      // map the location into the exposure plate
      //ix = int(dimx * (xnew + 2.0) / 3);
      //iy = int(dimy * (ynew + 1.5) / 3);
      
      // center heart region
      ix = int(-dimx*2.5 + dimx*11 * (xnew + 2.0) / 3);
      iy = int(-dimy*5 + dimy*11 * (ynew + 1.5) / 3);
      
      if (ix >= 0 && iy >= 0 && ix < dimx && iy < dimy) {
        // expose point
        if (img[ix][iy]<exposureLimit) img[ix][iy]++;
      }
    }
    
    if ((xnew*xnew + ynew*ynew) > 4) {
      // escaped
      return true;   
    }
    x = xnew;
    y = ynew;
  }
  // did not escape before bailout
  return false;
}

void saveExposure() {
  String outputFilename = "output/buddhabrot"+millis()+".png";
  println();
  print("Saving "+outputFilename+"...");
  exposure.save(outputFilename);
  println("done.");
  println();
}
  

void keyPressed() {
  if (key=='s' || key=='S') {
    saveExposure();
  }
}

void mousePressed() {
  blowout = mouseX*10;
  println();
  println("Setting blowout:"+blowout);
  println();
}
