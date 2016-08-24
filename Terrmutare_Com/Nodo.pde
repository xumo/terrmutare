NodoUI getNodoUI(Nodo nodo){
	for (int i = 0; i < nodosUi.size(); i++) {
	   if(nodosUi.get(i).nodo == nodo){
	   		return nodosUi.get(i);
	   };
	  }
	return null;
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
		height 			= 70;
		nodo 			= inNodo;
		pressed 		= false;
		seleccionado 	= false;
	}


	float getPanX(){
		float pan = 0.0;
		if( x + width * 0.5 <= xEspacio){
			pan =  -1.0;
		}else if( x + width * 0.5 > xEspacio + anchoEspacio){
			pan =  1.0;
		}else{
			pan = 2 * ( x + width * 0.5 - xEspacio - anchoEspacio * 0.5) / anchoEspacio;
		}
		return pan;
	}

	float getPanY(){
		float pan = 0.0;
		if( y + height * 0.5 <= yEspacio){
			pan =  -1.0;
		}else if( y + height * 0.5 > yEspacio + altoEspacio){
			pan =  1.0;
		}else{
			pan = 2 * ( y + height * 0.5 - yEspacio - altoEspacio * 0.5) / altoEspacio;
		}
		return pan;
	}

	boolean overMe(){
		return mOverMe;
	}

	void mouseMove( float mX ,float mY ){
		if( mX > x && mX < x + width && mY > y && mY < y + height -20  ){
			mOverMe = true;
		}else{
			mOverMe = false;
		}
	}

	void mouseDown( float mX ,float mY ){


		if( mOverMe ){
			ofsetX = mX - x;
			ofsetY = mY - y;
			pressed = true;
			//mandarOsc("1", nodo);
			println("pan : "+ getPanX() +" : " + getPanY());
		}else{
			pressed = false;
      //Pender
      if( mX > x && mX < x + 25 && mY > y + 50 && mY < y + height   ){
        apagar();
      }
      
      //Apagar
      if( mX > x + 25 && mX < x + 50 && mY > y + 50 && mY < y + height   ){
        prender();
      }


		}
	}

	void drag( float mX ,float mY ){
		if(pressed){
			x = mX - ofsetX;
			y = mY - ofsetY;
		}

	}

  void prender(){
    println("prender nodo: "+nodo.id);
    sendNodo(nodo ,"1");
    mandarOsc("1", nodo);
    nodo.prendido=  true;
  }
  
  void apagar(){
    println("apagar nodo: "+nodo.id);
    sendNodo(nodo ,"0");
    mandarOsc("0", nodo);
    nodo.prendido=  false  ;
  }

	void draw(){
		if(seleccionado || mOverMe){
			fill( mOverMe ? 200 : 120 );  
			rect(x - 5, y - 5, width + 10 , height + 10, 5);
		}
		fill( 40 , 40, nodo.prendido ? 255 : 40  );  
		//fill( 40 , mOverMe ? 255 : 40, mOverMe ? 255 : 40  );  
		rect(x, y, width, height -20, 5);

    //Apagar
    fill( 200 , 40,  40 );  
    rect(x, y +50, 25, 20, 5);
    
    
    //Prender
    fill( 40 , 200,  40 );  
    rect(x+25, y +50, 25, 20, 5);

		textSize(12);
		textAlign(CENTER);
		fill( nodo.conectado ? 0 : 250 , nodo.conectado ? 250 : 0 , 0 );
		text( nodo.ip , x + width * 0.5 , y + height + 20 ); 

		textSize(18);
		textAlign(CENTER, CENTER);
		text( str( nodo.id ) , x  , y , width , height );
	}


}
