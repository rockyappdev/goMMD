//
//  Shader.fsh
//  MikuMikuPhone
//
//  Created by hakuroum on 1/14/11.
//  Copyright 2011 hakuroum@gmail.com . All rights reserved.
//


//uniform bool isEdge;
uniform bool useTexture;
uniform bool useSphere;
uniform bool isSphereAdd;

//uniform sampler2D toonSampler;
uniform sampler2D sphereSampler;

uniform lowp vec3 ambient;
uniform lowp vec3 diffuse;
uniform lowp vec3 specularColor;
uniform lowp vec3 lightDir;
uniform lowp vec3 lightDiffuse;


#define USE_PHONG (1)

uniform sampler2D       sTexture;
uniform mediump vec3		vMaterialAmbient;
uniform mediump vec4		vMaterialSpecular;

varying mediump vec4 colorSpecular;
varying mediump vec4 colorDiffuse;
varying highp vec2	texCoord;

#if USE_PHONG
uniform highp vec3		vLight0;
varying mediump vec3 position;
varying mediump vec3 normal;
#endif

void main()
{
#if USE_PHONG
	mediump vec3 halfVector = normalize(-vLight0 + position);
	mediump float NdotH = max(dot(normal, halfVector), 0.0);	
	mediump float fPower = vMaterialSpecular.w;	
	mediump float specular = pow(NdotH, fPower);
	
	mediump vec4 colorSpecular = vec4( vMaterialSpecular.xyz * specular, 1 );
//    gl_FragColor = texture2D(sTexture, texCoord)* colorDiffuse + colorSpecular;

    mediump vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
    
    if (useTexture && false) {
        color.rgb = texture2D(sTexture, texCoord.xy).rgb;
    } else {
        color = colorDiffuse + colorSpecular;
    }
    
    if(useSphere && false) {
        mediump vec2 sphereCoord = 0.5 * (1.0 + vec2(1.0, -1.0) * normalize(normal).xy);
        
        if(isSphereAdd){
            color.rgb += texture2D(sphereSampler, sphereCoord).rgb;
        }else{
            color.rgb *= texture2D(sphereSampler, sphereCoord).rgb;
        }
    }
    
    gl_FragColor = color;
    
#else
    gl_FragColor = texture2D(sTexture, texCoord)* colorDiffuse + colorSpecular;
#endif
}
