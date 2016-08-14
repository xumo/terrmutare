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

	boolean overMe(){
		return mOverMe;
	}

	void mouseMove( float mX ,float mY ){
		if( mX > x && mX < x + width && mY > y && mY < y + height  ){
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
		}else{
			pressed = false;
		}
	}

	void drag( float mX ,float mY ){
		if(pressed){
			x = mX - ofsetX;
			y = mY - ofsetY;
		}

	}

	void draw(){
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
		text( nodo.ip , x + width * 0.5 , y + height + 20 ); 

		textSize(18);
		textAlign(CENTER, CENTER);
		text( str( nodo.id ) , x  , y , width , height );
	}


}