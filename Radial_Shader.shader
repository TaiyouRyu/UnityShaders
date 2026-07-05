Shader "Custom/Radial_Shader"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _SecondMap("Second Map", 2D) = "white" {}
        _Rotation("Rotation", Range(1,10)) = 0
        _RevealValue("Reveal Value", Range(0,1)) = 0
         _Feathering("Feathering", Range(0,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Blend SrcAlpha OneMinusSrcAlpha
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

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _BaseMap;
            sampler2D _SecondMap;
            float _Rotation,_RevealValue,_Feathering;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
                float2 rotUV = OUT.uv.xy;
                rotUV -=0.5;
                float s = sin(_Rotation);
                float c = cos(_Rotation);
                float2x2 rotMatrix = float2x2(
                    c,-s,
                    s, c
                );
                rotUV = mul(rotMatrix,rotUV);
                rotUV += 0.5;
                OUT.uv.zw = rotUV;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 col = tex2D(_BaseMap, IN.uv.xy);
                float2 newUV = IN.uv.zw * 2 - 1;
                float radial = atan2(newUV.y,newUV.x)/(PI);
                radial = radial * 0.5 + 0.5;
                float reveal = smoothstep(radial - _Feathering, radial + _Feathering,frac(_Time*3));
                return half4(col.rgba*reveal);
            }
            ENDHLSL
        }
    }
}
