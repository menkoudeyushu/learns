Shader "Unlit/URPOutline"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _Outline_Size_1("_Outline_Size_1", Range(1, 16)) = 1
        _Outline_Color_1("_Outline_Color_1", COLOR) = (1,1,1,1)
        _Outline_HDR_1("_Outline_HDR_1", Range(0, 2)) = 1
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
            float _Outline_Size_1;
            float4 _Outline_Color_1;
            float _Outline_HDR_1;
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

            float4 OutLine(float2 uv,float value, float4 color, float HDR)
            {

                value*=0.01;
                float4 mainColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv + float2(-value, value))
                + SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + float2(value, -value))
                + SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv + float2(value, value))
                + SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, uv - float2(value, value));

                color *= HDR;
                mainColor.rgb = color;
                float4 addcolor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);
                if (mainColor.a > 0.40) { mainColor = color; }
                if (addcolor.a > 0.40) { mainColor = addcolor; mainColor.a = addcolor.a; }
                return mainColor;
            }
            

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float4 _Outline_1 = OutLine(IN.texcoord,_Outline_Size_1,_Outline_Color_1,_Outline_HDR_1);
                float4 FinalResult = _Outline_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
