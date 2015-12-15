#version 150

const float pi = 3.1415926;

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D normalBuffer;
uniform vec2 windowSize;
uniform float R;
uniform float s;
uniform float k;
uniform int randPoints;

// "varying" coming from vertex shader
in vec2 transform;

// output
out vec4 aoOut;

float HeavySide(in float a) {
    if(a < 0) {
        return 0.0;
    } else {
        return 1.0;
    }
}

void main() {
    int   xPrime = int(gl_FragCoord.x),
          yPrime = int(gl_FragCoord.y);
    vec2 xy = vec2(xPrime/windowSize.x,yPrime/windowSize.y);
    
    vec4 pos  = texture(positionBuffer,xy), // world space
         norm = texture(normalBuffer,xy);   // world space
    
    //If we are calculating the ambient for the skydome, simply output white.
    if(pos.w < 0) {
        aoOut = vec4(1,1,1,-1);
        return;
    }
    
    // select some random points
    
    int n = randPoints;
    float c        = 0.1 * R,
          cSquared = pow(c,2),
          psy      = 0.001,
          gamma    = (30 * xPrime ^ yPrime) + 10 * xPrime * yPrime,
          d        = norm.w; // This is in camera space depth
    vec3 N = norm.xyz,
         P = pos.xyz;
    
    float S = 0.0;
    for(int i = 0; i < n; i++) {
        float alpha = (float(i) + 0.5) / float(n);
        float h = alpha * R / d;
        float phi = 2.0 * pi * alpha * (7.0 * n / 9.0) + gamma;
        
        vec2 uv = xy + h * vec2(cos(phi),sin(phi));
        
        vec3  pSubi = texture(positionBuffer,uv).xyz;
        float dSubi = texture(positionBuffer,uv).w; //view space z of
        vec3  wSubi = pSubi - P;
        
        
        float top = max(0, max(dot(N,wSubi),0) - psy * dSubi)
                         * HeavySide(R - length(wSubi)),
              bot = max(cSquared,max(dot(wSubi,wSubi),0));
        
        S += top/bot;
    }
    
    S *= (2.0 * pi * c) / n;
    
    float ao = max( pow( (1 - s * S),k ) ,0 );
    aoOut = vec4(vec3(ao),1);
}
