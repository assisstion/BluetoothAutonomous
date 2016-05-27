
#include <SPI.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include <SoftwareSerial.h>
#define rxPin 3  // pin 3 connects to smcSerial TX  (not used in this example)
#define txPin 4  // pin 4 connects to smcSerial RX
SoftwareSerial smcSerial = SoftwareSerial(rxPin, txPin);
 
// required to allow motors to move
// must be called when controller restarts and after any error
void exitSafeStart()
{
  smcSerial.write(0x83);
}

// speed should be a number from -3200 to 3200
void setMotorSpeed(int speed)
{
  if (speed < 0)
  {
    smcSerial.write(0x86);  // motor reverse command
    speed = -speed;  // make speed positive
  }
  else
  {
    smcSerial.write(0x85);  // motor forward command
  }
  smcSerial.write(speed & 0x1F);
  smcSerial.write(speed >> 5);
}


//int forwardsPin = 5;
//int backwardsPin = 10;

//The speed of the servos
double leftSpeed = 0;
double rightSpeed = 0;

//Based on https://github.com/scottCheezem/BlueRCSketch/blob/LED_example/BleRC.ino

void setup() {
  
  //Setup the Serial Peripheral Interface
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.begin();

  //Begins scanning for bluetooth
  ble_begin();
  
  //pinMode(forwardsPin, OUTPUT);
  //pinMode(backwardsPin, OUTPUT);

  //Begins running the serial port on 57600 bits per second
  Serial.begin(57600);
  Serial.println("start");
  
  // initialize software serial object with baud rate of 19.2 kbps
  smcSerial.begin(19200);
 
  // the Simple Motor Controller must be running for at least 1 ms
  // before we try to send serial data, so we delay here for 5 ms
  delay(100);
 
  // if the Simple Motor Controller has automatic baud detection
  // enabled, we first need to send it the byte 0xAA (170 in decimal)
  // so that it can learn the baud rate
  smcSerial.write(0xAA);  // send baud-indicator byte
 
  // next we need to send the Exit Safe Start command, which
  // clears the safe-start violation and lets the motor run
  exitSafeStart();  // clear the safe-start violation and let the motor run
}

void motorWrite(double value){//int forwards, int backwards, int value){
  /*if(value > 0){
    analogWrite(forwards, value);
    analogWrite(backwards, 0);   
  }
  else if(value < 0){
    analogWrite(forwards, 0);
    analogWrite(backwards, -value);
  }
  else{
    analogWrite(forwards, 0);
    analogWrite(backwards, 0);
  }*/
  int outspeed = (int)(3200*value);
  //Serial.println(value);
  if(outspeed > 3200 || outspeed < -3200){
    return;
  }
  setMotorSpeed(outspeed);  // full-speed forward
}


void loop() {
  
  //Read bluetooth data as long as there is remaining unread data
  while(ble_available()){
    
    //The bytes of data for the left and right motors
    byte left;
    byte right;
    byte option;
    
    //If the data is present
    if(right = ble_read()){
      //Read the right and left motor data
      left = ble_read();
      option = ble_read();
      
      //Prints the data
      Serial.print(left);
      Serial.print(", ");
      Serial.print(right);
      Serial.print(", ");
      Serial.print(option);
      Serial.print("\n");

      if(option == 0){
        //Converts the left and right speed from the bytes sent
        leftSpeed = byteToSpeed(left);
        rightSpeed = byteToSpeed(right);
      }
      else if(option == 1){
        setMotorSpeed(0);  // full-speed forward
        exitSafeStart();
        delay(1);
      }
    }  
  }
    
  Serial.print("p");
  Serial.print(leftSpeed);
  Serial.print(", ");
  Serial.print(rightSpeed);
  Serial.print("\n");
  
    
  //Writes the left speed to the servo, converting from speed to servo value
  //motorWrite(forwardsPin, backwardsPin, speedToMotorValue((leftSpeed+rightSpeed)/2.0)); 
  motorWrite((leftSpeed+rightSpeed)/2.0); 
  delay(1);
  // Allow BLE Shield to send/receive data
  ble_do_events();
}

//Converts the byte read from bluetooth to the servo speed 
double byteToSpeed(byte value){
  return (value - 128) / 127.0;
}

//Converting from -1 to 1 (speed) -> 0 to 180 (servo value)
int speedToMotorValue(double value){
  return (int)(value * 255.0);
}
