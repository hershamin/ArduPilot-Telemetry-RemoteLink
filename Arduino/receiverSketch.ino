#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

String inData;

// the setup routine runs once when you press reset:
void setup() {
  // Set serial
  Serial.begin(4800);
  
  // Set radio
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.setRADDR((byte*)"serv1");
  Mirf.payload = 1;
  Mirf.config();
  Mirf.configRegister(RF_SETUP,0x06);
}

// the loop routine runs over and over again forever:
void loop() {
  Serial.println("TSET RPY!");
  byte c;
  if (Mirf.dataReady()) {
    Mirf.getData(&c);
    char ch = c;
    
    // process when new line character is received
    if (ch == '\n') {
      // Send to serial
      Serial.println(inData);
      // Clear Buffer
      inData = "";
    } else {
      // Append Data
      inData += ch;
    }
  }
}
