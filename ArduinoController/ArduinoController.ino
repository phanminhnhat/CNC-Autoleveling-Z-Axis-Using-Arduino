/*
  Detect zero for Z axis

  This code will detect port 2 on arduino when it change status from HIGH to LOW.
  Script will send a signal "Z0" via serial port. Software on Window will detect this "Z0" keyword to stop moving knife on MACH3 and set z to zero.
  https://www.facebook.com/npmlab/
  All right reserved
  by Nhat Phan Minh
 */


// the setup function runs once when you press reset or power the board
void setup() {
  Serial.begin(19200);
  // initialize digital pin 13 as an output.
  pinMode(13, OUTPUT);
  pinMode(2, INPUT_PULLUP);
}

// the loop function runs over and over again forever
void loop() {
  int sensorVal = digitalRead(2);
  //print out the value of the pushbutton
  // Keep in mind the pullup means the pushbutton's
  // logic is inverted. It goes HIGH when it's open,
  // and LOW when it's pressed. Turn on pin 13 when the
  // button's pressed, and off when it's not:
  if (sensorVal == HIGH) {
    digitalWrite(13, LOW);
  } else {
    digitalWrite(13, HIGH);
    Serial.println("Z0");
  }
}
