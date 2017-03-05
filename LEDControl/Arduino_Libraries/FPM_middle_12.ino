/*
FPM code
*/
//Adapted from examples from Adafruit
#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library
//setting range of LED's to use and the color
int xmin = 9, xmax = 21, ymin = 9, ymax= 21, hue = 0, x, y; 
int total = (xmax - xmin)*(ymax-ymin), counter = 1;
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
  Serial.println('a');
  char a = 'b';
  while (a != 'a')
  {
    a = Serial.read();
  }
}

// the loop routine runs over and over again until satisfied:
void loop() {
   matrix.begin();
   x = xmin;
   y = ymin;
   matrix.drawPixel(x, y, matrix.Color333(7, 7, 7));
   delay(1000);
   
    while (counter < total){
   if (Serial.available() > 0)
     {
       matCOM = Serial.read();
   if (matCOM == '1')
     {
      triggerNextLed();
      matrix.drawPixel(x,y,matrix.Color333(7,7,7));
      Serial.println("1"); 
//      Serial.println(x);
//      Serial.println(y);
//      Serial.println("Send 1 when ready");
     }
    }
  }
  }

int triggerNextLed(){
        matrix.drawPixel(x,y,matrix.Color333(0,0,0));
         if (y == ymax){
           x = x+1;
           y = ymin;
         }
         else{
           y = y+1;
         }
         if(x > xmax){
           x = xmin;
           y = ymin;
         }
         return x,y;
      }
