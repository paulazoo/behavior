#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int levInput = A0;
unsigned long time;
 
void setup()
{
  Serial.begin(19200);
}

void loop() {
  //  Read lever convert it to two bytes
  int levRaw = analogRead(levInput);
  char levChar1 = (levRaw - (levRaw % 255)) / 255;
  char levChar2;
  if (levRaw % 255 == 10) {
    levChar2 = 11; //Correct for line feed bytes
  }
  else if (levRaw % 255 == 13) {
    levChar2 = 14; //Correct for carriage return bytes
  }
  else {
    levChar2 = levRaw % 255;
 }
 
  time = micros();
  Serial.println(time); // prints time since program started

  Serial.println(levChar1); // prints the lever output
  Serial.print(levChar2);

}