#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int levInput = A0;
const int xInput = A3;
const int yInput = A4;
const int zInput = A5;
int lickSpout1 = 2;
int lickSpout2 = 4;
int baseX = 0;
int baseY = 0;
int baseZ = 0;
const int sampleSize = 200; // Take multiple samples to calculate base value
 
void setup()
{
//  analogReference(EXTERNAL);
  Serial.begin(19200);
 
  // make the lickspout's pin an input:
  pinMode(lickSpout1, INPUT);
  pinMode(lickSpout2, INPUT);
 
  //  Calculate the baseline value to adjust range of accelerometer data from 0..255
  baseX = ReadAxis(xInput) - round(255 / 2);
  baseY = ReadAxis(yInput) - round(255 / 2);
  baseZ = ReadAxis(zInput) - round(255 / 2);
}
 
 
void loop() {
 
 
  // Read each spout cover it to (00 01 10 11)+100 to avoid char = 10
  int lick1 = digitalRead(lickSpout1);
  int lick2 = digitalRead(lickSpout2);
  char lickChar = (10 * lick1 + lick2) + 100;
 
  // Read accelerator data and convert
  int xRaw = analogRead(xInput) - baseX;
  int yRaw = analogRead(yInput) - baseY;
  int zRaw = analogRead(zInput) - baseZ;
  char xChar = convertAccRead(xRaw);
  char yChar = convertAccRead(yRaw);
  char zChar = convertAccRead(zRaw);
 
  //  Read lever convert it to two bytes
    int levRaw = analogRead(levInput);
//  int levRaw = xRaw;
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
 
  Serial.print(levChar1);
  Serial.print(levChar2);
  Serial.print(lickChar);
  Serial.print(xChar);
  Serial.print(yChar);
  Serial.println(zChar);
 
    delay(2);
}
 
//
// Make sure the analog read of accelerator is within the 0..255 limit and output as a ASCII character
//
char convertAccRead(int val)
{
  if (val < 0) {
    val = 0;
  }
  if (val > 255) {
    val = 255;
  }
  if (val == 10) {
    val = 11; // avoid char = 10
  }
  if (val == 13) {
    val = 14; // avoid char = 13
  }
 
  char convertedVal = val;
  return convertedVal;
}
 
//
// Read "sampleSize" samples and report the average
//
int ReadAxis(int axisPin)
{
  long reading = 0;
  analogRead(axisPin);
  delay(1);
  for (int i = 0; i < sampleSize; i++)
  {
    reading += analogRead(axisPin);
  }
  return reading / sampleSize;
}
