Shader "Unlit/NewTurnGold"
{
     Properties
    { 
       _MainTex("Sprite Texture", 2D) = "white" {}
        _TurnGold_Speed_1("_TurnGold_Speed_1", Range(-8, 8)) = 1    
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
            float _TurnGold_Speed_1;
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

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 ColorTurnGold(float2 uv,float speed)
            {
                float4 txt1=SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);
                float lum = dot(txt1.rgb, float3 (0.2126, 0.2152, 0.4722));
                float3 metal = float3(lum,lum,lum);
                metal.r = lum * pow(1.46*lum, 4.0);
                metal.g = lum * pow(1.46*lum, 4.0);
                metal.b = lum * pow(0.86*lum, 4.0);
                float2 tuv = uv;
                uv *= 2.5;
                float time = (_Time/4)*speed;
                float a = time * 50;
                float n = sin(a + 2.0 * uv.x) + sin(a - 2.0 * uv.x) + sin(a + 2.0 * uv.y) + sin(a + 5.0 * uv.y);
                n = fmod(((5.0 + n) / 5.0), 1.0);
                n += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,tuv).r * 0.21 + SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,tuv).g * 0.4 + SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,tuv).b * 0.2;
                n=fmod(n,1.0);
                float tx = n * 6.0;
                float r = clamp(tx - 2.0, 0.0, 1.0) + clamp(2.0 - tx, 0.0, 1.0);
                float4 sortie=float4(1.0, 1.0, 1.0,r);
                sortie.rgb=metal.rgb+(1-sortie.a);
                sortie.rgb=sortie.rgb/2+dot(sortie.rgb, float3 (0.1126, 0.4552, 0.1722));
                sortie.rgb-=float3(0.0,0.1,0.45);
                sortie.rg+=0.025;
                sortie.a=txt1.a;
                return sortie; 
            }

            // This macro declares _BaseMap as a Texture2D object.
            // This macro declares the sampler for the _BaseMap texture.

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
                float4 _TurnGold_1 = ColorTurnGold(IN.texcoord,_TurnGold_Speed_1);
                float4 FinalResult = _TurnGold_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
