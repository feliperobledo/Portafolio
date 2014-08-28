attribute lowp vec4 aPosition;
attribute lowp vec4 aColor;
varying vec4 color;
uniform mat4 u_modelPersp_matrix;

//The output of the vertex shader is clipped, so the

void main()
{
    color = aColor;
    gl_Position =  u_modelPersp_matrix * aPosition;
    //gl_Position = aPosition;
}
