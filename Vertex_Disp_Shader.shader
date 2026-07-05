Shader "Custom/Vertex_Disp_Shader"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _BaseMap;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.uv = IN.uv;
                float xMod = tex2Dlod(_BaseMap, float4(OUT.uv.xy,0,1));
                xMod = xMod * 2 -1;
                
                OUT.uv.x = sin(xMod * 10 + _Time.y);
                float3 vert = IN.positionOS;
                vert.y = OUT.uv.x;
                OUT.positionHCS = TransformObjectToHClip(vert);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return tex2D(_BaseMap,IN.uv);
            }
            ENDHLSL
        }
    }
}
