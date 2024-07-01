// ����� ����������
float4x4 g_WorldMatrix, g_ViewMatrix, g_ProjMatrix;
texture g_Texture;

float g_fFadeAlpha;
float g_fTotalColor;

float   g_fAlpha;

float3   g_fColor = {1.f,1.f,1.f};


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

    // �����, ��������� ����� ���صΰ� �� ���� ���� �뵵
    matrix WorldView, WorldViewProjection;

    WorldView = mul(g_WorldMatrix, g_ViewMatrix);
    WorldViewProjection = mul(WorldView, g_ProjMatrix);

    Out.vPosition = mul(float4(In.vPosition, 1.f), WorldViewProjection);
    Out.vTextCoord = In.vTextCoord;
    Out.vWorldPosition = mul(float4(In.vPosition, 1.f), g_WorldMatrix).xyz;

    return Out;
}

// VS_OUT ������ �״�� �޾ƿ�
struct PS_IN
{
    float4 vPosition : POSITION;
    float2 vTextCoord : TEXCOORD0;
    float3 vWorldPosition : TEXCOORD1;
};

// �ȼ��� ���� ��ȯ�Ұ���
struct PS_OUT
{
    float4 vColor : COLOR0;
};

// ȭ�鿡 ��µ� ������ ������
PS_OUT PS_MAIN(PS_IN In)
{
    PS_OUT Out;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    return Out;
}

PS_OUT PS_BlendExample(PS_IN In)
{
    PS_OUT Out = (PS_OUT) 0;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    Out.vColor.a *= g_fAlpha;

    return Out;
}

PS_OUT PS_BlendSetAlpha(PS_IN In)
{
    PS_OUT Out = (PS_OUT) 0;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    Out.vColor.a = g_fFadeAlpha;
    return Out;
}

PS_OUT PS_BlendBlink(PS_IN In)
{
    PS_OUT Out = (PS_OUT) 0;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    Out.vColor.rgb = g_fTotalColor;
    Out.vColor.a = g_fFadeAlpha;
    
    return Out;
}


PS_OUT PS_BlendMonoPanel(PS_IN In)
{
    PS_OUT Out = (PS_OUT)0;
    Out.vColor = tex2D(DiffuseSampler, In.vTextCoord);
    Out.vColor.a *= g_fAlpha;


    Out.vColor.r *= g_fColor.x;
    Out.vColor.g *= g_fColor.y;
    Out.vColor.b *= g_fColor.z;

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

    pass BlendExample
    {
        AlphablendEnable = true;    //���ĺ��� Ȱ��ȭ
        SrcBlend = SrcAlpha;        //�ҽ��� ���� ������
        DestBlend = InvSrcAlpha;    //����Ʈ�� ���Ĵ� 1-�ҽ�
        BlendOp = Add;              // ���ؼ� ������
        CULLMODE = NONE;            // �޸鵵 ��������
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_BlendExample();
    }

    pass BlendSetAlpha
    {
        AlphablendEnable = true; //���ĺ��� Ȱ��ȭ
        SrcBlend = SrcAlpha; //�ҽ��� ���� ������
        DestBlend = InvSrcAlpha; //����Ʈ�� ���Ĵ� 1-�ҽ�
        BlendOp = Add; // ���ؼ� ������
        CULLMODE = NONE; // �޸鵵 ��������
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_BlendSetAlpha();
    }

    pass BlendBlink
    {
        AlphablendEnable = true; //���ĺ��� Ȱ��ȭ
        SrcBlend = SrcAlpha; //�ҽ��� ���� ������
        DestBlend = InvSrcAlpha; //����Ʈ�� ���Ĵ� 1-�ҽ�
        BlendOp = Add; // ���ؼ� ������
        CULLMODE = NONE; // �޸鵵 ��������
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_BlendBlink();
    }


    pass BlendMonoPanel
    {
        AlphablendEnable = true;    //���ĺ��� Ȱ��ȭ
        SrcBlend = SrcAlpha;        //�ҽ��� ���� ������
        DestBlend = InvSrcAlpha;    //����Ʈ�� ���Ĵ� 1-�ҽ�
        BlendOp = Add;              // ���ؼ� ������
        CULLMODE = NONE;            // �޸鵵 ��������
        VertexShader = compile vs_3_0 VS_MAIN();
        PixelShader = compile ps_3_0 PS_BlendMonoPanel();
    }

}