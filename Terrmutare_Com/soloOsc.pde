void iniciarOsc(){
	/*  
   * Creamos objecto OSC y se abre el puerto 8000 para recibir mensajes
   */
  oscP5 = new OscP5(this,8000);
  
  /* Dirección IP y puerto de la máquina que recibe los OSC
   * 
   */
  
  myBroadcastLocation = new NetAddress("127.0.0.1",57120);
  //direccionVisuales  = new NetAddress("192.168.1.103",57120);
  direccionVisuales  = new NetAddress("192.168.1.100",57120);
}

void mandarOsc(String message, Nodo nodo){
  
	OscMessage myOscMessage = new OscMessage("/terrmutare");
  
	int uno = int( message);
	if (uno == 1){
		println("uno");
	}else if( uno==0){
		println("cero"); 
	}

	myOscMessage.add( nodo.id );
	myOscMessage.add( int(message) );
	oscP5.send(myOscMessage, myBroadcastLocation );
	oscP5.send(myOscMessage, direccionVisuales );
}

void oscEvent(OscMessage theOscMessage) {
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
      		sendNodo( nodosID.get(idNodo) , str(valor) );
      	}
      
      }
      
    }  
  } 
}