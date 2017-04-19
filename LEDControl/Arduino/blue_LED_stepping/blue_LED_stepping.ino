/*
FPM code
*/
//Adapted from examples from Adafruit
#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library
//setting range of LED's to use and the color
int centerx = 16, centery = 15, xmin = 0, xmax = 15, ymin = 0, ymax= 15, hue = 0, x, y; 
int xstart = centerx-((xmax-1)/2), xend = centerx+((xmax-1)/2), ystart = centery-((ymax-1)/2), yend = centery+((ymax-1)/2);
int total = (xmax-xmin)*(ymax-ymin), counter = 1;
#define CLK 8 
#define OE  9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2
#define D   A3

RGBmatrixPanel matrix(A, B, C, D, CLK, LAT, OE, false);
//define the characters sent by matlab
int matCOM = 0;

void setup() {  
  
  
  Serial.begin(9600);
  matrix.begin();
  matrix.drawPixel(centerx,centery,matrix.Color333(0, 0, 7));
  Serial.println('a');
  char a = 'b';
  while (a != 'a')
  {
    a = Serial.read();
  }
  matrix.drawPixel(centerx,centery,matrix.Color333(0, 0, 7));
  while(dark=0){
  if (Serial.available() > 0)
  {
    matCOM = Serial.read();
    if (matCOM == '1')
    {
      matrix.fillRect(xstart, ystart, xmax, ymax, matrix.Color333(0, 0, 0));
    dark = 1
    }
  }
}
}

// the loop routine runs over and over again until satisfied:
void loop() {
  x = 0;
  y = 0;
  while(counter<=total){
   if (Serial.available() > 0)
     {
       matCOM = Serial.read();
   if (matCOM == '1')
     {
      
      triggerNextLed();
      matrix.drawPixel(xstart+x, ystart+y, matrix.Color333(0, 0, 7));
      Serial.println("2"); 
//      Serial.println(x);
//      Serial.println(y);
//      Serial.println("Send 1 when ready");
     }
    }
  }
  }
  

int triggerNextLed(){
        matrix.fillRect(xstart, ystart, xmax, ymax, matrix.Color333(0, 0, 0));
         if (y == ymax-1){
           x = x+1;
           y = 0;
         }
         else{
           y = y+1;
         }
         if(x > xmax-1){
           x = 0;
           y = 0;
         }
         return x,y;
      }
