Shader "Unlit/URPAnimatedPingPongZoom"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       AnimatedZoomUV_AnimatedZoomUV_Zoom_1("AnimatedZoomUV_AnimatedZoomUV_Zoom_1", Range(0.2, 4)) = 1
       AnimatedZoomUV_AnimatedZoomUV_PosX_1("AnimatedZoomUV_AnimatedZoomUV_PosX_1", Range(-1, 2)) = 0.5
       AnimatedZoomUV_AnimatedZoomUV_PosY_1("AnimatedZoomUV_AnimatedZoomUV_PosY_1", Range(-1, 2)) = 0.5
       AnimatedZoomUV_AnimatedZoomUV_Intensity_1("AnimatedZoomUV_AnimatedZoomUV_Intensity_1", Range(0, 4)) = 0.5
       AnimatedZoomUV_AnimatedZoomUV_Speed_1("AnimatedZoomUV_AnimatedZoomUV_Speed_1", Range(-10, 10)) = 6.393
       _LerpUV_Fade_1("_LerpUV_Fade_1", Range(0, 1)) = 1
       _SpriteFade("SpriteFade", Range(0, 1)) = 1.00
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
            float AnimatedZoomUV_AnimatedZoomUV_Zoom_1;
            float AnimatedZoomUV_AnimatedZoomUV_PosX_1;
            float AnimatedZoomUV_AnimatedZoomUV_PosY_1;
            float AnimatedZoomUV_AnimatedZoomUV_Intensity_1;
            float AnimatedZoomUV_AnimatedZoomUV_Speed_1;
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



            float2 AnimatedZoomUV(float2 uv, float zoom, float posx, float posy, float radius, float speed)
            {
            float2 center = float2(posx, posy);
            uv -= center;
            zoom -= radius * 0.1;
            zoom += sin(_Time * speed * 20) * 0.1 * radius;
            uv = uv * zoom;
            uv += center;
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
                float2 AnimatedZoomUV_1 = AnimatedZoomUV(IN.texcoord,AnimatedZoomUV_AnimatedZoomUV_Zoom_1,AnimatedZoomUV_AnimatedZoomUV_PosX_1,AnimatedZoomUV_AnimatedZoomUV_PosY_1,AnimatedZoomUV_AnimatedZoomUV_Intensity_1,AnimatedZoomUV_AnimatedZoomUV_Speed_1);
                AnimatedZoomUV_1 = saturate(AnimatedZoomUV_1); 
                IN.texcoord = lerp(IN.texcoord,AnimatedZoomUV_1,_LerpUV_Fade_1);
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
