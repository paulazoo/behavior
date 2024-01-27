#include <SPI.h>

const int leverInput = A0;
int lickSpout = 2;

void setup()
{
  Serial.begin(19200);
 
  pinMode(lickSpout, INPUT);
  pinMode(A0, INPUT);
}
 
 
void loop() {
  // readAnalog has a range of 0-1023
  // our lever sensor outputs ~300 pulled back to ~700 pushed forward, ~550 when neutral
  int lever_raw = analogRead(leverInput);
 
  // licks
  int lick_raw = digitalRead(lickSpout);
 
  // send data through serial port =================
  Serial.write((byte) (lever_raw)); // byte 1
  Serial.write((byte) (lever_raw>>8)); // byte 2
  Serial.write((byte) (lick_raw)); // byte 3

  // send Terminator (CR) for fscanf() function on MATLAB side
  Serial.println('k'); // bytes 4 and 5
 
  delay(2);
}
