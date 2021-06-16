Shader "Unlit/URPAnimated_Pingpong"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       AnimatedPingPongOffsetUV_1_OffsetX_1("AnimatedPingPongOffsetUV_1_OffsetX_1", Range(-1, 1)) = 0.182
       AnimatedPingPongOffsetUV_1_OffsetY_1("AnimatedPingPongOffsetUV_1_OffsetY_1", Range(-1, 1)) = 0
       AnimatedPingPongOffsetUV_1_ZoomX_1("AnimatedPingPongOffsetUV_1_ZoomX_1", Range(1, 10)) = 1
       AnimatedPingPongOffsetUV_1_ZoomY_1("AnimatedPingPongOffsetUV_1_ZoomY_1", Range(1, 10)) = 1
       AnimatedPingPongOffsetUV_1_Speed_1("AnimatedPingPongOffsetUV_1_Speed_1", Range(-1, 1)) = 0.354
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
            float AnimatedPingPongOffsetUV_1_OffsetX_1;
            float AnimatedPingPongOffsetUV_1_OffsetY_1;
            float AnimatedPingPongOffsetUV_1_ZoomX_1;
            float AnimatedPingPongOffsetUV_1_ZoomY_1;
            float AnimatedPingPongOffsetUV_1_Speed_1;
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
                    
                 
            float2 AnimatedPingPongOffsetUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy, float speed)
            {
                float time = sin(_Time * 100* speed)  * 0.1;
                // 不明所以
                speed *= time * 25;
                uv += float2(offsetx, offsety)*speed;
                uv = uv * float2(zoomx, zoomy);
                return uv;
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
                float2 AnimatedPingPongOffsetUV_1 = AnimatedPingPongOffsetUV(IN.texcoord,AnimatedPingPongOffsetUV_1_OffsetX_1,AnimatedPingPongOffsetUV_1_OffsetY_1,AnimatedPingPongOffsetUV_1_ZoomX_1,AnimatedPingPongOffsetUV_1_ZoomY_1,AnimatedPingPongOffsetUV_1_Speed_1);
                IN.texcoord = lerp(IN.texcoord,AnimatedPingPongOffsetUV_1,_LerpUV_Fade_1);
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
