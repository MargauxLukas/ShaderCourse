Shader "Unlit/MinimalShader"    //defines the name of the shader
{
    SubShader   //Unity chooses the subshader that fits the GPU best
    {
        Pass    //some shaders require multiple passes
        {
            CGPROGRAM   //here begins the part in Unity's Cg

            #pragma vertex vert     // this specifies the vert function as the vertex shader
            #pragma fragment frag   // this specifies the frag function as the fragment shader
            
            float4 vert (float4 vertexPos : POSITION) : SV_POSITION     //vertex shader
            {
                return UnityObjectToClipPos(float4(1, .1, 1, 1) * vertexPos);  //this line transforms the vertex input parameter and returns it as a nameless vertex output parameter
            }

            float4 frag(void) : COLOR   //fragment shader
            {
                return float4(.6, 1, 0, 1);  //this fragment shader returns a nameless fragment output parameter that is set to opaque red
            }
            ENDCG   //here end the part in Cg
        }
    }
}
