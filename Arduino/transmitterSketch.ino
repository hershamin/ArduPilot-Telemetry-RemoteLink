#include <LiquidCrystal.h>
#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

// LCD
int Contrast=15;
int Backlight=28836;
LiquidCrystal lcd(A0,A1,A2,A3,A4,A5);
//String currentStatus;
String inData;

// the setup routine runs once when you press reset:
void setup() {                
  // Set LCD
  pinMode(A0,OUTPUT);
  pinMode(A1,OUTPUT);
  pinMode(A2,OUTPUT);
  pinMode(A3,OUTPUT);
  pinMode(A4,OUTPUT);
  pinMode(A5,OUTPUT);
  analogWrite(6,Contrast);
  analogWrite(9,Backlight);
  lcd.begin(16,2);
  lcd.print("RPY Telemetry...");
  lcd.setCursor(0,1);
  lcd.print("Waiting...");
  
  // Set serial
  Serial.begin(4800);
  
  // Set radio
  Mirf.spi = &MirfHardwareSpi;
  Mirf.init();
  Mirf.payload = 1;
  Mirf.config();
  Mirf.configRegister(RF_SETUP,0x06);
}

// the loop routine runs over and over again forever:
void loop() {
   while (Serial.available() > 0) {
    char received = Serial.read();
    
    // Update LCD
    /*if (currentStatus != "Transmitting...") {
      lcd.setCursor(0,1);
      lcd.print("                ");
      lcd.setCursor(0,1);
      lcd.print("Transmitting...");
      currentStatus = "Transmitting...";
    }*/
    
    // process message when new line character is received
    if (received == '\n') {
      // Send to LCD
      lcd.setCursor(0,1);
      lcd.print("                ");
      lcd.setCursor(0,1);
      lcd.print(inData);
      // Send to Radio
      Mirf.setTADDR((byte*)"serv1");
      byte c = received;
      Mirf.send(&c);
      while (Mirf.isSending());
      // Clear buffer
      inData = "";
    } else {
      // Append Data
      inData += received;
      // Send to Radio
      Mirf.setTADDR((byte*)"serv1");
      byte c = received;
      Mirf.send(&c);
      while (Mirf.isSending());
    }
  }
  delay(10);
  /*if (currentStatus != "Waiting...") {
    lcd.setCursor(0,1);
    lcd.print("                ");
    lcd.setCursor(0,1);
    lcd.print("Waiting...");
    currentStatus = "Waiting...";
  }*/
}
