Shader "Unlit/URPShake"
{
   Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       Offset_X("Offset_X", Range(0, 0.05)) = 0
        Offset_Y("Offset_Y", Range(0, 0.05)) = 0.004
        Intensity_X("Intensity_X", Range(-3, 3)) = 1
        Intensity_Y("Intensity_Y", Range(-3, 3)) = 1
        Speed("Speed", Range(-1, 1)) = 0.161
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
            float Offset_X;
            float Offset_Y;
            float Intensity_X;
            float Intensity_Y;
            float Speed;
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

            float2 AnimatedShakeUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy, float speed)
            {
                float time = sin(_Time * speed * 5000 * zoomx);
                float time2 = sin(_Time * speed * 5000 * zoomy);
                // 每个UV 坐标的相对偏移量
                uv += float2(offsetx * time, offsety * time2);
                return uv;
            }
            

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float2 AnimatedShakeUV_1 = AnimatedShakeUV(IN.texcoord,Offset_X,Offset_Y,Intensity_X,Intensity_Y,Speed);
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,AnimatedShakeUV_1);
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
