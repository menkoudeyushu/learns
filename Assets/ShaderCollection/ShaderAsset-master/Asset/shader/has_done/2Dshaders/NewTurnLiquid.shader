Shader "Unlit/NewTurnLiquid"
{
    // The _BaseMap variable is visible in the Material's Inspector, as a field
    // called Base Map.
    Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
       WaveX("WaveX", Range(0, 2)) = 2
       WaveY("WaveY", Range(0, 2)) = 2
       DistanceX("DistanceX", Range(0, 1)) = 0.3
       DistanceY("DistanceY", Range(0, 1)) = 0.3
       Speed("Speed", Range(-2, 2)) = 1
       TurnLiquid_Value("TurnLiquid_Value", Range(0, 1)) = 1
       _SpriteFade("SpriteFade",Range(0, 1))= 1.0
    }

    SubShader
    {
        Tags { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "PreviewType"="Plane" 
            "CanUseSpriteAtlas"="True" 
            "RenderPipeline" = "UniversalPipeline"
             }
        ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _SpriteFade;
            float WaveX;
            float WaveY;
            float DistanceX;
            float DistanceY;
            float Speed;
            float TurnLiquid_Value;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS: POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;

            };


            float2 LiquidUV(float2 p, float WaveX, float WaveY, float DistanceX, float DistanceY, float Speed)
            { 
                Speed *= _Time * 100;
                float x = sin(p.y * 4 * WaveX + Speed);
                float y = cos(p.x * 4 * WaveY + Speed);
                x += sin(p.x)*0.1;
                y += cos(p.y)*0.1;
                x *= y;
                y *= x;
                x *= y + WaveY*8;
                y *= x + WaveX*8;
                p.x = p.x + x * DistanceX * 0.015;
                p.y = p.y + y * DistanceY * 0.015;
                return p;
            }

            // This macro declares _BaseMap as a Texture2D object.
            TEXTURE2D(_MainTex);
            // This macro declares the sampler for the _BaseMap texture.
            SAMPLER(sampler_MainTex);

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // The TRANSFORM_TEX macro performs the tiling and offset
                // transformation.
                OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 LiquidUV_1 = LiquidUV(IN.texcoord,WaveX,WaveY,DistanceX,DistanceY,Speed);
                IN.texcoord = lerp(IN.texcoord,LiquidUV_1,TurnLiquid_Value);
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                FinalResult.rgb *= FinalResult.a;
                FinalResult.a = saturate(FinalResult.a);
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
