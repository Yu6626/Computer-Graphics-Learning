
## IUnknown接口类

DirectX11的API是由一系列的COM组件来管理的，里面前缀带I的接口类继承自`IUnknown`接口类

|           方法           |                                          描述                              |
|:------------------------:|:------------------------------------------------------------------------ :|
| IUnknown::AddRef         | 内部引用计数加1。在每次复制了一个这样的指针后，应当调用该方法以保证计数准确性        |
| IUnknown::QueryInterface | 查询该实例是否实现了另一个接口，如果存在则返回该接口的指针，并且对该接口的引用计数加1 |
| IUnknown::Release        | 内部引用数减1。只有当内部引用数到达0时才会真正释放                               |

而且使用最多的是第三种方法

	此外，我们必须用
	#define ReleaseCOM(x) { if(x){ x->Release(); x = nullptr; } }
	之类的宏来释放内存

+ 不过，根据提示，使用了`ComPtr`最好不要再使用`IUnknown接口类`

## 前提

使用该智能指针需要包含头文件`wrl/client.h`，并且智能指针类模板`ComPtr`位于名称空间`Microsoft::WRL`内。

## 使用方法

|              方法              |                                                             描述                                              |
|:------------------------------:|:------------------------------------------------------------------------------------------------------------:|
| ComPtr::Get                    | 该方法返回T*，并且不会触发引用计数加1，常用在COM组件接口的函数输入                                                    |
| ComPtr::GetAddressOf           | 该方法返回T**，常用在COM组件接口的函数输出                                                                        |
| ComPtr::Reset                  | 该方法对里面的实例调用Release方法，并将指针置为nullptr                                                             |
| ComPtr::ReleaseAndGetAddressOf | 该方法相当于先调用Reset方法，再调用GetAddressOf方法获取T**，常用在COM组件接口的函数输出，适用于实例可能会被反复构造的情况下 |
| ComPtr::As                     | 一个模板函数，可以替代IUnknown::QueryInterface的调用，需要传递一个ComPtr实例的地址                                   |

## 事关运算符

| 运算符  |                                描述                       |
|:------:|:---------------------------------------------------------:|
| &      | 相当于调用了ComPtr<T>::ReleaseAndGetAddressOf方法，不推荐使用 |
| ->     | 和裸指针的行为一致                                           |
| =      | 不要将裸指针指向的实例赋给它，若传递的是ComPtr的不同实例则发生交换 |
| ==和!= | 可以和nullptr，或者另一个ComPtr实例进行比较                    |

## 示例

	class D3DApp
	{
	public:
		D3DApp(HINSTANCE hInstance);              // 在构造函数的初始化列表应当设置好初始参数
		virtual ~D3DApp();
	
		HINSTANCE AppInst()const;                 // 获取应用实例的句柄
		HWND      MainWnd()const;                 // 获取主窗口句柄
		float     AspectRatio()const;             // 获取屏幕宽高比
	
		int Run();                                // 运行程序，进行游戏主循环
	
		                                        // 框架方法。客户派生类需要重载这些方法以实现特定的应用需求
		virtual bool Init();                      // 该父类方法需要初始化窗口和Direct3D部分
		virtual void OnResize();                  // 该父类方法需要在窗口大小变动的时候调用
		virtual void UpdateScene(float dt) = 0;   // 子类需要实现该方法，完成每一帧的更新
		virtual void DrawScene() = 0;             // 子类需要实现该方法，完成每一帧的绘制
		virtual LRESULT MsgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);
		// 窗口的消息回调函数
		protected:
		bool InitMainWindow();      // 窗口初始化
		bool InitDirect3D();        // Direct3D初始化
	
		void CalculateFrameStats(); // 计算每秒帧数并在窗口显示
	
	protected:
	
		HINSTANCE m_hAppInst;        // 应用实例句柄
		HWND      m_hMainWnd;        // 主窗口句柄
		bool      m_AppPaused;       // 应用是否暂停
		bool      m_Minimized;       // 应用是否最小化
		bool      m_Maximized;       // 应用是否最大化
		bool      m_Resizing;        // 窗口大小是否变化
		bool	  m_Enable4xMsaa;	 // 是否开启4倍多重采样
		UINT      m_4xMsaaQuality;   // MSAA支持的质量等级
	
	
		GameTimer m_Timer;           // 计时器
	
		// 使用模板别名(C++11)简化类型名
		template <class T>
		using ComPtr = Microsoft::WRL::ComPtr<T>;
		// Direct3D 11
		ComPtr<ID3D11Device> m_pd3dDevice;                    // D3D11设备
		ComPtr<ID3D11DeviceContext> m_pd3dImmediateContext;   // D3D11设备上下文
		ComPtr<IDXGISwapChain> m_pSwapChain;                  // D3D11交换链
		// Direct3D 11.1
		ComPtr<ID3D11Device1> m_pd3dDevice1;                  // D3D11.1设备
		ComPtr<ID3D11DeviceContext1> m_pd3dImmediateContext1; // D3D11.1设备上下文
		ComPtr<IDXGISwapChain1> m_pSwapChain1;                // D3D11.1交换链
		// 常用资源
		ComPtr<ID3D11Texture2D> m_pDepthStencilBuffer;        // 深度模板缓冲区
		ComPtr<ID3D11RenderTargetView> m_pRenderTargetView;   // 渲染目标视图
		ComPtr<ID3D11DepthStencilView> m_pDepthStencilView;   // 深度模板视图
		D3D11_VIEWPORT m_ScreenViewport;                      // 视口
	
		// 派生类应该在构造函数设置好这些自定义的初始参数
		std::wstring m_MainWndCaption;                       // 主窗口标题
		int m_ClientWidth;                                   // 视口宽度
		int m_ClientHeight;                                  // 视口高度
	};

