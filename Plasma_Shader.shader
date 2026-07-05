Shader "Custom/Plasma_Shader"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        _Scale("Scale",float) = 1
        _TimeScale("Time Scale",float) = 1
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

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _BaseMap;
            float _Scale, _TimeScale;

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }
            
            float3 Plasma(float2 uv)
            {
                uv = uv * _Scale - _Scale/2;
                float t = + _Time.y * _TimeScale;
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
                //half4 col = tex2D(_BaseMap, IN.uv);
                //float3 plasma = Plasma(IN.uv);
                //return half4(col.rgb,plasma.x);
                
                
                //Wiggle Entire Texture
                float3 plasma = Plasma(IN.uv);
                half4 col = tex2D(_BaseMap, IN.uv + plasma.rg * 0.03);
                return half4(col.rgb,1);
            }
            ENDHLSL
        }
    }
}
