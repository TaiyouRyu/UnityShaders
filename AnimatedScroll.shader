Shader "Custom/AnimatedScroll"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _AnimateXY("Animate X Y", Vector) = (0,0,0,0)
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
                float2 uv : TEXCOORD0;
            };

            struct Vert
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _BaseMap;
            float4 _AnimateXY;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Vert vert(Attributes IN)
            {
                Vert OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                //Always move math to vertex shader
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.uv += frac(_AnimateXY.xy* _BaseMap_ST.xy *_Time.yy);
                return OUT;
            }

            half4 frag(Vert IN) : SV_Target
            {
                float2 uvs = IN.uv;
                half4 textureColor = tex2D(_BaseMap, uvs);
                return textureColor;
            }
            ENDHLSL
        }
    }
}
