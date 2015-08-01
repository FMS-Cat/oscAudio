/**
 * oscP5message by andreas schlegel
 * example shows how to create osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */
 
import ddf.minim.*;
import ddf.minim.analysis.*;

import oscP5.*;
import netP5.*;

Minim minim;
AudioInput input;
FFT fft;

OscP5 oscP5;
NetAddress myRemoteLocation;
final int PORT = 9000;

void setup(){
  size( 400, 400 );
  frameRate( 60 );
  
  minim = new Minim( this );
  input = minim.getLineIn( Minim.STEREO, 1024 );
  fft = new FFT( input.bufferSize(), input.sampleRate() );
  
  oscP5 = new OscP5( this, 9001 );
  myRemoteLocation = new NetAddress( "127.0.0.1", PORT );
}

void draw(){
  background( 0 );
  
  float loudL = 0.0;
  float loudR = 0.0;
  for( int i=0; i<1024; i++ ){
    loudL = max( loudL, input.left.get( i ) );
    loudR = max( loudR, input.right.get( i ) );
  }
  ellipse( loudL * 400, 100, 32, 32 );
  ellipse( loudR * 400, 150, 32, 32 );
  
  fft.forward( input.mix );
  
  OscMessage messageFftSize = new OscMessage( "/audio/fftSize" );
  messageFftSize.add( fft.specSize()/20 );
  oscP5.send( messageFftSize, myRemoteLocation );
  
  OscMessage messageFft = new OscMessage( "/audio/fft" );
  for( int i=0; i<fft.specSize(); i+=20 ){
     messageFft.add( fft.getBand( i ) );
  }
  oscP5.send( messageFft, myRemoteLocation );
  
  OscMessage messageLoud = new OscMessage( "/audio/loud" );
  messageLoud.add( loudL );
  messageLoud.add( loudR );
  oscP5.send( messageLoud, myRemoteLocation );
}

void stop(){
  input.close();
  minim.stop();
  
  super.stop();
}

void oscEvent( OscMessage theOscMessage ){
  println( "### received an osc message." );
  println( " addrpattern: " + theOscMessage.addrPattern() );
  println( " typetag: " + theOscMessage.typetag() + "\n" );
}
