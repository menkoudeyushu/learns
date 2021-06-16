Shader "Unlit/URPAnimationTwist"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       AnimatedTwistUV_AnimatedTwistUV_Bend_1("AnimatedTwistUV_AnimatedTwistUV_Bend_1", Range(-1, 1)) = 0.354
       AnimatedTwistUV_AnimatedTwistUV_PosX_1("AnimatedTwistUV_AnimatedTwistUV_PosX_1", Range(-1, 2)) = 0.5
       AnimatedTwistUV_AnimatedTwistUV_PosY_1("AnimatedTwistUV_AnimatedTwistUV_PosY_1", Range(-1, 2)) = 0.5
       AnimatedTwistUV_AnimatedTwistUV_Radius_1("AnimatedTwistUV_AnimatedTwistUV_Radius_1", Range(0, 1)) = 0.5
       AnimatedTwistUV_AnimatedTwistUV_Speed_1("AnimatedTwistUV_AnimatedTwistUV_Speed_1", Range(-10, 10)) = 2.679
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
            float _SpriteFade;
            float AnimatedTwistUV_AnimatedTwistUV_Bend_1;
            float AnimatedTwistUV_AnimatedTwistUV_PosX_1;
            float AnimatedTwistUV_AnimatedTwistUV_PosY_1;
            float AnimatedTwistUV_AnimatedTwistUV_Radius_1;
            float AnimatedTwistUV_AnimatedTwistUV_Speed_1;
            float _LerpUV_Fade_1;
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
                    
                 
            float2 AnimatedTwistUV(float2 uv, float value, float posx, float posy, float radius, float speed)
            {
                float2 center = float2(posx, posy);
                float2 tc = uv - center;
                float dist = length(tc);
                // 距离中心（旋转UV） 的半径
                if (dist < radius)
                {
                float percent = (radius - dist) / radius;
                float theta = percent * percent * 16.0 * sin(value);
                float s = sin(theta + _Time.y * speed);
                float c = cos(theta + _Time.y * speed);
                tc = float2(dot(tc, float2(c, -s)), dot(tc, float2(s, c)));
                }
                tc += center;
                return tc;
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
                // sampler.
                float2 AnimatedTwistUV_1 = AnimatedTwistUV(IN.texcoord,AnimatedTwistUV_AnimatedTwistUV_Bend_1,AnimatedTwistUV_AnimatedTwistUV_PosX_1,AnimatedTwistUV_AnimatedTwistUV_PosY_1,AnimatedTwistUV_AnimatedTwistUV_Radius_1,AnimatedTwistUV_AnimatedTwistUV_Speed_1);
                IN.texcoord = lerp(IN.texcoord,AnimatedTwistUV_1,_LerpUV_Fade_1);
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
