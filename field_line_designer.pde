/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/34033*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */

////////////////////////////////////////////////////////
//                                                    //
//      F I E L D    L I N E    D E S I G N E R       //
//                                                    //
////////////////////////////////////////////////////////

//      (c) bit.craft 2011

//      
//      click the mouse to charge it and move it around.
//      once you release the mouse, the charge is released to the field.
//      
//      Key Map
//      
//      [SPACE] to switch the mouse charge
//      [TAB] or [#] switch between field types 
//      
//      [q][w][e] [a][s][d] move the limits 
//      [l] limit on/off
//      
//      Use cursor keys to rotate the field lines.
//      [SHIFT] cursor keys to change the line density
//      
//      [b] blurred / soft mode
//      [m] moiree mode on/off
//      [-] line thickness
//      [f] filters
//      [t] tiled mode
//      [i] invert colors
//      
//      [1] lores 
//      [2] hires
//      [g] grid style reset
//      [r] reset all
//      [R] reset all
//      
//      [S] save image to data folder
//      [D] draw background or not
//      
//      enjoy!
//

static final int XLINES = 1, YLINES = 2, XYLINES = 3,  MASK = 0xff;
static final int ANG = 0, MAG = 1;

static color nocolor = #cccccc, fgcolor = #003399, bgcolor = #ffffff;
float shiftsteps = 16f, moireeFactor = 50;

int xscale, yscale, xshift, yshift, renderMode, filterMode;
boolean limited, smooth, moiree, drawBackground;
float charge, newcharge, csum, tween;
float yrange, above, below;
float[][][] field;
color[] buffer;
float xres, yres;
int n, w, h;
PImage img;
int res = 1;
int edge = 0;
int oldWidth = 400; 
int oldHeight = 400;

void setup() {
  img = loadImage("in.jpg");

  size(oldWidth, oldHeight);  
  if (frame != null) {
    frame.setResizable(true);
  }

  colorMode(RGB, 2);
  cursor(CROSS);
  reset(res);
  resetGrid();
}

void draw() {
  if(oldHeight != height || oldWidth != width){
    reset(res);
    resetGrid();
    oldHeight = height;
    oldWidth = width;   
  }
  xres = float(w) / width;  
  yres = float(h) / height;
  float factor = moiree ? moireeFactor : 1.0;
  charge = mousePressed ? lerp(charge, newcharge, tween) : 0;
  yrange = 1 + (above + below);
  float ymin = 5 * (csum + charge) - below;
  float ymax = ymin + yrange;
  color ctop = color(0);
  color cbottom = color(2);
  float bottom =  ymin + yshift / shiftsteps;
  float top = ymax + yshift / shiftsteps;
  float xs = xscale * factor;
  float ys = yscale * factor / yrange;
  float dx = xshift / shiftsteps;
  float dy = ymin  +  yshift / shiftsteps;
  loadPixels();
   for(int y = 0; y < h; y++) {
     for(int x = 0; x < w; x++) {
       float[] vector = field[x][y];
       float px = x - mouseX * xres;
       float py = y - mouseY * yres;
       float mag = (vector[MAG] + charge * log(mag(px, py)) + .5);
       color c = 0;
       if(limited && mag < bottom) c = cbottom;
       else if(limited && mag > top) c = ctop;
       else {
         mag = (mag - dy) * ys;
         mag = mag - floor(mag);
         float ang = ((vector[ANG] + charge * atan2(px, py)) - PI) / TWO_PI ;
         ang = ang * xs + dx;
         ang = ang - floor(ang);
         
         switch(renderMode) {
           case(XLINES): c = color(ang + .5); break;
           case(YLINES): c = color(mag + .5); break;
           case(XYLINES): c = color(mag +ang); break;
         }  
       }
       pixels[y * w + x] = c;
     }
   }

   if(filterMode > 0) edgeFilter(filterMode, 1 + edge); 
   if(smooth) blurFilter(res); else if(res > 1) blurFilter(res-1);
   if(drawBackground) drawBackground();
   updatePixels();
   if(frameCount % 20 == 0) println(frameRate);
}

void addCharge(float ax, float ay, float charge) {
  csum += charge;
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      float dx = (x - ax);
      float dy = (y - ay);
      float[] vector = field[x][y];
      vector[ANG] += charge * atan2(dx, dy);
      vector[MAG] += charge * log(mag(dx, dy));
    }
  }
}

void save() {
  String date = concat("-", s(year()), s(month()), s(day()));
  String time = concat(":", s(hour()), s(minute()), s(second()));
  String fileName = "data/out";
  String fileType = "jpg";
  saveFrame(concat(".", fileName, date, time, fileType));
}

String concat(String separator, String... args){
  String result = "";
  for(int i=0; i<args.length - 1; i++){
    result += args[i] + separator;
  }
  result += args[args.length - 1];
  return result;
}

String s(Integer number){
  return String.valueOf(number);
}