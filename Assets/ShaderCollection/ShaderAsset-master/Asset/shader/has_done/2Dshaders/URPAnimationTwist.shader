Shader "Unlit/URPAnimationTwist"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _AnimatedBurn_Offset("_AnimatedBurn_Offset", Range(-1, 1)) =0
       _AnimatedBurn_Fade("_AnimatedBurn_Fade", Range(0, 1)) =1
       _AnimatedBurn_Speed("_AnimatedBurn_Speed", Range(-2, 2)) =0.465
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
            float _AnimatedBurn_Offset;
            float _AnimatedBurn_Fade;
            float _AnimatedBurn_Speed;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                // 2D物体的顶点颜色
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
                    
                 
            float4 Color_PreGradients(float4 rgba, float4 a, float4 b, float4 c, float4 d, float offset, float fade, float speed)
            {
                float gray = (rgba.r + rgba.g + rgba.b) / 3;
                gray += offset+(speed*_Time*20);
                float4 result = a + b * cos(6.28318 * (c * gray + d));
                result.a = rgba.a;
                result.rgb = lerp(rgba.rgb, result.rgb, fade);
                return result;
            }

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

            // 顶点着色器的颜色 * 片元采样后的颜色
            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 _PremadeGradients_1 = Color_PreGradients(_MainTex_1,float4(1,0,0.13,1),float4(0.42,0.95,0,1),float4(0.99,0.68,0.99,1),float4(0.39,0.39,1,1),_AnimatedBurn_Offset,_AnimatedBurn_Fade,_AnimatedBurn_Speed);
                float4 FinalResult = _PremadeGradients_1;
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
