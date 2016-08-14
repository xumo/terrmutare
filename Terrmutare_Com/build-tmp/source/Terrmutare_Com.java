import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import hypermedia.net.*; 
import oscP5.*; 
import netP5.*; 
import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Terrmutare_Com extends PApplet {







/*
*
* Variables de comunicaci\u00f3n UDP y OSC
* ver soloUsp.pde y soloOsc
* EL programa env\u00eda y recive mensaje a los nodo por UDP
* y tiene la opco\u00f3 de recinir y mandar por OSC a cualquier programa
*/
UDP udp; 
OscP5 oscP5;
NetAddress myBroadcastLocation; 


/*
* Listas que contienen a los objectos nodos y a los botones que los representan
* en Nodo.pde viene las definiciones de los objecto Nodo y NodoUI(el bot\u00f3n)
*/



HashMap<String,Nodo> nodos = new HashMap<String,Nodo>();
HashMap<Integer,Nodo> nodosID = new HashMap<Integer,Nodo>();
ArrayList<NodoUI> nodosUi = new ArrayList<NodoUI>();

/*
* Se puede seleccionar un nodo
* para poder mandarle mensajes por este medio
*/
NodoUI nodoActivo = null;

public void setup() {
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

public void mouseMoved() {
  for (int i = 0; i < nodosUi.size(); i++) {
    nodosUi.get(i).mouseMove(mouseX, mouseY);

    if ( nodosUi.get(i).overMe() ) {
      return;
    }
  }
}

public void mouseDragged() 
{
  for (int i = 0; i < nodosUi.size(); i++) {
    nodosUi.get(i).drag( mouseX , mouseY );
  }
}

public void mousePressed() {
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

public void mouseReleased() {
 
}

public void keyPressed() {
  if (key == ' ') {
    println("mandar a nodo activo");
    if( nodoActivo != null){
      sendNodo(nodoActivo.nodo, "1");
    }
  }else if( key == 's' || key == 'S' ){
    guardarXml();
  } 
}

public void draw() {
  background(0);
  for (int i = 0; i < nodosUi.size(); i++) {
   nodosUi.get(i).draw();
  }
}






public void armarBotones(){
	
}
class Nodo{
	
	int id;
	String ip;
	boolean conectado;
	boolean prendido;

	Nodo(){
		prendido  = false;
		conectado = false;
	}
}

class NodoUI{
	float 	x,
			y,
			ofsetX,
			ofsetY,
			width,
			height;
	
	Nodo 	nodo;

	boolean mOverMe,
			pressed,
			seleccionado;

	NodoUI(Nodo inNodo, float inX, float inY){
		x 				= inX;
		y 				= inY;
		width 			= 50;
		height 			= 50;
		nodo 			= inNodo;
		pressed 		= false;
		seleccionado 	= false;
	}

	public boolean overMe(){
		return mOverMe;
	}

	public void mouseMove( float mX ,float mY ){
		if( mX > x && mX < x + width && mY > y && mY < y + height  ){
			mOverMe = true;
		}else{
			mOverMe = false;
		}
	}

	public void mouseDown( float mX ,float mY ){
		if( mOverMe ){
			ofsetX = mX - x;
			ofsetY = mY - y;
			pressed = true;
		}else{
			pressed = false;
		}
	}

	public void drag( float mX ,float mY ){
		if(pressed){
			x = mX - ofsetX;
			y = mY - ofsetY;
		}

	}

	public void draw(){
		if(seleccionado || mOverMe){
			fill( mOverMe ? 200 : 120 );  
			rect(x - 5, y - 5, width + 10 , height + 10, 5);
		}
		fill( 40 , 40, nodo.prendido ? 255 : 40  );  
		//fill( 40 , mOverMe ? 255 : 40, mOverMe ? 255 : 40  );  
		rect(x, y, width, height, 5);

		textSize(12);
		textAlign(CENTER);
		fill( nodo.conectado ? 0 : 250 , nodo.conectado ? 250 : 0 , 0 );
		text( nodo.ip , x + width * 0.5f , y + height + 20 ); 

		textSize(18);
		textAlign(CENTER, CENTER);
		text( str( nodo.id ) , x  , y , width , height );
	}


}
public void iniciarOsc(){
	/*  
   * Creamos objecto OSC y se abre el puerto 8000 para recibir mensajes
   */
  oscP5 = new OscP5(this,8000);
  
  /* Direcci\u00f3n IP y puerto de la m\u00e1quina que recibe los OSC
   * 
   */
  
  myBroadcastLocation = new NetAddress("127.0.0.1",8001);
}

public void mandarOsc(String message, Nodo nodo){

	OscMessage myOscMessage = new OscMessage("/terrmutare");
  
	int uno = PApplet.parseInt( message);
	if (uno == 1){
		println("uno");
	}else if( uno==0){
		println("cero"); 
	}

	myOscMessage.add( nodo.id );
	myOscMessage.add( PApplet.parseInt(message) );
	oscP5.send(myOscMessage, myBroadcastLocation);
}

public void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/terrmutare") == true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ii")) {
      
      int idNodo = theOscMessage.get(0).intValue();  
      int valor = theOscMessage.get(1).intValue();
      if( nodosID.containsKey( idNodo ) ){
      	
      	//El valor debe ser 0 o 1 para poder enviarlo al nodo y encender o apagar el nodoUI
      	if (valor == 1) {
      		nodosID.get(idNodo).prendido = true;
      		sendNodo( nodosID.get(idNodo) , str(valor));
      	}else if( valor == 0){
      		nodosID.get(idNodo).prendido = false;
      		sendNodo( nodosID.get(idNodo) , str(valor));
      	}
      	

      }
      
    }  
  } 
}



public void iniciarUdp(){
	udp = new UDP( this, 12000 );
   udp.log( true );     // <-- printout the connection activity
   udp.listen( true );
}

//PAra recibir paquetes de los nodos
public void receive( byte[] data, String ip, int port ) {
  data = subset(data, 0, data.length);
  String message = new String( data );
  
  //Revisar que ya tengamos registado ese nodo
  if( nodos.containsKey( ip ) ){
  	if(nodos.get(ip).conectado){
  		println("nodo conectado");
  	}else{
  		println("se acaba de conectar nodo " + ip);
  		nodos.get(ip).conectado =  true;
  		sendNodo(nodos.get(ip), "1");
  	}
  	nodos.get(ip).prendido = PApplet.parseInt(message) == 1;

  	println( "::: Prendes nodo :: " +  nodos.get(ip).conectado);
  }else{
  	Nodo nodo = new Nodo();
  	nodo.id = nodos.size();
  	nodo.ip = ip;
  	nodo.conectado = true;
  	nodos.put(ip, nodo );
  	nodosID.put(nodo.id, nodo);
  	sendNodo(nodos.get(ip), "1");
  	println( ":::: Conectando con nodo ::::" );
  	nodosUi.add( new NodoUI(nodo, random(width), random(height)) );
  }

  println( "receive: \""+message+"\" from "+ip+" on port "+port );
  println( "nodos: " + nodos.size() );
  
} 

public void sendNodo(Nodo nodo, String msg){
	int port        = 6000;
	 udp.send( msg, nodo.ip, port );
}

public void sendUdp(boolean prendido){
   String message  = prendido ? "1" : "0";  // the message to send
   String ip       = "192.168.1.92";  // the remote IP address
   int port        = 6000;    // the destination port
    
   udp.send( message, ip, port );
}
XML xml;

public void cargarXml(){
  xml = loadXML("marcos.xml");
  XML[] children = xml.getChildren("nodo");

  for (int i = 0; i < children.length; i++) {
    int id 		= PApplet.parseInt( children[i].getChild("id").getContent()) ;
    String ip	= children[i].getChild("ip").getContent();
    float x 	= PApplet.parseFloat( children[i].getChild("posicion").getChild("x").getContent() );
    float y 	= PApplet.parseFloat( children[i].getChild("posicion").getChild("y").getContent() );
   // String name = children[i].getContent();
    println( "id: " + id + " ip " + ip + " x " + x + " y " + y);
    Nodo nodo = new Nodo();
  	nodo.id = id;
  	nodo.ip = ip;
  	nodo.conectado = false;
  	nodos.put(ip, nodo );
  	nodosID.put(id, nodo);
  	//sendNodo(nodos.get(ip), "1");
  	nodosUi.add( new NodoUI( nodo, x , y ) );
  }

}

public void guardarXml(){
	println("guardarXml");
	XML marcos = new XML("marcos");
	for (int i = 0; i < nodosUi.size(); i++) {
		XML nodo = new XML("nodo");
		XML id = new XML("id");
		XML ip = new XML("ip");
		XML posicion = new XML("posicion");

		XML x = new XML("x");
		XML y = new XML("y");

		x.setContent( str( nodosUi.get(i).x) );
		y.setContent( str( nodosUi.get(i).y) );

		posicion.addChild(x);
		posicion.addChild(y);
		id.setContent( str( nodosUi.get(i).nodo.id ));
		ip.setContent( nodosUi.get(i).nodo.ip );
		
		nodo.addChild(id);
		nodo.addChild(ip);
		nodo.addChild(posicion);
		marcos.addChild(nodo);	

	}

	saveXML(marcos, "marcos.xml");

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Terrmutare_Com" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
