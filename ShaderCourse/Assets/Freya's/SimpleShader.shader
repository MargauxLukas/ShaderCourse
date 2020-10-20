Shader "Unlit/SimpleShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Float) = 1
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM

            //#pragma init the vertex and fragment shaders with a name == a var initialisation in Unity
            #pragma vertex vert
            #pragma fragment frag

            //sort of using from Unity, include many Unity functionalities
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" //using this for shading with Unity lights

            //Mesh data: vertex pos, vertex normal, UVs, tangents, vertex color
            struct VertexInput      //originally named appdata
            {
                float4 vertex : POSITION;
                //if you want to access to other datas you need to initialize them in there 
                //float4 colors : COLOR;
                float4 normal : NORMAL; //normal direction of each vertex
                //float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0;     //can use float4 for UVs but it's rare    //use multiple UV channels for multiple data like one for texture, one for lightmaps...
                //float2 uv1 : TEXCOORD1;     //each vertex has UV data that is the position of the vertex in a 2D space which is the UV space. UVs basically determine how to map a texture on a 3D mesh
            };

            //Output of Vertex shader that goes into the Fragment shader
            struct VertexOutput     //originally named v2f
            {
                float4 clipSpacePos : SV_POSITION;  //initialise the var for the clip position output by the next function
                float2 uv0 : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            uniform float4 _Color;
            float _Gloss;
            uniform float4

            //Vertex shader function
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0; //take the uv from mesh, pass it through VertexOutput function which output data read by the frag. shader
                o.normal = v.normal;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex); //can't read a position, need to multiply matrix with this Unity function to transform vertex from local space to world space
                o.clipSpacePos = UnityObjectToClipPos(v.vertex); //can skip lines above and under by just returning clipSpacePos (example below)
                return o;
            }

            /*
                ////////EXAMPLE\\\\\\\\
            float4 vert (VertexInput v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }
            
            float4 frag(float4 o : SV_POSITION) : SV_Target
            {
                return float4(1,1,1,0);
            }
                \\\\\\\\EXAMPLE////////
            */

            //float / fixed / half --> different levels of precision, usually use float which is the most precise //fixed and half mostly use for non desktop applications (like mobile)

            //created for a personalized lerp 
            float3 MyLerp(float3 a, float3 b, float t) 
            {
                return t*b + (1.0 - t)*a;
            }

            //there is no InvLerp in shader language, have to do it manually
            float InvLerp(float3 a, float3 b, float value) 
            {
                return (value - a) / (b - a);
            }

            float Posterize(float steps, float value) 
            {
                return floor(value * steps) / steps;
            }

            //returns a color
            float4 frag(VertexOutput i) : SV_Target
            {
                float2 uv = i.uv0; //get the uv from the VertexOutput in parameters

                    //__Color Gradient__
                //float3 colorA = float3(.1, .8, 1); //define 2 colors
                //float3 colorB = float3(1, .1, .8);
                //float t = step(uv.y, .5); //to do a harsh cutoff but with a lerp function
                //float t = uv.y; //use this for lerp
                //float t = InvLerp(.25, .75, uv.y); //use this for InvLerp
                //float t = smoothstep(.25, .75, uv.y); // smoothstep is basically the same as InvLerp but with a curve applied which makes it smoother
                //t = round(t * 8) / 8; //use this for a steppy gradient 
                //t = floor(t * 8) / 8; //or this, depends on what alignment is needed
                //t = Posterize(16, t); //same but with a function, can be used for lighting (cf specularFalloff & lightFalloff funcs)

                //return t; //debug

                //float3 blend = MyLerp(colorA, colorB, t); //interpolate between them then return result

                //return float4(blend, 0); //debug

                //float3 normals = i.normal * 0.5 + 0.5; //i.normal is -1 to 1 (= 2) to get the normals go from 0 to 1, need to divide it by 2 and add 0.5 
                float3 normal = normalize(i.normal); //Interpolated normals normalized to only have lenght = 1 and have a smooth render

                        //__LIGHTING__
                //float3 lightDir = normalize(float3 (1, 1, 1)) //to do hard code lighting (not real lighting, faking a light source), declare a light direction
                float3 lightDir = _WorldSpaceLightPos0.xyz; //to do lighting using Unity lights  
                //float3 lightColor = float3(.9, .85, .7);
                float3 lightColor = _LightColor0.rgb; //to do lighting using Unity lights

                    //__Direct diffuse Light__
                float3 lightFalloff = saturate(dot(lightDir, normal)); //saturate clamps values between 0 to 1 //can use max(0, yourValue)
                //lightFalloff = step(.1, lightFalloff); //for cell shading/toon shading
                //lightFalloff = Posterize(4, lightFalloff); //steps gradient
                float3 directDiffuseLight = lightColor * lightFalloff; //the light source color basically

                    //__Ambient Light__
                float3 ambientLight = float3 (.2, .2, .2); //ambiance created by surroundings //grey scale for example

                    //__Direct specular Light__
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - i.worldPos;
                float3 viewDir = normalize(fragToCam);

                    //__Phong (Specular Highlights)__
                float3 viewReflect = reflect(-viewDir, normal); //view reflection
                float3 specularFalloff = max(0, dot(viewReflect, lightDir)); //add glossiness
                specularFalloff = pow(specularFalloff, _Gloss); //modify gloss by adding a new variable _Gloss and make your specularFalloff power _Gloss
                //specularFalloff = step(.1, specularFalloff); //for cell shading/toon shading
                //specularFalloff = Posterize(4, specularFalloff); //steps gradient
                float3 directSpecular = specularFalloff * lightColor;

                    //__Composite__
                float3 diffuseLight = ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular; //color of the suface affected by lighting plus specular light

                return float4(finalSurfaceColor, 0);
                //display uv in xy coords (float2) //output uv will render the 2D uv tex on the sphere, where x is red channel and y is green channel of the color output
                //display only positive normals (0 to 1) and you have a usable normal map
                //display light by returning .xxx coords, light not having y and z coords. For a pure white light display lightFalloff.xxx. For a colored light, display directDiffuseLight
                //display diffuseLight for a more realistic light //sum can go >1, depends on light source etc, >1 will turn color to a pure white
                //display finalSurfaceColor for a diffuse color, affected by color, light source, ambient light & specular light
                //debug world position by returning i.worldPos, random alpha (1 is good)
            }

            ENDCG
        }
    }
}
