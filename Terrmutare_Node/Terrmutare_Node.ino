#include <ESP8266WiFi.h>
#include <WiFiUDP.h>

// wifi connection variables
//const char* ssid = "TelevisaTeIdiotiza";
//const char* password = "5554402768";

const char* ssid = "AXTEL-1722";
const char* password = "C3121722";


boolean wifiConnected = false;
boolean confirmado = false;

//Direccion de l servidor
char* remoto = "192.168.15.39";
char* remoto2 = "192.168.1.90";


boolean mandado = false;
// UDP variables
unsigned int localPort = 6000;
unsigned int hostPort = 12000;

int cuenta = 0;



WiFiUDP UDP;
boolean udpConnected = false;
char packetBuffer[UDP_TX_PACKET_MAX_SIZE]; //buffer to hold incoming packet,
char ReplyBuffer[] = "acknowledged"; // a string to send back

char resultado[] = "0";


/*
  para leer el valor del sensor
*/
int salida;
int entradaSensor;
int btn;
int val;
char* ping;
int redpin=1;

int boton = 5;
int puertoSensor = 0;

boolean prendido = false;
boolean prendidoAnterior = false;
boolean ordenRemota = false;

/* PAra en sensor de distancia*/
long distancia;
long tiempo;
int puertoTrigger = 15;
int puertoEcho = 4;

unsigned long tiempo, tiempoRef, tiempoMax;

void setup() {
  // Initialise Serial connection
  Serial.begin(115200);
  
  // pinMode(puertoTrigger, OUTPUT); /*activación del pin 9 como salida: para el pulso ultrasónico*/
  // pinMode(puertoEcho, INPUT); /*activación del pin 8 como entrada: tiempo del rebote del ultrasonido*/
  //Serial.println("******* Prueba de sensor *********");
  //return;
  pinMode(redpin,OUTPUT);
  pinMode(puertoSensor, INPUT);
  pinMode(boton, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  // Initialise wifi connection
  wifiConnected = connectWifi();
  
  // only proceed if wifi connection successful
  if(wifiConnected){
    udpConnected = connectUDP();
    if (udpConnected){
      // initialise pins
      pinMode(LED_BUILTIN,OUTPUT);
    }
  }
  tiempoMax = 1500;
  tiempoRef =  millis();
}

void loop() {
  //leerSensor();
  //return;
  btn = digitalRead(boton);
  entradaSensor =  analogRead(puertoSensor);

  Serial.println("******* Sensor *********");
  Serial.println(entradaSensor);
  Serial.println("************************");

  prendido =  btn == HIGH;

  if( prendido  != prendidoAnterior ){
    mandar( prendido ? 1 : 0);
  }
   
  prendidoAnterior = prendido;
  
  recibirUDP();

  if( ordenRemota ){
    salida = HIGH;
  }else{
    salida = !prendido ? HIGH : LOW;
  }
  
  digitalWrite( LED_BUILTIN, salida ); 


  if( !confirmado){
    tiempo = millis() - tiempoRef;
    if( tiempo > tiempoMax){
      mandar(2);
    }
  }
}

void leerSensor(){
  
  digitalWrite(puertoTrigger,LOW); /* Por cuestión de estabilización del sensor*/
  delayMicroseconds(5);
  digitalWrite(puertoTrigger, HIGH); /* envío del pulso ultrasónico*/
  delayMicroseconds(10);
  
  tiempo=pulseIn(puertoEcho, HIGH); /* Función para medir la longitud del pulso entrante. Mide el tiempo que transcurrido entre el envío
  del pulso ultrasónico y cuando el sensor recibe el rebote, es decir: desde que el pin 12 empieza a recibir el rebote, HIGH, hasta que
  deja de hacerlo, LOW, la longitud del pulso entrante*/
  distancia= int(0.017*tiempo); /*fórmula para calcular la distancia obteniendo un valor entero*/
  /*Monitorización en centímetros por el monitor serial*/
  Serial.println("Distancia ");
  Serial.println(tiempo);
  Serial.println(" cm");
  delay(1000);
}

void recibirUDP(){
  
  if(wifiConnected){
    if(udpConnected){
    
    // if there’s data available, read a packet
    int packetSize = UDP.parsePacket();
    if(packetSize)
    {
      Serial.println("");
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      Serial.print("From ");
      IPAddress remote = UDP.remoteIP();
      for (int i =0; i < 4; i++)
      {
        Serial.print(remote[i], DEC);
        if (i < 3)
        {
        Serial.print(".");
        }
      }
      Serial.print(", port ");
      Serial.println(UDP.remotePort());
      
      // read the packet into packetBufffer
      UDP.read(packetBuffer,UDP_TX_PACKET_MAX_SIZE);
      Serial.println("Contents:");
      int value = packetBuffer[0]*256 + packetBuffer[1];
      
      // send a reply, to the IP address and port that sent us the packet we received
     
      if(packetBuffer[0] == '1'){
        //value = HIGH; 
        Serial.println("Uno: "+packetBuffer[0]);
        ordenRemota = true;
        confirmado = true;
      }else if(packetBuffer[0] == '0'){
        //value = LOW;
        Serial.println("Cero: "+packetBuffer[0]);
        ordenRemota = true;
        confirmado = true;
      }else{
        Serial.println("Sin cabula");
      }
       Serial.println(packetBuffer[0]);
      // turn LED on or off depending on value recieved
      
    }
    delay(10);
    
    }
  }
}

void mandar(int valor){
  if(wifiConnected){
    if(udpConnected){

      if( valor == 1 ){
        ping = "1";
        Serial.println("+++++++ SI ++++++++");
      }else if( valor == 0){
        ping = "0";
        Serial.println("------- NO --------");
      }else{
        ping = "2";
        Serial.println("---- Primero contacto con servidor ----");
        Serial.println(remoto);
        Serial.println(remoto2);
      }

      //UDP.beginPacket(valor > 0 ? "1": "0", hostPort);
      UDP.beginPacket(remoto, hostPort);
      UDP.write(ping);
      UDP.endPacket();

      UDP.beginPacket(remoto2, hostPort);
      UDP.write(ping);
      UDP.endPacket();

      //cuenta++;
    }
  }
}


// connect to UDP – returns true if successful or false if not
boolean connectUDP(){
  boolean state = false;
  
  Serial.println("");
  Serial.println("Connecting to UDP");
  
  if(UDP.begin(localPort) == 1){
    Serial.println("Connection successful");
    state = true;
  }
  else{
    Serial.println("Connection failed");
  }
  
  return state;
}
// connect to wifi – returns true if successful or false if not
boolean connectWifi(){
  boolean state = true;
  int i = 0;
  WiFi.begin(ssid, password);
  Serial.println("");
  Serial.println("Connecting to WiFi");
  
  // Wait for connection
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
  delay(500);
  Serial.print(".");
    if (i > 10){
      state = false;
      break;
    }
    i++;
  }
  if (state){
    Serial.println("");
    Serial.print("Connected to ");
    Serial.println(ssid);
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
  }
  else {
    Serial.println("");
    Serial.println("Connection failed.");
  }
  return state;
}

