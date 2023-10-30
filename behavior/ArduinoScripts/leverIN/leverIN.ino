#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int leverInput = A0;
const int tStart = 7;

int lever_data = 0;

void setup()
{
    // 115200 bits per s = 14400 bytes per s
    Serial.begin(115200);
    pinMode(7, INPUT);
    pinMode(A0, INPUT);
}

void loop() {
    // lever_raw analog data =========================
    // readAnalog has a range of 0-1023
    // our lever sensor outputs ~300 pulled back to ~700 pushed forward, ~550 when neutral
    int lever_raw = analogRead(leverInput);
    
    // tStart signal ==================================
    if (digitalRead(tStart) == LOW) {
        lever_data = (int) (lever_raw + 2000); // if lever_raw > 2000, then trial has not started
    } else {
        lever_data = (int) lever_raw; // if lever_raw = 0, then trial has not started
    }

00    // send data through serial port as 2 bytes =================
    Serial.write(lowByte(lever_data));
    Serial.write(highByte(lever_data));
}
