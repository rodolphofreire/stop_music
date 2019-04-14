#include <Ultrasonic.h>
#include <SoftwareSerial.h>
#include <LiquidCrystal.h>

#define pino_trigger 4
#define pino_echo 5
#define pino_led 6
#define wake_up_distance 15.0
#define bt_tx 2
#define bt_rx 3
#define lcd_rs 12
#define lcd_enable 11
#define lcd_d4 10
#define lcd_d5 9
#define lcd_d6 8
#define lcd_d7 7
#define lcd_col 16
#define lcd_line 2


bool is_Stopped = false;
bool is_Holding = false;
bool is_suspended = false;

Ultrasonic ultrasonic(pino_trigger, pino_echo);
SoftwareSerial bluetooth(bt_tx, bt_rx);
LiquidCrystal lcd(lcd_rs, lcd_enable, lcd_d4, lcd_d5, lcd_d6, lcd_d7);

void setup() {
  Serial.begin(9600);
  pinMode(pino_led, OUTPUT);
  bluetooth.begin(9600);
  lcd.begin(lcd_col, lcd_line);
}

void loop() {

  float cm_msec;
  long microsec = ultrasonic.timing();
  cm_msec = ultrasonic.convert(microsec, Ultrasonic::CM);
  if(cm_msec <= wake_up_distance && is_Holding==false) {
    is_Stopped = !is_Stopped && !is_suspended;
    is_Holding = true; 
  } else if (cm_msec > wake_up_distance) {
    is_Holding = false;
  }

  if(is_Stopped) {
    bluetooth.println("music_stop");
    digitalWrite(pino_led, HIGH);
    // lcd.setCursor(0, 0);
    // lcd.print("MUSIC STOPPED");
  }else{
    bluetooth.println("music_play");
    digitalWrite(pino_led, LOW);
    // lcd.setCursor(0, 0);
    // lcd.print("PLAYING MUSIC");
  }

  if (bluetooth.available()) {
    delay(100);
    lcd.clear();
    String readString = "";
    while (bluetooth.available() > 0) {
      char c = bluetooth.read();
      if( c >= 32 && c <= 126){
        readString += c;
      }
    }
    if( readString == "CMD:ON" ){
      is_suspended = false;
    }else if( readString == "CMD:OFF" ){
      is_suspended = true;
    }else{
      lcd.print(readString);
    }
    
  }
 
  delay(600);
}
