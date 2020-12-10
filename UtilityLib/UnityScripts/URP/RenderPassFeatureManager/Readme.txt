这是一个动态添加RenderPassFeature到urp的小框架.

1 创建Feature asset.
	1 选择RendererFeatures所在的目录.
	2 点击 URP/Instance ScriptableRendererFeatures From Selection Folders.
	创建的assets存放于URPFeatureAssets
	
2 添加RenderPassFeatureManager到ForwardRenderer
	展开featherList,加入1创建的featherAssets
	
3 RendererFeature中的settings字段将显示设置,可以基础BaseSettings
	参考RendererFeaturesManager