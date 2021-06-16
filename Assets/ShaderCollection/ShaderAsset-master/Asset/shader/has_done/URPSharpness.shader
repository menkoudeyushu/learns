Shader "Unlit/URPSharpness"
{
     Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
       _Sharpness_Angle_1("_Sharpness_Angle_1", Range(-1, 1)) = 0.25
       _Sharpness_Distance_1("_Sharpness_Distance_1", Range(0, 16)) = 2.257
       _Sharpness_Intensity_1("_Sharpness_Intensity_1", Range(-2, 2)) = 0.279
       _Sharpness_Fade_1("_Sharpness_Fade_1", Range(-2, 2)) = 1
       _Sharpness_original_1("_Sharpness_original_1", Range(-2, 2)) = 1
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
            float _SpriteFade;
            float _Sharpness_Angle_1;
            float _Sharpness_Distance_1;
            float _Sharpness_Intensity_1;
            float _Sharpness_Fade_1;
            float _Sharpness_original_1;
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

            float4 Sharpness(float2 uv, float angle, float dist, float intensity, float g, float o)
            { 
                angle = angle *3.1415926;
                intensity = intensity *0.25;
                #define rot(n) mul(n, float2x2(cos(angle), -sin(angle), sin(angle), cos(angle)))
                float m1 = 0; float m2 = -1; float m3 = 0;
                float m4 = -1; float m5 =  5; float m6 = -1;
                float m7 = 0; float m8 = -1; float m9 = 0;
                float Offset = 0.5;
                float Scale = 1;
                float4 r = float4(0, 0, 0, 0);
                dist = dist * 0.005;
                float4 rgb = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv + rot(float2(-dist, -dist))) * m1*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(0, -dist))) * m2*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(dist, -dist))) * m3*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(-dist, 0))) * m4*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(0, 0))) * m5*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(dist, 0))) * m6*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(-dist, dist))) * m7*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(0, dist))) * m8*intensity;
                r += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + rot(float2(dist, dist))) * m9*intensity;
                r = lerp(r,dot(r.rgb,3),g);
                r = lerp(r+0.5,rgb+r,o);
                r = saturate(r);
                r.a = rgb.a;
            return r;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                //float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 _Sharpness_1 = Sharpness(IN.texcoord,_Sharpness_Angle_1,_Sharpness_Distance_1,_Sharpness_Intensity_1,_Sharpness_Fade_1,_Sharpness_original_1);
                float4 FinalResult = _Sharpness_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
