Shader "Custom/Holofoil_Shader"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _HoloMap("Holo Map", 2D) = "white" {}
        _Scale("Scale",float) = 1
        _Intensity("Intensity",float) = 1
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
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _BaseMap;
            sampler2D _HoloMap;
            float _Scale, _Intensity;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.viewDir = GetWorldSpaceViewDir(IN.positionOS.xyz);
                return OUT;
            }
            
            float3 Plasma(float2 uv, float o)
            {
                uv = uv * _Scale - _Scale/2;
                float t = o;
                float w1 = sin(uv.x + t);
                float w2 = sin(uv.y + t) + 0.5;
                float w3 = sin(uv.x + uv.y + t);
                
                float r = sin(sqrt(uv.x * uv.x + uv.y * uv.y) + t);
                float finalWave = w1+w2+w3+r;
                float3 finalValue =  float3(sin(finalWave * PI),cos(finalWave* PI),0);
                return finalValue * 0.5 + 0.5;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 foil = tex2D(_HoloMap, IN.uv);
                float2 newUV = IN.viewDir.xy + foil.xy;
                float3 plasma = Plasma(newUV,IN.viewDir.z)* _Intensity;
                half4 col = tex2D(_BaseMap, IN.uv);
                return half4(col.rgb + col.rgb * plasma.rgb,1);
            }
            ENDHLSL
        }
    }
}
