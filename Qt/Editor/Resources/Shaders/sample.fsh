//#ifdef GL_FRAGMENT_PRECISION_HIGH
//	precision highp float;
//#else
//	precision mediump float;
//#endif

varying vec4 color;
//uniform mat4 uModelToWorldMat;
//uniform mat4 uWorldToViewMat;
//uniform mat4 uViewToPerspMat;

void main()
{
	gl_FragColor = color;
}