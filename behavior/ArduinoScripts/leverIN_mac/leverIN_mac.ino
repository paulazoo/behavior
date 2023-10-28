#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int leverInput = A0;
const int tStart = 7;

int lever_raw;
int no_lever_raw = 0;
int lever_data;

void setup()
{
    // 115200 bits per s = 14400 bytes per s
    Serial.begin(115200);
}

void loop() {
    // lever_raw analog data =========================
    // readAnalog has a range of 0-1023, our lever sensor outputs 300 pulled back, to 700 pushed forward
    lever_raw = (int) ((micros()/10) % 10000); // lever_raw increases by 1 every 10 microseconds  and restarts at 10000 
    
    // tStart signal ==================================
    int tStartValue = digitalRead(tStart);
    if (tStartValue == LOW) {
        lever_data = lever_raw;
    }
    if (tStartValue == HIGH) {
        lever_data = lever_raw; // if lever_raw = 0, then trial has not started
    }

    // send data through serial port as 2 bytes =================
    Serial.write(lowByte(lever_data));
    Serial.write(highByte(lever_data));
}
