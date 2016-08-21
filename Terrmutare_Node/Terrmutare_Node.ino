#include <ESP8266WiFi.h>
#include <WiFiUDP.h>

// wifi connection variables
///const char* ssid = "TelevisaTeIdiotiza";
//const char* password = "5554402768";

const char* ssid = "TERRMUTARE";
const char* password = "terrm";


boolean wifiConnected = false;
boolean confirmado = false;

//Direccion de l servidor
char* remoto = "192.168.1.101";
char* remoto2 = "192.168.1.76";


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

int salida;
int entradaSensor;
int btn;
int val;
char* ping;
int redpin=1;

int boton = 5;
int puertoSensor = A0;

boolean prendido = false;
boolean prendidoAnterior = false;
boolean ordenRemota = false;
boolean estadoSensor = false;

boolean cambioSensor = false;
boolean cambioServidor = false;
boolean estadoServidor = false;
boolean estadoServidorAnterior = false;
boolean estadoFinal = false;


unsigned long tiempo, tiempoRef, tiempoMax;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
    Serial.println("******* Inicio Terrmutare *********");
  
  pinMode(redpin,OUTPUT);
  pinMode(puertoSensor, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  wifiConnected = connectWifi();

   if(wifiConnected){
    udpConnected = connectUDP();
    if (udpConnected){

      //pinMode(LED_BUILTIN,OUTPUT);
    }
  }

}

void loop() {
  
  leerSensor();
  recibirUDP();

  if( cambioSensor){
    cambioServidor = false; 
  }

  if( cambioServidor){
    prendido = estadoServidor;
  }else{
    prendido = estadoSensor;
  }

  salida = !prendido ? HIGH : LOW;
  digitalWrite( LED_BUILTIN, salida ); 

  if( !confirmado){
    tiempo = millis() - tiempoRef;
    if( tiempo > tiempoMax){
      mandar(2);
      tiempoRef = millis();
      Serial.println("******* mandar 2 *********");
    }
  }

}


void leerSensor(){

   val=analogRead(puertoSensor);
   val=(6762/(val-9))-4;
   Serial.println(val);
   if( val >=0 && val < 15 ){
    prendido = true;
   }else{
    prendido = false;
   }

   if( prendido  != prendidoAnterior ){
    mandar( prendido ? 1 : 0);
    estadoSensor = prendido ? true : false;
    cambioSensor = true;
  }else{
    cambioSensor = false;
  }

  prendidoAnterior = prendido;
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
        estadoServidor = true;
        confirmado = true;
        //return true;
      }else if(packetBuffer[0] == '0'){
        //value = LOW;
        Serial.println("Cero: "+packetBuffer[0]);
        estadoServidor = false;
        confirmado = true;
        //return true;
      }else if(packetBuffer[0] == '2'){
        Serial.println("Confirmado");
        confirmado = true;
      }
       Serial.println(packetBuffer[0]);

       cambioServidor = true;
       

       estadoServidorAnterior = estadoServidor;

      
    }
    delay(10);
    
    }
  }

  //return false;
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
