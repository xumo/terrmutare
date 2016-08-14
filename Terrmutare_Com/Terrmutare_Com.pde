import controlP5.*;
import hypermedia.net.*;

import oscP5.*;
import netP5.*;

/*
*
* Variables de comunicación UDP y OSC
* ver soloUsp.pde y soloOsc
* EL programa envía y recive mensaje a los nodo por UDP
* y tiene la opcoó de recinir y mandar por OSC a cualquier programa
*/
UDP udp; 
OscP5 oscP5;
NetAddress myBroadcastLocation; 


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

void setup() {
  size(1280, 800);
  iniciarUdp();
  iniciarOsc();
  cargarXml();
  /*int cuenta = 121;
  for (int i = 0; i < 20; i++){
    Nodo nodo = new Nodo();
    nodo.id = nodos.size();
    nodo.ip = "192.168.15." + str( cuenta );
    nodo.conectado = true;
    nodos.put(nodo.ip, nodo );
    nodosID.put(nodo.id, nodo);
    nodosUi.add( new NodoUI(nodo, random(width), random(height)) );
    cuenta++;
  }*/
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
  for (int i = 0; i < nodosUi.size(); i++) {
   nodosUi.get(i).draw();
  }
}






