#version 150

const float pi = 3.1415926;

/*
 Description: Send quad coordinates to fragment shader
 */

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D diffuseBuffer;
uniform vec3 eye;
uniform vec2 windowSize;
uniform float R; //range of influence
uniform float s; //adjustable scale
uniform float k; //adjustable contrast

// "varying" coming from vertex shader
in vec2 transform;

// output
out vec4 aoOut;

float HeavySide(in int a) {
    if(a >= 0) {
        return 1.0;
    } else {
        return 0.0
    }
}

void main() {
    int xPrime = gl_FragCoord.x,
        yPrime = gl_FragCoord.y;
    vec2 xy = vec2(xPrime/windowSize.x,yPrime/windowSize.y);
    
    vec4 pos  = texture(positionBuffer,xy), // world space
         norm = texture(normalBuffer,xy);   // world space
    
    // If we are calculating the ambient for the skydome, simply output white.
    if(pos.w < 0) {
        fragColor = vec4(1);
        return;
    }
    
    // This is supposed to be camera space depth
    float d = pos.w;
    
    // select some random points
    
    int n = 10;
    float c        = 0.1 * R,
          cSquared = pow(c,2),
          psy      = 0.001,
          gamma    = (30 * xPrime ^ yPrime) + 10 * xPrime * yPrime,
          d        = pos.z;
    vec4 N = norm;
    
    float S = 0.0;
    for(int i = 0; i < n; i++) {
        float alpha = (float(i) + 0.5) / float(n);
        float h = alpha * R / d;
        float phi = 2.0 * pi * alpha * (7.0 * n / 9.0) + gamma;
        
        vec2 pSubi = xy + h * vec2(cos(phi),sin(phi));
        vec2 wSubi = pSubi - xy;
        float dSubi = texture(normalBuffer,pSubi);
        
        float top = max(0, N * wSubi - psy * dSubi)
                         * HeavySide(R - distance(wSubi)),
              bot = max(cSquared,max(dot(wSubi,wSubi,0)));
        
        S += top/bot;
    }
    
    float ao = max( pow( (1 - s * S),k ) ,0 );
    aoOut = vec4(vec3(ao),1);
}
