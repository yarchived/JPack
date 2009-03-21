JPack 是一个小巧强大的背包整理插件
作者： 桂健雄、yleaf

___/特点\___

1. 快, JPack的整理非常快!
2. 自动,只能的堆叠. 如果你包里和银行有同样的物品, 插件会自动将背包内的物品存放当银行并进行堆叠.
3. 简单强大的设置, 见下文说明.
4. 迷你地图图标, 并且支持Data broker(你需要一个LDB显示插件)
(虽然有LDB支持了, 不过我还是希望背包插件来支持JPack. 现在已经有很多背包插件修改版了.)
(如果不需要此功能可以删除<plugins>文件夹.)


___/Usage\___

命令: /jpack OR /jp

/jp - 整理
/jp minimap OR mm - 打开/关闭小地图图标
/jp asc - 正序
/jp desc - 逆序
/jp deposit OR save - 存放至银行
/jp draw OR load - 从银行提取
/jp debug - 显示debug信息以获取物品分类情况
/jp nodebug - 关闭debug信息


___/排序\___

没有设置界面, 通过编辑lua文件来改变排序.

例子(你可以在以下目录找到更多<JPack\localization>):

JPACK_ORDER={"炉石","##坐骑","矿工锄","剥皮小刀","鱼竿","#鱼竿","#武器","#护甲",
"#武器##其它","#护甲##其它","#配方","#任务","##元素","##金属和矿石","##草药",
"#材料","##珠宝","#消耗品","##布料","#商品","##肉类","#","鱼油","灵魂碎片","#其它"}
JPACK_DEPOSIT={"##元素","##金属和矿石","#材料","##草药","#珠宝","#容器"}
JPACK_DRAW={"#任务"}

说明:
#XX			物品分类
##XX		子类别
#X##Y		X(类别) AND Y(子类别)
#			单个 '#', 插件会将在 '#' 之前的物品整理在 '#' 之后的物品之前

炉石			物品: [炉石]
#武器			分类为武器
##坐骑			子分类为坐骑
#护甲##其它		分类为武器, 子分类为其他

你可以安装一些小提示插件来获取物品分类, 例如yGravier或Engravings(都可以在wowinterface.com找到).

**你可以在 <JPackConfig.lua> 文件中写入你自己的排序. 它会在本地文件后载入, 你将会在游戏中使用自己写的排序.


___/其他\___

主页:			http://wow-jpack.googlecode.com/
更新日志:		http://code.google.com/p/wow-jpack/wiki/ChangeList

BUG提交/翻译提交: http://code.google.com/p/wow-jpack/issues/entry
