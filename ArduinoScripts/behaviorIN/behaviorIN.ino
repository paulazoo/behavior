/*
  DigitalReadSerial

  Reads a digital input on pin 2 and 4, prints the result to the Serial Monitor


*/

// digital pin 2 and 4 has lickspouts attached to it. Give it a name:
int lickSpout1 = 2;
int lickSpout2 = 4;
int val = 0; // Value read from MATLAB
//long time = 0;
int leverValue = 0;
int lick1 = 0;
int lick2 = 0;
// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  // make the lickspout's pin an input:
  pinMode(lickSpout1, INPUT);
  pinMode(lickSpout2, INPUT);
}

// the loop routine runs over and over again forever:
void loop() {

    leverValue = analogRead(A0);
    lick1 = digitalRead(lickSpout1);
    lick2 = digitalRead(lickSpout2);
    // print out lever and lick spouts:
    String str = String('X'+String(leverValue)+String(lick1)+String(lick2));
    //Serial.print(leverValue);
    //Serial.print(lick1);
    Serial.println(str);

}
