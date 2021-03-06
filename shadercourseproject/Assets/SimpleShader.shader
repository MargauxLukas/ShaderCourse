﻿Shader "Unlit/SimpleShader"
{
    Properties
    {
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
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

            //Vertex shader function
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.uv0 = v.uv0; //take the uv from mesh, pass it through VertexOutput function which output data read by the frag. shader
                o.normal = v.normal; 
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

            //returns a color
            float4 frag(VertexOutput i) : SV_Target
            {
                float2 uv = i.uv0; //get the uv from the VertexOutput in parameters
                //float3 normals = i.normal * 0.5 + 0.5; //i.normal is -1 to 1 (= 2) to get the normals go from 0 to 1, need to divide it by 2 and add 0.5 
                float3 lightDir = normalize(float3 (1, 1, 1)); //to do hard code lighting (not real lighting, faking a light source), declare a light direction
                float3 lightFalloff = dot(lightDir, i.normal);
                float3 lightColor = float3(.9, .85, .7);
                float3 diffuseLight = lightColor * lightFalloff;
                float3 ambientLight = float3 (.2, .35, .4);

                return float4(ambientLight + diffuseLight, 0);
                //display uv in xy coords (float2) //output uv will render the 2D uv tex on the sphere, where x is red channel and y is green channel of the color output
                //display only positive normals (0 to 1) and you have a usable normal map
                //display light by returning .xxx coords, light not having y and z coords. For a pure white light display lightFalloff.xxx. For a colored light, display diffuseLight
                //display diffuseLight + ambientLight for a more realistic light 
            }

            ENDCG
        }
    }
}
