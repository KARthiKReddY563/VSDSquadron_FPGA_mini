unsigned long lastDebugTime = 0;

void setup() {
  Serial.begin(9600);
  Serial.println("UART Receiver Started");
}

bool newLine = false;
String receivedValue = "";
void loop() {
  // Check if data is available
  while (Serial.available() > 0) {
   while (Serial.available() > 0) {
    char incomingByte = Serial.read();
    
    // If it's a newline character, process the complete number
    if (incomingByte == '\n' || incomingByte == '\r' ) {
      if (receivedValue.length() > 0 && !newLine) {
        Serial.print("Distance: ");
        Serial.print(receivedValue.toInt()); // Convert string to integer
        Serial.println(" cm");
        receivedValue = "";
        newLine = true;
        
      }
    } 
    else {
      
        receivedValue += incomingByte;
      newLine = false;
      
    }
  }

  
  delay(100);
}
}

