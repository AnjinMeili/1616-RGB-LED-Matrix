// 16x16 Simple Color LED Matrix Single Color Graphic Example
// Pinouts for Arduino Duemilanove
// pinouts may vary slightly depending on your particular board
// Use the simple HTML based frame editor to edit your frames, then past the number sets in one after the other.
//
// Upper and Lower half RGB serial lines each get their own pin
// On Amber the R1 and R2 pins should be connected to two serial lines, such as the R1 and R2
//
// Upper and Lower half Clock, Latch Enable and Output Enable Lines are shared
//
// These are just examples to see how to communicate with the display panels, I truly hope someone comes
// up with something much better to operate them.
//
// Use the matrix_draw.html file to make your own animations. Just turn your head sideways to draw :P
// Make a frame, 'compute hex code' then paste the numbers in, do that over and over for each frame of your animation.

#include <avr/pgmspace.h>

// Pin Setup Lower Half
 int datar1 = 2;     // Data Pin for Red Serial Data
 int datag1 = 3;     // Data Pin for Green Serial Data
 int datab1 = 4;     // Data Pin for Blue Serial Data
 
// Pin Setup Upper Half
 int datar2 = 5;     // Data Pin for Red Serial Data
 int datag2 = 6;     // Data Pin for Green Serial Data
 int datab2 = 7;     // Data Pin for Blue Serial Data
 
 // Clock and Latch Enable Pins
 int clock = 8;      // Clock pin
 int le = 12 ;       // Latch Enable Pin
 
// Output Enable pins use on PWM pins for PWM dimming
 int oer = 9;       // Red
 int oeg = 10;      // Green
 int oeb = 11;      // Blue
 
// Enable(1) or disable(0) PWM 
 boolean PWMEnable = 1; 
 
// RGB Brightness, 0 = Full, 127 = Half, 255 = Off
 byte rbright = 0; 
 byte bbright = 0; 
 byte gbright = 0;

// Pause between each frame
 int del(20);
 
// Define our animation sequence, the "Droplet" animation below consists of 23 frames, each consisting of 16 16-bit 
// unsigned integers for a total of 368 values (16*23). That's a lot of RAM to take up for static content, so we're  
// going to store them in the program memory instead(flash) using PROGMEM.

// Droplet Anim
PROGMEM prog_uint16_t gfx[] = {  
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/*one frame*/,1,1,1,1,1,1,32769,32769,1,1,1,1,1,1,1,1,/*another frame, etc*/
  1,1,1,1,1,32769,16385,16385,32769,1,1,1,1,1,1,1,1,1,1,1,1,49153,8193,8193,49153,1,1,1,1,1,1,1,
  1,1,1,1,1,24577,36865,36865,24577,1,1,1,1,1,1,1,1,1,1,1,1,12289,18433,18433,12289,1,1,1,1,1,1,1,
  1,1,1,1,1,6145,9217,9217,6145,1,1,1,1,1,1,1,1,1,1,1,1,3073,4609,4609,3073,1,1,1,1,1,1,1,
  1,1,1,1,1,1537,2305,2305,1537,1,1,1,1,1,1,1,1,1,1,1,1,769,1153,1153,769,1,1,1,1,1,1,1,
  1,1,1,1,1,385,577,577,385,1,1,1,1,1,1,1,1,1,1,1,1,193,289,289,193,1,1,1,1,1,1,1,
  1,1,1,1,1,97,145,145,97,1,1,1,1,1,1,1,1,1,1,1,1,49,73,73,49,1,1,1,1,1,1,1,
  1,1,1,1,1,25,37,37,25,1,1,1,1,1,1,1,1,1,1,1,1,13,19,19,13,1,1,1,1,1,1,1,
  1,1,1,1,3,7,9,9,7,3,1,1,1,1,1,1,1,1,5,3,7,3,5,5,3,7,3,5,1,1,1,1,
  1,9,5,3,15,3,1,1,3,15,3,5,9,1,1,1,1,9,5,3,15,3,1,1,3,15,3,5,9,1,1,1,
  17,9,1,1,25,1,1,1,1,25,1,1,9,17,1,1,17,1,1,1,17,1,1,1,1,17,1,1,1,17,1,1,
  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
  
// Make sure your display is facing the right way (fed from right to left). The HTML generator
// actually reverses the order of each the generated frames so it appears in the right order on
// the display.
// If you make your own program or convert graphics, keep that in mind.
// If you don't want to erase the original graphic, just make more PROGMEM statements like below
// and replace with your own values and update the code to use the new array.

PROGMEM prog_uint16_t gfx2[] = {63496,40968,22536,62,47132,8,14336,10752,15880,8,63496,8265,6251,32830,63516,32776};  

void setup()
{
// Set all the pins we're using as outputs  
  pinMode(datar1, OUTPUT);
  pinMode(datag1, OUTPUT);
  pinMode(datab1, OUTPUT);
  pinMode(datar2, OUTPUT);
  pinMode(datag2, OUTPUT);
  pinMode(datab2, OUTPUT);  
  pinMode(le, OUTPUT);
  pinMode(clock, OUTPUT);
  pinMode(oer, OUTPUT);
  pinMode(oeg, OUTPUT);
  pinMode(oeb, OUTPUT);

// Set clock and latch enable(le) low
  digitalWrite(clock, LOW);
  digitalWrite(le, LOW);
  
// Set the brightness of the display to the proper levels via PWM
  if(PWMEnable)
  {
    analogWrite(oer, rbright);
    analogWrite(oeg, gbright);
    analogWrite(oeb, bbright);
  }
  else
  {
    digitalWrite(oer, LOW);
    digitalWrite(oeg, LOW);
    digitalWrite(oeb, LOW);
  }
} 

void loop()
{
  // Figure out the size of the array (flexible in case you do your own graphic)
  int array_size = sizeof(gfx) / 2; // sizeof returns the number of 8-bit elements, we need 16
                                    // so I just divided by two, seems to work.
                                    
  // The index is used to follow our sub-loops through the main array loop                                    
  int index = 0;
  
  for(int array_loop = 0; array_loop < array_size; array_loop++)
  {
    LEDshiftOut(pgm_read_word(&gfx[array_loop])); // Shift out the data from the gfx array in PROGMEM at the array_loop position
    index++; // The read position index
    
    // After we read 16 columns we latch the data we just sent
    // into the registers of the LED drivers.
    if(index == 16)
    {
      index = 0; // reset the read position index
      digitalWrite(le, HIGH); // Latch the Data
      digitalWrite(le, LOW);
      delay(del); // Delay for x mseconds
    }
  }
}

// This is a modified version of the default Arduino shiftOut command
void LEDshiftOut(uint16_t val)
{
      uint8_t i;

      // Write a column of data, we have a 16 bit value, which is broken down to 2 8-bit values
      // so we cycle through this 8 times, writing two bits per cycle(1 Upper Half, 1 Lower Half)
      // We send it to red, green and blue channels which ends up all white. To do color you would
      // need to have pixel maps for each color.
      for (i = 0; i < 8; i++)  {

      // Write a pixel value to the top half of the display
        digitalWrite(datar1, !!((val >> 8) & (1 << i)));
        digitalWrite(datag1, !!((val >> 8) & (1 << i)));                 
        digitalWrite(datab1, !!((val >> 8) & (1 << i)));
        
      // Write a a pixel value to the bottom half of the display 
        digitalWrite(datar2, !!((val & 0xFF) & (1 << i)));
        digitalWrite(datag2, !!((val & 0xFF) & (1 << i)));
        digitalWrite(datab2, !!((val & 0xFF) & (1 << i)));                 
 
      // Clock the data into the driver registers      
        digitalWrite(clock, HIGH);
        digitalWrite(clock, LOW);            
      }
}
