Shader "Unlit/RGBCubeShader"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct vertexOutput     //for multiple vertex output parameters, an output structure is defined
            {
                float4 pos : SV_POSITION;
                float4 col : TEXCOORD0;
            };

            vertexOutput vert (float4 vertexPos : POSITION)
            {
                vertexOutput o;    //no need to type 'struct' here
                o.pos = UnityObjectToClipPos(vertexPos);
                o.col = vertexPos + float4(.5, .5, .5, 0);  //here the vertex shader writes output data to the output struct. add .5 to xyz coord because coords of the cube are between -.5 and .5
                return o;                                   //but we need them to be between 0 and 1
            }

            float4 frag (vertexOutput input) : COLOR
            {
                return input.col;   //here the fragment shader returns the col input parameter (TEXCOORD0) as nameless output parameter (COLOR)
            }
            ENDCG
        }
    }
}
