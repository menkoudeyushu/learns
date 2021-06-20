Shader "Unlit/NewTwist"
{
   Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
        TwistUV_TwistUV_Bend_1("TwistUV_TwistUV_Bend_1", Range(-1, 1)) = 0.296
        TwistUV_TwistUV_PosX_1("TwistUV_TwistUV_PosX_1", Range(-1, 2)) = 0.5
        TwistUV_TwistUV_PosY_1("TwistUV_TwistUV_PosY_1", Range(-1, 2)) = 0.5
        TwistUV_TwistUV_Radius_1("TwistUV_TwistUV_Radius_1", Range(0, 1)) = 0.5
        _LerpUV_Fade_1("_LerpUV_Fade_1", Range(0, 1)) = 1
        _SpriteFade("SpriteFade", Range(0, 1)) = 1.0
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
            float TwistUV_TwistUV_Bend_1;
            float TwistUV_TwistUV_PosX_1;
            float TwistUV_TwistUV_PosY_1;
            float TwistUV_TwistUV_Radius_1;
            float _LerpUV_Fade_1;
            float _SpriteFade;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                float4 color    : COLOR;

            };

            float2 TwistUV(float2 uv, float value, float posx, float posy, float radius)
            {
            float2 center = float2(posx, posy);
            float2 tc = uv - center;
            float dist = length(tc);
            if (dist < radius)
            {
            float percent = (radius - dist) / radius;
            float theta = percent * percent * 16.0 * sin(value);
            float s = sin(theta);
            float c = cos(theta);
            tc = float2(dot(tc, float2(c, -s)), dot(tc, float2(s, c)));
            }
            tc += center;
            return tc;
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
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float2 TwistUV_1 = TwistUV(IN.texcoord,TwistUV_TwistUV_Bend_1,TwistUV_TwistUV_PosX_1,TwistUV_TwistUV_PosY_1,TwistUV_TwistUV_Radius_1);
                IN.texcoord = lerp(IN.texcoord,TwistUV_1,_LerpUV_Fade_1);
                half4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.texcoord);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
