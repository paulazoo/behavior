#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int leverInput = A0;
const int tStart = 7;

int lever_raw;

void setup()
{
    Serial.begin(115200); // 115 bits per ms = about 10 bytes per ms, 100 bytes per 10 ms
}

void loop() {
    // tStart signal ==================================
    int tStartValue = digitalRead(tStart);
    if (tStartValue == HIGH) {
        // readAnalog has a range of 0-1023, our lever sensor outputs 300 pulled back, to 700 pushed forward
        lever_raw = analogRead(leverInput);
    } else {
        lever_raw = 0; // if lever_raw = 0, then trial has not started
    }

    Serial.write(lowByte(lever_raw));
    Serial.write(highByte(lever_raw));
}
