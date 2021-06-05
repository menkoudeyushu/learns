Shader "Unlit/NewURPVintage"
{
    // The _BaseMap variable is visible in the Material's Inspector, as a field
    // called Base Map.
    Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
        _ColorFilters_Fade_1("_ColorFilters_Fade_1",Range(0,10)) = 1
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
            float _ColorFilters_Fade_1;
            float _SpriteFade;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 uv           : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 uv           : TEXCOORD0;
                float4 color    : COLOR;

            };

            float4 ColorFilters(float4 rgba, float4 red, float4 green, float4 blue, float fade)
            {
            float3 c_r = float3(red.r, red.g, red.b);
            float3 c_g = float3(green.r, green.g, green.b);
            float3 c_b = float3(blue.r, blue.g, blue.b);
            float4 r = float4(dot(rgba.rgb, c_r) + red.a, dot(rgba.rgb, c_g) + green.a, dot(rgba.rgb, c_b) + blue.a, rgba.a);
            return lerp(rgba, saturate(r), fade);
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
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                half4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float4 _ColorFilters_1 = ColorFilters(_MainTex_1,float4(2,1.09,-1.04,-0.48),float4(0.42,1.26,-0.01,-0.2),float4(-0.4,1.21,-0.31,0.12),_ColorFilters_Fade_1);
                float4 FinalResult = _ColorFilters_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
