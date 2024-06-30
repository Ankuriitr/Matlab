/* This code is written by Ankur, DD Imaging Laboratory, Physics Department, IIT Roorkee.
 *  First version Date: 12/07/2020
    This code send commands to the arduino to control the stepper motor through serial port.
    It controls 3 stepper motors and the step size resolution.  upto 1/64 division per step.
    It get the instructions from the device from which we want to control the arduino ... like MATLAB.
    With support package of the matlab for arduino we can only run stepper motor using AdafruitMotorShield only.
    Also Matlab control for arduino is not fast(real-time).
*/
const int step_pin0 = 2;     //Stepper motor 1,2 For vertical motion.
const int dir_pin0 = 1;
const int step_pin1 = 4;     //Stepper motor 3, For rotational motion.
const int dir_pin1 = 3;
const int step_pin2 = 6;     // Stepper motor 4, For translation motion.
const int dir_pin2 = 5;
const int m0 = 7;            // To control the step size resolution.
const int m1 = 8;
const int m2 = 9;
const int nchar = 19;        // Here,to control the direction(1 char), # steps(4*3  char)and speed(same for all,4 char), #(3 for stepsize truthtable).
// For rotational motion, direcion is set to rotate only in 1-D. Total of 12 characters.
char received_Char[nchar];   // the array for received data
boolean newData = false;     // the indicator for new data, when new data arrives and receivedChar is filled, newData=true;

int dir = 0;                 // movement direction
int steps0=0;
int steps1 = 0;              // the number of steps
int steps2 = 0; 
int vert_steps = 0;          // the number of steps for vertical motion
int stepper_speed = 0;
char endMarker = '>';        // the end marker character

void setup() {
  Serial.begin(9600);
  pinMode(step_pin0, OUTPUT);
  pinMode(dir_pin0, OUTPUT);
  pinMode(step_pin1, OUTPUT);
  pinMode(dir_pin1, OUTPUT); // Here, we can add the arduino pins to which we want to send/receive data.
  pinMode(step_pin2, OUTPUT);
  pinMode(dir_pin2, OUTPUT);
}

void loop() {
  if (Serial.available() > 0) // If something appears on the serial port, run this
  {
    getdata();                 // fill in the array receivedChar
    execute();                 // set the variables "dir" and "distance", here you can enter your code for driving the stepper motor
    senddata();                // this is to confirm that the code is running properly, we send back to MATLAB (or to an Arduino Serial monitor) what was received
  }

}
void getdata()
{
  int index = 0; // this is the index for filling in "receivedChar", this variable does not need to be static, it can be a global variable...
  char rChar;    // received character, that is an output of Serial.read() function

  while (Serial.available() > 0 && newData == false)
  {
    rChar = Serial.read();        // Reading serial data.
    delay(2);
    if (rChar != endMarker && index <= (nchar - 1))
    {
      received_Char[index] = rChar;
      index++;
    }
    else
    {
      received_Char[index] = '\0'; // terminate the string
      index = 0;                   // reset the counter
      newData = true;              // set the "newData" indicator to true, meaning that the new data has arrived, and we can proceed further
    }
  }
}
void execute()
{
  // these two arrays are needed for the "atoi" function
  char tmp_dir[2];   // Stores the direction input
  char tmp_steps0[4]; // Stores the step input for vertical motion.
  char tmp_steps1[4]; // Stores the step input
  char tmp_steps2[4];
  char tmp_speed[3]; // Stores the speed input
  char step_res[2]; 
  char m[3];

  if (newData == true)
  {
    // Acquiring the direction, steps and speed which is stored in the string form in the recieved data.
    tmp_dir[0] = received_Char[0];
    tmp_dir[1] = '\0';
    dir = atoi(tmp_dir); //converts string to an integer,

    // Steps for 0th stepper (For Vertical Motion)
    for (int j = 0; j <= 3; j++)
    {
      tmp_steps0[j] = received_Char[j + 1];
    }
    tmp_steps0[4] = '\0';   //This is fifth index.. dont get confuse.
    steps0 = atoi(tmp_steps0);

    // Steps for Ist stepper (For rotation)
    for (int j = 0; j <= 3; j++)
    {
      tmp_steps1[j] = received_Char[j + 5];
    }
    tmp_steps1[4] = '\0';   //This is fifth index.. dont get confuse.
    steps1 = atoi(tmp_steps1);

    // Steps for IInd stepper (For translation)
    for (int k = 0; k <= 3; k++)
    {
      tmp_steps2[k] = received_Char[k + 9];
    }
    tmp_steps2[4] = '\0';
    steps2 = atoi(tmp_steps2);

    // To set speed for both steppers.
    for (int k = 0 ; k <= 3; k++)
    {
      tmp_speed[k] = received_Char[k + 12];
    }
    tmp_speed[4] = '\0';
    stepper_speed = atoi(tmp_speed);

    // To set speed for both steppers.
    for (int k = 0 ; k <= 2; k++)
    {
      m[k] = received_Char[k + 16];
    }
    m[3] = '\0';
    step_res[0] = atoi(m[0]);
    step_res[1] = atoi(m[1]);
    step_res[2] = atoi(m[2]);

    delay(1);
    newData = false;

// For vertical motion.
    if (steps0 > 0) {
      if (dir == 0)
      { digitalWrite(dir_pin0, LOW); // set direction, HIGH for clockwise, LOW for anticlockwise
      }
      if (dir == 1)
      { digitalWrite(dir_pin0, HIGH); // set direction, HIGH for clockwise, LOW for anticlockwise
      }
      for (int a = 0; a <= steps0; a++) { // loop for 200 steps
        digitalWrite(step_pin0, HIGH);
        delayMicroseconds(stepper_speed);
        digitalWrite(step_pin0, LOW);
        delayMicroseconds(stepper_speed);
        //        Serial.print(a);           //"Rotation # = %d",
        //        Serial.write('\r');
      }
    }
 // For rotational motion.  
    if (steps1 > 0) {
      if (dir == 0)
      { digitalWrite(dir_pin1, LOW); // set direction, HIGH for clockwise, LOW for anticlockwise
      }
      if (dir == 1)
      { digitalWrite(dir_pin1, HIGH); // set direction, HIGH for clockwise, LOW for anticlockwise
      }
      for (int a = 0; a <= steps1; a++) { // loop for 200 steps
        digitalWrite(step_pin1, HIGH);
        delayMicroseconds(stepper_speed);
        digitalWrite(step_pin1, LOW);
        delayMicroseconds(stepper_speed);
        //        Serial.print(a);           //"Rotation # = %d",
        //        Serial.write('\r');
      }
    }
    // Instructions to run stepper motor.
    //    digitalWrite(dirPin, HIGH); // set direction, HIGH for clockwise, LOW for anticlockwise
    if (steps2 > 0) {
      if (dir == 0)
      { digitalWrite(dir_pin2, LOW); // set direction, HIGH for clockwise, LOW for anticlockwise
      }
      if (dir == 1)
      { digitalWrite(dir_pin2, HIGH); // set direction, HIGH for clockwise, LOW for anticlockwise
      }

      for (int b = 0; b <= steps2; b++) { // loop for 200 steps
        digitalWrite(step_pin2, HIGH);
        delayMicroseconds(stepper_speed);
        digitalWrite(step_pin2, LOW);
        delayMicroseconds(stepper_speed);
        //        Serial.print(b);             // "Translation #  = %d",
        //        Serial.write('\r');
      }
    }

// To set step resolution.
  if (step_res[0]==1){
    digitalWrite(m0,HIGH);
  }
  else
  {
    digitalWrite(m0,LOW);
  }
  if (step_res[1]==1){
    digitalWrite(m1,HIGH);
  }
  else
  {
    digitalWrite(m1,LOW);
  }  
  if (step_res[2]==1){
    digitalWrite(m2,HIGH);
  }
  else
  {
    digitalWrite(m2,LOW);
  }

//  Serial.print(step_res[0],'%d ');//,steps0,steps1,\t %d \t %d
//  Serial.print(step_res[1],'%d ');
//  Serial.println(step_res[2],'%d ');
//  Serial.println(steps0,'%d ');
//  Serial.println(steps1,'%d ');
//  for(int i=0;i<20;i++){
//    Serial.print(received_Char[i],'%s');
//  }
//  
    delay(1); // delay for 1 millisecond
    // to free the buffer  (if something is still there)
    while (Serial.available() > 0)
    {
      Serial.read();
    }

  }
}
void senddata()
{
  //Serial.print(steps2);          //"Rotation # = %d",

  //Serial.println(dir); // send back the direction, the number can be read from the Serial Monitor, or from MATLAB
  Serial.write('\r');    // this is the 'CR' terminator for MATLAB, see the MATLAB code
}
