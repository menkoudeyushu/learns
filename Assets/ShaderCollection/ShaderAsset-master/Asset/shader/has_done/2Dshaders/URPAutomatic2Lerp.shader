Shader "Unlit/URPAutomatic2Lerp"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _NewTex_1("NewTex_1(RGB)", 2D) = "white" {}
       _AutomaticLerp_Speed_1("_AutomaticLerp_Speed_1", Range(0, 1)) = 1
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
            float4 _NewTex_1_ST;
            float _SpriteFade;
            float _AutomaticLerp_Speed_1;
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

            TEXTURE2D(_NewTex_1);
            SAMPLER(sampler_NewTex_1);

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
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 NewTex_1 = SAMPLE_TEXTURE2D(_NewTex_1,sampler_NewTex_1,IN.texcoord);
                float _AutomaticLerp_Fade_1 = (1 + cos(_Time.y * 4 * _AutomaticLerp_Speed_1)) / 2;
                _MainTex_1.rgb = lerp(_MainTex_1.rgb, NewTex_1.rgb, 1-_MainTex_1.a);
                NewTex_1.rgb = lerp(_MainTex_1.rgb, NewTex_1.rgb, NewTex_1.a);
                _MainTex_1 = lerp(_MainTex_1, NewTex_1, _AutomaticLerp_Fade_1);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }  
}
