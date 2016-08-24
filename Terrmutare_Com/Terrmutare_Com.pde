//import controlP5.*;
import hypermedia.net.*;

import oscP5.*;
import netP5.*;

/*74063900
*
* Variables de comunicación UDP y OSC
* ver soloUsp.pde y soloOsc
* EL programa envía y recive mensaje a los nodo por UDP
* y tiene la opcoó de recinir y mandar por OSC a cualquier programa
*/
UDP udp; 
OscP5 oscP5;
NetAddress myBroadcastLocation; 

NetAddress direccionVisuales; 



/*
* Listas que contienen a los objectos nodos y a los botones que los representan
* en Nodo.pde viene las definiciones de los objecto Nodo y NodoUI(el botón)
*/



HashMap<String,Nodo> nodos = new HashMap<String,Nodo>();
HashMap<Integer,Nodo> nodosID = new HashMap<Integer,Nodo>();
ArrayList<NodoUI> nodosUi = new ArrayList<NodoUI>();

/*
* Se puede seleccionar un nodo
* para poder mandarle mensajes por este medio
*/
NodoUI nodoActivo = null;


/*
* Dimnesiones del espacio
*
*/
int ancho = 1440;//Cambiar este parámetro para ajustar pantalla al monitor
int alto = 920;//Cambiar este parámetro para ajustar pantalla al monitor
int anchoEspacio = 1240;
int altoEspacio = 760;
int xEspacio    = 50;
int yEspacio    = 50;

void setup() {

  anchoEspacio = ancho - xEspacio * 2;
  altoEspacio = alto - yEspacio * 2;

  size(ancho, alto);
  iniciarUdp();
  iniciarOsc();
  cargarXml();
  int cuenta = 121;
  for (int i = 0; i < 20; i++){
    Nodo nodo = new Nodo();
    nodo.id = nodos.size();
    nodo.ip = "192.168.15." + str( cuenta );
    nodo.conectado = true;
    nodos.put(nodo.ip, nodo );
    nodosID.put(nodo.id, nodo);
    nodosUi.add( new NodoUI(nodo, random(width), random(height)) );
    cuenta++;
  }
}

void mouseMoved() {
  for (int i = 0; i < nodosUi.size(); i++) {
    nodosUi.get(i).mouseMove(mouseX, mouseY);

    if ( nodosUi.get(i).overMe() ) {
      return;
    }
  }
}

void mouseDragged() 
{
  for (int i = 0; i < nodosUi.size(); i++) {
    nodosUi.get(i).drag( mouseX , mouseY );
  }
}

void mousePressed() {
 nodoActivo = null;
 for (int i = 0; i < nodosUi.size(); i++) {
    nodosUi.get(i).mouseDown( mouseX , mouseY );
    nodosUi.get(i).seleccionado = false;
    if(nodosUi.get(i).overMe()){
      nodoActivo = nodosUi.get(i);
      nodoActivo.seleccionado = true;
    }
  }
}

void mouseReleased() {
 
}

void keyPressed() {
  if (key == ' ') {
    println("mandar a nodo activo");
    if( nodoActivo != null){
      sendNodo(nodoActivo.nodo, "1");
    }
  }else if( key == 's' || key == 'S' ){
    guardarXml();
  } 
}

void draw() {
  background(0);

  fill(120, 40, 0);
  rect( xEspacio, yEspacio, anchoEspacio, altoEspacio);

//stroke(0, 40, 200);
stroke(255);
  line( xEspacio , yEspacio + altoEspacio * 0.5, anchoEspacio + xEspacio , yEspacio + altoEspacio * 0.5);
  line( xEspacio + anchoEspacio * 0.5, yEspacio, xEspacio + anchoEspacio * 0.5, altoEspacio+ yEspacio);
  for (int i = 0; i < nodosUi.size(); i++) {
   nodosUi.get(i).draw();
  }
}
