// digital pin 2 and 4 has lickspouts attached to it. Give it a name:
int AirRight = 2;
int AirLeft = 4;
int WaterRight = 1;
int WaterLeft = 7;
int LED = 8;
int val = 0;
int TStart = 11;
int THit = 7;
int Laser = 10;

void setup() {

    // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  // make the lickspout's pin an input:
  pinMode(AirRight, OUTPUT);
  pinMode(AirLeft, OUTPUT);
  pinMode(WaterRight, OUTPUT);
  pinMode(WaterLeft, OUTPUT);
  pinMode(LED, OUTPUT);
  pinMode(TStart, OUTPUT);
  pinMode(THit, OUTPUT);
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
      digitalWrite(WaterRight, HIGH); 
      break;
      
     case 'E':
      digitalWrite(WaterLeft, HIGH);
      digitalWrite(THit,HIGH);
      break;
      
     case 'O':
      digitalWrite(WaterRight, LOW);
      digitalWrite(WaterLeft, LOW);
      digitalWrite(THit,LOW);
      break;
      
     case 'L':
      digitalWrite(AirLeft, HIGH);
      break;
      
     case 'M':
      digitalWrite(AirLeft, LOW);
      break;
      
     case 'R':
      digitalWrite(AirRight, HIGH);
      break;
      
     case 'S':
      digitalWrite(AirRight, LOW);
      break;
      
     case 'I':
      digitalWrite(LED, HIGH);
      digitalWrite(TStart,LOW);
      break;
      
     case 'J':
      digitalWrite(LED, LOW);
      digitalWrite(TStart,HIGH); // When LED goes off it is the begining of a trial
      break;
      
     case 'A':
      digitalWrite(Laser,HIGH);
      digitalWrite(Laser,LOW);
      break;
    }
  }
}
