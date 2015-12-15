#version 150

const float e = 2.7182818285;

// uniforms
uniform sampler2D prevAOBuffer;
uniform sampler2D normalBuffer;
uniform float sFactor;
uniform vec2 windowSize;
uniform float sqrtPiS2;
uniform int blurrWidth;

// attributes
in vec2 transform;

// "varyings"
out vec4 newFilteredAO;

float R(in vec3 nSubi, in float dSubi,
        in vec3 n, in float d) {
    float k = pow((dSubi - d),2);
    
    float a = max( dot(nSubi,n), 0);
    float b = (1 /sqrtPiS2);
    float c = pow(e, (-1/(2 * sFactor) ) * k);
    return  a * b * c;
}

void main() {
    // Our window of pixels will be 3x3, with the pixel in questin in the center
    
    vec2 xy = vec2(gl_FragCoord.x,gl_FragCoord.y);
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    
    vec3  N = texture(normalBuffer,uv).xyz;
    float d = texture(normalBuffer,uv).w;
    
    if (texture(prevAOBuffer,uv).w < 0) {
        newFilteredAO = vec4(1,1,1,-1);
        return;
    };
    
    //newFilteredAO = vec4(N,1);
    //newFilteredAO = texture(prevAOBuffer,uv);
    //newFilteredAO = vec4(1,0,0,1);
    //return;
    
    // Optimization: make this a parameter. Precalculate weights in CPU
    //     and send array.
    // glUniformBlockBinding
    int w = blurrWidth;
    
    // Accounts for the kernel/origin
    int numOfPixels = 2 * w + 1;
    int halfW = numOfPixels / 2;

    float eNegSquareRoot = pow(e, -0.5);
    
    vec3  nominator   = vec3(0);
    float denominator = float(0);
    for(int i = 1; i <= w; i++) {
        float k1 = pow( (i/sFactor), 2 ),
              k2 = pow( (-i/sFactor), 2 );
        
        // Calculating top
        vec2 xy_1 = vec2(gl_FragCoord.x + i, gl_FragCoord.y);
        vec2 uv_1 = vec2(xy_1 / windowSize);
        float weight1 = eNegSquareRoot * pow(1, k1);
        
        vec3  nSubi = texture(normalBuffer,uv_1).xyz;
        float dSubi = texture(normalBuffer,uv_1).w;
        
        float SofXandXi = i * weight1;
        float r = R(nSubi,dSubi,N,d);
        
        float W = r * SofXandXi;
        
        nominator += W * texture(prevAOBuffer,uv_1).xyz;
        denominator += W;
        
        // Calculating bottom
        vec2 xy_2 = vec2(gl_FragCoord.x - i, gl_FragCoord.y);
        vec2 uv_2 = vec2(xy_2 / windowSize);
        float weight2 = eNegSquareRoot * pow(1, k2);
        
        nSubi = texture(normalBuffer,uv_2).xyz;
        dSubi = texture(normalBuffer,uv_2).w;
        
        SofXandXi = i * weight2;
        r = R(nSubi,dSubi,N,d);
        
        W = r * SofXandXi;
        
        nominator += W * texture(prevAOBuffer,uv_2).xyz;
        denominator += W;
    }
    
    newFilteredAO = vec4(nominator / denominator,1);
    
    if (denominator == 0) {
        newFilteredAO = vec4(1,0,0,1);
    }
}