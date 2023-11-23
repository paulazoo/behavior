// digital pin 2 and 4 has lickspouts attached to it. Give it a name:
int Air = 4;
int Water = 7;
int val = 0;
int TStart = 11;
int yellowLED = 8;
int Laser = 10;

void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  // make the lickspout's pin an input:
  pinMode(Air, OUTPUT);
  pinMode(Water, OUTPUT);
  pinMode(TStart, OUTPUT);
  pinMode(yellowLED, OUTPUT);
  pinMode(Laser, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  while (Serial.available() == 0)
  {
  }
  
  if (Serial.available() > 0)
  {
   val = Serial.read();
   switch (val){
     case 'W':
      digitalWrite(Water,HIGH);
      break;
      
     case 'X':
      digitalWrite(Water,LOW);
      break;
      
     case 'A':
      digitalWrite(Air, HIGH);
      break;
      
     case 'B':
      digitalWrite(Air,LOW);
      break;
      
     case 'I':
      digitalWrite(TStart,LOW);
      digitalWrite(yellowLED,HIGH);
      break;
      
     case 'J':
      digitalWrite(TStart,HIGH);
      digitalWrite(yellowLED,LOW);
      break;
      
     case 'L':
      digitalWrite(Laser,HIGH);
      digitalWrite(Laser,LOW);
      break;
    }
  }
}
