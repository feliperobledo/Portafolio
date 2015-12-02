#version 150

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D environmentBuffer;
uniform sampler2D irradianceBuffer;
uniform vec3[40] randomNormals;
uniform float Kd;

// input "varyings"

// HELPERS ---------------------------------------------------------------------
void halfVector(in vec3 L,in vec3 V,out vec3 h) {
    h = normalize(L + V);
}

void F(in vec3 L,in vec3 H,out vec3 f) {
    // Note sure if the dot product in the following formular should be
    //    clamped to 0
    f = Ks + (1 - Ks) * pow( (1 - max( dot(L,H),0.0) ), 5 );
}

void G(in vec3 L, in vec3 V, in vec3 N,in vec3 H, out float g) {
    float dotNH = max(dot(N,H),0);
    float dotNV = max(dot(N,V),0);
    float dotHV = max(dot(H,V),0);
    float dotHL = max(dot(H,L),0);
    float dotNL = max(dot(N,L),0);
    
    float k = (2 * dotNH * dotNV) / dotHV;
    float d = (2 * dotNH * dotNL) / dotHL;
    
    g = min( 1, min(k,d) );
}

void D(in vec3 H,in vec3 N,out float d) {
    d = ((roughness + 2.0) / (2.0 * pi)) *
    pow( max( dot(N,H),0 ),roughness );
}

void LightFromDir(in vec3 dir,out vec3 intensity) {
    
}
// HELPERS - END ---------------------------------------------------------------

void main(void) {
    /*
        Calculate the diffuse color by:
            
        diffuse = (Kd / pi) * irradiance(N)
    
    */
    
    /*
        Calculate the specular term by using the monte carlo approximation
        of the integral.
     
        float g;
        vec3 f;
        vec4 specular;
     
        for every dir in randomNormals
            wSubK = dir;
            vec3 lSubi;
            LightFromDir(wSubK,lSubi)
            G(wSubK, V, N, H, g);
            F(wSubK, H, f);
     
            specular += (g * f / 4 * dot(wSubK,N) * dot(V,N)) * lSubi * dot(wSubK,V)
     
        specular *= (1/40)
    */
    
    /*
        Calculate final light value by adding the diffuse and specular
     
        final = specular + diffuse;
    */
}