#version 150
// uniforms
uniform mat4 MWLP;

in vec4 transform;

out vec4 depth;

void main() {
    //gl_FragDepth = position.z;
    float t = transform.w / (100.0 - 1.0);
    depth = vec4(t,t,t,1.0);//(gl_FragCoord.z);
    
    // Writes out to the hardware depth texture. Faster than writing to a
    //     color texture.
    //gl_FragDepth = t;
}
