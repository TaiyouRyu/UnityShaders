Shader "Custom/Erosion_Shader"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _MaskTexture("Texture Mask", 2D) = "white" {}
        
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0
        [Range(0,1)]
        _RevealValue("Reveal %", Float) = 0
        _Feather("Feathering",float) = 0
        _ErosionColor("Erosion Color", Color) = (1,1,1,1)
        _ErosionSpeed("Speed",float) = 0
        _ErosionCurveOffset("CurveOffset",float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]
        
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
                float4 uv : TEXCOORD0;
            };
            
            sampler2D _BaseMap;
            sampler2D _MaskTexture;
            float _RevealValue;
            float _Feather,_ErosionSpeed,_ErosionCurveOffset;
            float4 _ErosionColor;
            

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float4 _MaskTexture_ST;
            CBUFFER_END

            Vert vert(Attributes IN)
            {
                Vert OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv.xy = TRANSFORM_TEX(IN.uv,_BaseMap);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv,_MaskTexture);
                return OUT;
            }

            half4 frag(Vert IN) : SV_Target
            {
                half4 col = tex2D(_BaseMap, IN.uv.xy);
                half4 mask = tex2D(_MaskTexture, IN.uv.zw);
                //For colorless version
                //float revealAmount = smoothstep(mask.r - _Feather, mask.r+_Feather, _RevealValue);
                //Unanimated version
                //float revealAmountTop = step(mask.r, _RevealValue +_Feather);
                float revealAmountTop = step(mask.r, (sin(_Time.y*_ErosionSpeed)+_ErosionCurveOffset)/2 +_Feather);
                float revealAmountBottom = step(mask.r, (sin(_Time.y*_ErosionSpeed)+_ErosionCurveOffset)/2 -_Feather);
                float revealAmountDifference = revealAmountTop - revealAmountBottom;
                float3 finalCol = lerp(col.rgb, _ErosionColor, revealAmountDifference);
                //return half4(revealAmountDifference.xxx,1);
                return half4(finalCol.rgb, col.a * revealAmountTop);
            }
            ENDHLSL
        }
    }
}