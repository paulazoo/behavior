#include <SPI.h> // https://www.arduino.cc/reference/en/language/functions/communication/spi/

const int leverInput = A1;

int lever_data = 0;

void setup()
{
    // 115200 bits per s = 14400 bytes per s
    Serial.begin(115200);
    pinMode(A1, INPUT);
}

void loop() {
    // lever_raw analog data =========================
    // readAnalog has a range of 0-1023
    // our lever sensor outputs ~300 pulled back to ~700 pushed forward, ~550 when neutral
    int lever_raw = analogRead(leverInput);
    lever_data = (int) (lever_raw);

    // send data through serial port as 2 bytes =================
    Serial.write((byte) (lever_data>>8));
    Serial.write((byte) (lever_data));
    //Serial.println(lever_raw);
}
