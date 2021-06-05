Shader "Unlit/2Doutline"
{
   Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _lineWidth("lineWidth",Range(0,10)) = 1
        _lineColor("lineColor",Color)=(1,1,1,1)
    }
    // ---------------------------【子着色器】---------------------------
    SubShader
    {
        // 渲染队列采用 透明
        Tags{
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            }
        //Blend SrcAlpha OneMinusSrcAlpha


            
        Pass
        {
            HLSLINCLUDE
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _lineWidth;
            half4 _lineColor;
            CBUFFER_END

            TEXTURE2D(_MainTex);//在CG中会写成sampler2D _BaseMap;
            SAMPLER(sampler_MainTex);

            //顶点着色器输入结构体 
            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            //顶点着色器输出结构体 
            struct VertexOutput
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // ---------------------------【顶点着色器】---------------------------
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            // ---------------------------【片元着色器】---------------------------
            fixed4 frag (VertexOutput i) : SV_Target
            {
                fixed4 col = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv);
                // 采样周围4个点
                float2 up_uv = i.uv + float2(0,1) * _lineWidth * _MainTex_ST.xy;
                float2 down_uv = i.uv + float2(0,-1) * _lineWidth * _MainTex_ST.xy;
                float2 left_uv = i.uv + float2(-1,0) * _lineWidth * _MainTex_ST.xy;
                float2 right_uv = i.uv + float2(1,0) * _lineWidth * _MainTex_ST.xy;
                // 如果有一个点透明度为0 说明是边缘
                float w = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,up_uv).a * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,down_uv).a * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,left_uv).a * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,right_uv).a;

                // if(w == 0){
                    //    col.rgb = _lineColor;
                // }
                // 和原图做插值
                col.rgb = lerp(_lineColor,col.rgb,w);
                return col;
            }
            ENDHLSL
        }
    }
}
