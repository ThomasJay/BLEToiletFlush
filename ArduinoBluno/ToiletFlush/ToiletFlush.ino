#include <PlainProtocol.h>

#include <avr/pgmspace.h>
#include <Wire.h>
#include "Arduino.h"
#include "PlainProtocol.h"

#define INFlushPin 5

int flushes = 0;


PlainProtocol BLUNOPlainProtocol(Serial,115200);


const char deviceInformation[] PROGMEM  = {"default info"};

void setup() {

  Serial.println("Setup Started");
  

  Serial.begin(115200);
  TCCR1B &= ~((1<<CS12)|(1<<CS11)|(1<<CS10));  //Clock select: SYSCLK divde 8;
  TCCR1B |= (1<<CS11);
  TCCR2B &= ~((1<<CS12)|(1<<CS11)|(1<<CS10)); //Clock select: SYSCLK divde 8;
  TCCR2B |= (1<<CS11);


  pinMode(INFlushPin, INPUT);
 
  delay(200);

  Serial.println("Setup Completed BC");

  flushes = 0;

  
}





void loop()
{


  if (BLUNOPlainProtocol.available()) {

       if (BLUNOPlainProtocol.receivedCommand=="STATUS"){

        delay(500);
        BLUNOPlainProtocol.write("FLUSHES", flushes);
    }

  }

  int currentInputValue = digitalRead(INFlushPin);

   // If its high, wait then check again
  if (currentInputValue & 1) {

    delay(2);

    currentInputValue = digitalRead(INFlushPin);

    // If still high, coutn this was a flush
    if (currentInputValue & 1) {
       

       // Wait until flush is done
       while (1) {
         delay(10);

          currentInputValue = digitalRead(INFlushPin);
          if (currentInputValue == 0) {
             flushes++;

             delay(500);
             BLUNOPlainProtocol.write("FLUSHES", flushes);

             break;
          }
       }
    }
    
  }
  



}


