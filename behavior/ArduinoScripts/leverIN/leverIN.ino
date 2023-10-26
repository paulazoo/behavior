#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int leverInput = A0;
const int tStart = 7;

unsigned long time = 0;
unsigned char time_buf[4];
int lever_raw;

void setup()
{
    Serial.begin(115200); // 115 bits per ms = about 10 bytes per ms, 100 bytes per 10 ms
}

void loop() {
    // tStart signal and Time ==================================
    int tStartValue = digitalRead(tStart);
    if (tStartValue == HIGH) {
        time = millis();
    } else {
        time = 0; // if time = 0, then trial has not started
    }
    // print time since program started in milliseconds (4 bytes for unsigned long)
    time_buf[0] = (time & 0x000000FF);
    time_buf[1] = (time & 0x0000FF00) >> 8;
    time_buf[2] = (time & 0x00FF0000) >> 16;
    time_buf[3] = (time & 0xFF000000) >> 24;
    Serial.write(time_buf[0]);
    Serial.write(time_buf[1]);
    Serial.write(time_buf[2]);
    Serial.write(time_buf[3]);

    //  Analog lever ==========================
    // readAnalog has a range of 0-1023, our lever sensor outputs 300 pulled back, to 700 pushed forward
    int lever_raw = analogRead(leverInput);
    Serial.write(lowByte(lever_raw));
    Serial.write(highByte(lever_raw));
}

