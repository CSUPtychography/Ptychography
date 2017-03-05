/*
FPM code
*/
//Adapted from examples from Adafruit
#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library
//setting range of LED's to use and the color
int xmin = 9, xmax = 21, ymin = 9, ymax= 21, hue = 0, x, y; 
// If your 32x32 matrix has the SINGLE HEADER input,
// use this pinout:
#define CLK 8  // MUST be on PORTB! (Use pin 11 on Mega)
#define OE  9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2
#define D   A3
// If your matrix has the DOUBLE HEADER input, use:
//#define CLK 8  // MUST be on PORTB! (Use pin 11 on Mega)
//#define LAT 9
//#define OE  10
//#define A   A3
//#define B   A2
//#define C   A1
//#define D   A0
RGBmatrixPanel matrix(A, B, C, D, CLK, LAT, OE, false);

void setup() {                

}

// the loop routine runs over and over again until satisfied:
void loop() {
  matrix.begin();
 for(x = xmin; x < xmax; x++) {
   for (y = ymin; y < ymax; y++) {
     matrix.drawPixel(x, y, matrix.Color333(7, 7, 7));
    delay(1000);// wait for 1000 milliseconds (1 second)
    matrix.drawPixel(x, y, matrix.Color333(0, 0, 0));
    }
  }
}
