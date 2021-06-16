Shader "Unlit/URPShinyFx"
{
    Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
       _ShinyFX_Pos_1("_ShinyFX_Pos_1", Range(-1, 1)) = 0
        _ShinyFX_Size_1("_ShinyFX_Size_1", Range(-1, 1)) = -0.1
        _ShinyFX_Smooth_1("_ShinyFX_Smooth_1", Range(0, 1)) = 0.25
        _ShinyFX_Intensity_1("_ShinyFX_Intensity_1", Range(0, 4)) = 1
        _ShinyFX_Speed_1("_ShinyFX_Speed_1", Range(0, 8)) = 1
        _SpriteFade("SpriteFade", Range(0, 1)) = 1.0
        _FlashColor("falsh_colro",Color) = (1.0,1.0,1.0,1.0)
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
            float _ShinyFX_Pos_1;
            float _ShinyFX_Size_1;
            float _ShinyFX_Smooth_1;
            float _ShinyFX_Intensity_1;
            float _ShinyFX_Speed_1;
            float4 _FlashColor;
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

            float4 ShinyFX(float4 txt, float2 uv, float pos, float size, float smooth, float intensity, float speed)
            {
                pos = pos + 0.5+sin(_Time*20*speed)*0.5;
                uv = uv - float2(pos, 0.5);
                float a = atan2(uv.x, uv.y) + 1.4, r = 3.1415;
                float d = cos(floor(0.5 + a / r) * r - a) * length(uv);
                float dist = 1.0 - smoothstep(size, size + smooth, d);
                txt.rgb += dist*intensity*_FlashColor;
                return txt;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 _ShinyFX_1 = ShinyFX(_MainTex_1,IN.texcoord,_ShinyFX_Pos_1,_ShinyFX_Size_1,_ShinyFX_Smooth_1,_ShinyFX_Intensity_1,_ShinyFX_Speed_1);
                float4 FinalResult = _ShinyFX_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
