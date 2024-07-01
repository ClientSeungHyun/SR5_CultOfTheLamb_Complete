// 사용할 전역변수들
float4x4 g_WorldMatrix, g_ViewMatrix, g_ProjMatrix;
texture g_Texture;


sampler2D DiffuseSampler = sampler_state
{
    texture = g_Texture;
    MINFILTER = linear;
    MAGFILTER = linear;
    MIPFILTER = linear;
};

struct VS_IN
{
    float3 vPosition : POSITION;
    float2 vTextCoord : TEXCOORD0;
};

struct VS_OUT
{
    float4 vPosition : POSITION;
    float2 vTextCoord : TEXCOORD0;
    float3 vWorldPosition : TEXCOORD1;
};

VS_OUT VS_MAIN(VS_IN In)
{
    VS_OUT Out;

    // 월드뷰, 월드뷰투영 행렬을 구해두고 한 번에 곱할 용도
    matrix WorldView, WorldViewProjection;

    WorldView = mul(g_WorldMatrix, g_ViewMatrix);
    WorldViewProjection = mul(WorldView, g_ProjMatrix);

    Out.vPosition = mul(float4(In.vPosition, 1.f), WorldViewProjection);
    Out.vTextCoord = In.vTextCoord;
    Out.vWorldPosition = mul(float4(In.vPosition, 1.f), g_WorldMatrix).xyz;

    return Out;
}

// VS_OUT 정보를 그대로 받아옴
struct PS_IN
{
    float4 vPosition : POSITION;
    float2 vTextCoord : TEXCOORD0;
    float3 vWorldPosition : TEXCOORD1;
};

// 픽셀의 색을 반환할거임
struct PS_OUT
{
    float4 vColor : COLOR0;
};

// 화면에 출력될 색상을 결정함
PS_OUT PS_MAIN(PS_IN In)
{
    PS_OUT Out;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    return Out;
}

PS_OUT PS_OPEN(PS_IN In)
{
    PS_OUT Out;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    Out.vColor.rgb = 0.f;
    
    return Out;
}

PS_OUT PS_CLOSE(PS_IN In)
{
    PS_OUT Out;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    
    return Out;
}


technique UITechnique
{
    pass UIPass
    {
        AlphaTestEnable = TRUE;
        AlphaFunc = greater;
        AlphaRef = 40;
        CULLMODE = NONE;
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_MAIN();
    }

    pass Open
    {
        AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 50;
        CULLMODE = NONE;
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_OPEN();
    }

    pass Close
    {
        AlphaTestEnable = true;
        AlphaFunc = greater;
        AlphaRef = 50;
        CULLMODE = NONE;
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_CLOSE();
    }

}