/* pmx/shadow.fsh */
#if __VERSION__ < 130
#define in varying
#define outPixelColor gl_FragColor
#else
out vec4 outPixelColor;
#endif
#ifdef GL_ES
precision mediump float;
#endif
uniform vec3 lightColor;

void main() {
    vec4 color = vec4(lightColor, 0.65f);
    outPixelColor = color;
}

