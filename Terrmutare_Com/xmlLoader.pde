XML xml;

void cargarXml(){
  xml = loadXML("marcos.xml");
  XML[] children = xml.getChildren("nodo");

  for (int i = 0; i < children.length; i++) {
    int id 		= int( children[i].getChild("id").getContent()) ;
    String ip	= children[i].getChild("ip").getContent();
    float x 	= float( children[i].getChild("posicion").getChild("x").getContent() );
    float y 	= float( children[i].getChild("posicion").getChild("y").getContent() );
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

void guardarXml(){
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