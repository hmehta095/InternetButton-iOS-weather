// This #include statement was automatically added by the Particle IDE.
#include <InternetButton.h>

InternetButton button = InternetButton();
int DELAY = 200;
void setup() {
 button.begin();


Particle.function("hour",hours);
Particle.function("min",minute);
Particle.function("sec",second);
Particle.function("precep",preceps);
Particle.function("temp",temps);


    for(int i=0;i<3;i++){
    button.allLedsOn(200,0,0);
    delay(500);
    button.allLedsOff();  
    delay(500);
    }
}



int  preceps(String cmd){
     button.allLedsOff();  
    int per = cmd.toInt();
    int light = per/9.09;
    for(int i =1 ; i <= light+1; i++){
      button.ledOn(i,25,25,0);  
    }
    delay(2000);
    button.allLedsOff(); 
    
}


int temps(String cmd){
    button.allLedsOff();
    int temp = cmd.toInt();
    int light = temp/(28*5);
    
    for(int i =1 ; i <= light; i++){
      button.ledOn(i,25,0,25);  
    }
    delay(2000);
    button.allLedsOff(); 
    
   
}




int hours(String cmd){
    int hr = cmd.toInt();
    // button.allLedsOff();
    
    if(hr == 1 || hr == 13){
      button.ledOff(12);  
      button.ledOn(1,25,0,0);   
    }
    if(hr == 2 || hr == 14){
      button.ledOff(1);  
      button.ledOn(2,25,0,0);   
    }
    if(hr == 3 || hr == 15){
      button.ledOff(2);  
      button.ledOn(3,25,0,0);   
    }
    if(hr == 4 || hr == 16){
      button.ledOff(3);  
      button.ledOn(4,25,0,0);   
    }
    if(hr == 5 || hr == 17){
      button.ledOff(4);  
      button.ledOn(5,25,0,0);   
    }
    if(hr == 6 || hr == 18){
      button.ledOff(5);  
      button.ledOn(6,25,0,0);   
    }
    if(hr == 7 || hr == 19){
      button.ledOff(6);  
      button.ledOn(7,25,0,0);   
    }
    if(hr == 8 || hr == 20){
      button.ledOff(7);  
      button.ledOn(8,25,0,0);   
    }
    if(hr == 9 || hr == 21){
      button.ledOff(8);  
      button.ledOn(9,25,0,0);   
    }
    if(hr == 10 || hr == 22){
      button.ledOff(9);  
      button.ledOn(10,25,0,0);   
    }
    if(hr == 11 || hr == 23){
      button.ledOff(10);  
      button.ledOn(11,25,0,0);   
    }
    if(hr == 12 || hr == 24){
      button.ledOff(11);  
      button.ledOn(12,25,0,0);   
    }
    
    
    
    
    
    // if(hr > 12){
    //   int y = hr - 12;
    //   button.ledOn(y,255,0,0); 
    // }else{
    //   button.ledOn(hr,255,0,0);  
    // }
    
    



   
}
int minute(String cmd){
    int min = cmd.toInt();
    // button.allLedsOff();
    if(min>0 && min<6){
        button.ledOff(11);
      button.ledOn(1,0,25,0);  
    }
    if(min>5 && min<11){
        button.ledOff(1);
      button.ledOn(2,0,25,0);  
    }
    if(min>10 && min<16){
         button.ledOff(2);
      button.ledOn(3,0,25,0);  
    }
    if(min>15 && min<21){
        button.ledOff(3);
      button.ledOn(4,0,25,0);  
    }
    if(min>20 && min<26){
        button.ledOff(4);
      button.ledOn(5,0,25,0);  
    }
    if(min>25 && min<31){
        button.ledOff(5);
      button.ledOn(6,0,25,0);  
    }
    if(min>30 && min<36){
        button.ledOff(6);
      button.ledOn(7,0,25,0);  
    }
    if(min>35 && min<41){
        button.ledOff(7);
      button.ledOn(8,0,25,0);  
    }
    if(min>40 && min<46){
        button.ledOff(8);
      button.ledOn(9,0,25,0);  
    }
    if(min>45 && min<51){
        button.ledOff(9);
      button.ledOn(10,0,25,0);  
    }
    if(min>50 && min<56){
        button.ledOff(10);
      button.ledOn(11,0,25,0);  
    }
    if(min>55 && min<61){
        button.ledOff(11);
      button.ledOn(12,0,25,0);  
    }
    

}
int second(String cmd){
    int sec = cmd.toInt();
    if(sec>0 && sec<6){
        button.ledOff(11);
      button.ledOn(1,0,0,20);  
    }
    if(sec>5 && sec<11){
        button.ledOff(1);
      button.ledOn(2,0,0,20);  
    }
    if(sec>10 && sec<16){
         button.ledOff(2);
      button.ledOn(3,0,0,20);  
    }
    if(sec>15 && sec<21){
        button.ledOff(3);
      button.ledOn(4,0,0,20);  
    }
    if(sec>20 && sec<26){
        button.ledOff(4);
      button.ledOn(5,0,0,20);  
    }
    if(sec>25 && sec<31){
        button.ledOff(5);
      button.ledOn(6,0,0,20);  
    }
    if(sec>30 && sec<36){
        button.ledOff(6);
      button.ledOn(7,0,0,20);  
    }
    if(sec>35 && sec<41){
        button.ledOff(7);
      button.ledOn(8,0,0,20);  
    }
    if(sec>40 && sec<46){
        button.ledOff(8);
      button.ledOn(9,0,0,20);  
    }
    if(sec>45 && sec<51){
        button.ledOff(9);
      button.ledOn(10,0,0,20);  
    }
    if(sec>50 && sec<56){
        button.ledOff(10);
      button.ledOn(11,0,0,20);  
    }
    if(sec>55 && sec<61){
        button.ledOff(11);
      button.ledOn(12,0,0,20);  
    }
   
}



void loop() {
 
 
  if(button.buttonOn(4)){
      // choice A
      Particle.publish("playerChoice","A",60,PRIVATE);
      delay(DELAY);
  }
  if(button.buttonOn(2)){
      //choice B
      Particle.publish("playerChoice","B",60,PRIVATE);
      delay(DELAY);
  }
  if(button.buttonOn(3)){
      //Next question
      Particle.publish("playerChoice","true",60,PRIVATE);
      delay(DELAY);
  }
  if(button.buttonOn(1)){
     
      Particle.publish("playerChoice","C",60,PRIVATE);
      delay(DELAY);
  }



}
