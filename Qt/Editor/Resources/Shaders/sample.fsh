//#ifdef GL_FRAGMENT_PRECISION_HIGH
//	precision highp float;
//#else
//	precision mediump float;
//#endif

varying vec4 color;
uniform mat4 u_modelPersp_matrix;

void main()
{
	gl_FragColor = color;
}
