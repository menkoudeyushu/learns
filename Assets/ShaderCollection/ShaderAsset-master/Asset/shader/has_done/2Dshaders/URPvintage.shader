Shader "Unlit/URP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorFilters_Fade_1("_ColorFilters_Fade_1",Range(0,10)) = 1
        _SpriteFade("SpriteFade",Range(0, 1))= 1.0
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        // 渲染队列采用 透明
        Tags{
            "Queue" = "Transparent"
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "PreviewType"="Plane" 
            "CanUseSpriteAtlas"="True" 
            "RenderPipeline" = "UniversalPipeline"
            }
        ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off
        //Blend SrcAlpha OneMinusSrcAlpha


            
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _ColorFilters_Fade_1;
            float _SpriteFade;
            CBUFFER_END

            TEXTURE2D(_MainTex);//在CG中会写成sampler2D _BaseMap;
            SAMPLER(sampler_MainTex);

            //顶点着色器输入结构体 
            struct Attributes
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };
            //顶点着色器输出结构体 
            struct Varyings
            {
                float2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
            };

            float4 ColorFilters(float4 rgba, float4 red, float4 green, float4 blue, float fade)
            {
            float3 c_r = float3(red.r, red.g, red.b);
            float3 c_g = float3(green.r, green.g, green.b);
            float3 c_b = float3(blue.r, blue.g, blue.b);
            float4 r = float4(dot(rgba.rgb, c_r) + red.a, dot(rgba.rgb, c_g) + green.a, dot(rgba.rgb, c_b) + blue.a, rgba.a);
            return lerp(rgba, saturate(r), fade);
            }

            // ---------------------------【顶点着色器】---------------------------
            Varyings vert (Attributes IN)
            {                      
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex)
                OUT.color = IN.color;
                return OUT;
            }
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag (VertexOutput i) : SV_Target
            {
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                float4 _ColorFilters_1 = ColorFilters(_MainTex_1,float4(2,1.09,-1.04,-0.48),float4(0.42,1.26,-0.01,-0.2),float4(-0.4,1.21,-0.31,0.12),_ColorFilters_Fade_1);
                float4 FinalResult = _ColorFilters_1;
                FinalResult.rgb *= i.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
