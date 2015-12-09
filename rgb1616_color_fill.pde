// 16x16 Color LED Matrix Color Wipe Example
// Pinouts for Arduino Duemilanove
// pinouts may vary slightly depending on your particular board
// 
// Pin Setup Upper Half
 int datar1 = 2;    // Data Pin for Red Serial Data
 int datag1 = 3;    // Data Pin for Green Serial Data
 int datab1 = 4;    // Data Pin for Blue Serial Data
 
// Pin Setup Lower Half
 int datar2 = 5;    // Data Pin for Red Serial Data
 int datag2 = 6;    // Data Pin for Green Serial Data
 int datab2 = 7;    // Data Pin for Blue Serial Data
 
 int clock = 8;     // Clock pin
 int le = 12 ;      // Latch Enable Pin
 
// Output Enable pins use on PWM pins for PWM dimming
 int oer = 9;       // Red
 int oeg = 10;      // Green
 int oeb = 11;      // Blue
 
// Set Brightness
 int PWMEnable = 1; // Enable or Disable PWM brightness control (0/1)
 int rbright = 0;   // Brightness if using PWM (255 = off, 128 = half, 0 = full)
 int bbright = 0;   // Brightness if using PWM (255 = off, 128 = half, 0 = full)
 int gbright = 0;   // Brightness if using PWM (255 = off, 128 = half, 0 = full)
 int num_pixels = 256; // Number of pixels (256 = 1 panel)

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
  
// Set clock and latch enable(le) low to start with
  digitalWrite(clock, LOW);
  digitalWrite(le, LOW);
  
// Set the brightness of the display to the proper levels via PWM
  if(PWMEnable)
  {
    analogWrite(oer, rbright);
    analogWrite(oeg, gbright);
    analogWrite(oeb, bbright);  
  }
  else // Otherwise no PWM, full bright
  {
    digitalWrite(oer, LOW);
    digitalWrite(oeg, LOW);
    digitalWrite(oeb, LOW);
  }
}

void loop()
{
  Color_Wipe(1,0,0); // Red
  delay(1000);       // 1 Second Delay
  Color_Wipe(0,1,0); // Green
  delay(1000);       // 1 Second Delay
  Color_Wipe(0,0,1); // Blue
  delay(1000);       // 1 Second Delay
  Color_Wipe(0,1,1); // Aqua / Cyan
  delay(1000);       // 1 Second Delay
  Color_Wipe(1,1,0); // Yellow
  delay(1000);       // 1 Second Delay
  Color_Wipe(1,0,1); // Purple / Magenta
  delay(1000);       // 1 Second Delay
  Color_Wipe(0,0,0); // Black
  delay(1000);       // 1 Second Delay
  Color_Wipe(1,1,1); // White
  delay(1000);       // 1 Second Delay
}


void Color_Wipe(int r_value, int g_value, int b_value)
{
  // Wipes the display with the selected color
  // example for white. It clocks in all of the pixels
  // before latching the data.
  // Color_Wipe(1,1,1);

  // Clock in all pixels with fixed color
  // Pixels are not updated on the panel until data is latched below
  for (int count = 0; count < num_pixels; count++)
  {
    // We're going to clock in a pixel with each loop, we need to clock the data into 
    // the Red, Green and Blue Data lines individually
    // The clock line is currently low
    // Upper Half
    digitalWrite(datar1, r_value); // Color_Wipe(1,*,*) we write a 1, if Color_Wipe(0,*,*) we write a 0
    digitalWrite(datag1, g_value); // Color_Wipe(*,1,*) we write a 1, if Color_Wipe(*,0,*) we write a 0
    digitalWrite(datab1, b_value); // Color_Wipe(*,*,1) we write a 1, if Color_Wipe(*,*,0) we write a 0
    
    // Lower Half
    digitalWrite(datar2, r_value); // Color_Wipe(1,*,*) we write a 1, if Color_Wipe(0,*,*) we write a 0
    digitalWrite(datag2, g_value); // Color_Wipe(*,1,*) we write a 1, if Color_Wipe(*,0,*) we write a 0
    digitalWrite(datab2, b_value); // Color_Wipe(*,*,1) we write a 1, if Color_Wipe(*,*,0) we write a 0
    
    // Now we raise the clock high to clock in the data above
    digitalWrite(clock, HIGH); 
    
    // To finish clocking in the data, the chip datasheets says to bring the data lines low
    // then set the clock low, so we'll bring the data lines low.....
    
    // Upper Half
    digitalWrite(datar1, 0);
    digitalWrite(datag1, 0);
    digitalWrite(datab1, 0);
    
    // Lower Half
    digitalWrite(datar2, 0);
    digitalWrite(datag2, 0);
    digitalWrite(datab2, 0);

    // Complete the cycle by setting the clock low    
    digitalWrite(clock, LOW);    
    
    // A bit has now been shifted into the 6 RGB channels, we're setting the pixels
    // all to the same color, so this for loop will run (num_pixels) times before
    // dropping down below
  }
  
  // with the (numpixels) clocked into the panel(s) we now need to latch the data 
  // into the LED driver registers. Simple task. 
  digitalWrite(le, HIGH);      // Latch in 256 pixel data set
  digitalWrite(le, LOW);    
}
