import java.util.Map;


void iniciarUdp(){
	udp = new UDP( this, 12000 );
   udp.log( true );     // <-- printout the connection activity
   udp.listen( true );
}

//PAra recibir paquetes de los nodos
void receive( byte[] data, String ip, int port ) {
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
  	
    nodos.get(ip).prendido = int(message) == 1;
  	mandarOsc(message, nodos.get(ip));
  	println( "::: Prendes nodo :: " +  nodos.get(ip).conectado);
  
    if( int(message) == 2){
      sendNodo(nodos.get(ip),"2");
    }
  
  }else{
  	Nodo nodo = new Nodo();
  	nodo.id = nodos.size();
  	nodo.ip = ip;
  	nodo.conectado = true;
  	nodos.put(ip, nodo );
  	nodosID.put(nodo.id, nodo);
  	sendNodo(nodos.get(ip), "2");
  	println( ":::: Conectando con nodo ::::"+ nodos.size() );
  	nodosUi.add( new NodoUI(nodo, random(width), random(height)) );
  }

  println( "receive: \""+message+"\" from "+ip+" on port "+port );
  println( "nodos: " + nodos.size() );
  
} 

void sendNodo(Nodo nodo, String msg){
	int port        = 6000;
	 udp.send( msg, nodo.ip, port );
}

void sendUdp(boolean prendido){
   String message  = prendido ? "1" : "0";  // the message to send
   String ip       = "192.168.1.92";  // the remote IP address
   int port        = 6000;    // the destination port
    
   udp.send( message, ip, port );
}