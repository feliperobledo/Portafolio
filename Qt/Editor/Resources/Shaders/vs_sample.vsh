attribute lowp vec4 aPosition;
attribute lowp vec4 aColor;
varying vec4 color;
//uniform mat4 uModelToWorldMat;
//uniform mat4 uWorldToViewMat;
//uniform mat4 uViewToPerspMat;

void main()
{
    color = aColor;
    gl_Position = uViewToPerspMat * uWorldToViewMat * uModelToWorldMat * aPosition;
}
