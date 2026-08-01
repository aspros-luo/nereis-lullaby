extends Node


#
# 世界状态管理
#
# 保存所有影响剧情走向的全局变量
#
# 注意：
# 这里不要保存NPC个人状态
# NPC状态由NPCManager负责
#


var values:Dictionary = {


	#
	# 村庄整体腐化程度
	#
	# 来源:
	# - 外神饮品
	# - 邪教事件
	# - 特殊选择
	#
	# 影响:
	# - 村民变化
	# - 后期事件
	# - 结局分支
	#
	"village_corruption":0,



	#
	# 外神降临进度
	#
	# 表示蜜忒作为代理人
	# 对外神力量的推进程度
	#
	# 影响:
	# - 特殊事件
	# - 最终结局
	#
	"outer_god_progress":0,



	#
	# 教会真相揭露程度
	#
	# 表示玩家接触世界真相的程度
	#
	# 影响:
	# - 世界观剧情
	# - 隐藏路线
	#
	"church_truth":0,



	#
	# 原男主记忆恢复程度
	#
	# 影响:
	# - 主线推进
	# - 真相结局
	#
	"hero_memory":0,



	#
	# 原男主人性值
	#
	# 初始100
	#
	# 降低:
	# - 腐化
	# - 错误选择
	#
	# 影响:
	# - 最终状态
	#
	"hero_humanity":100,



	#
	# 蜜忒人性值
	#
	# 表示代理人在长期影响中的变化
	#
	# 影响:
	# - 蜜忒自身结局
	#
	"mite_humanity":100

}



#
# 增加数值
#
func add_value(
	key:String,
	value:int
):

	if values.has(key):

		values[key]+=value



#
# 获取数值
#
func get_value(
	key:String
):

	return values.get(key,0)



#
# 设置数值
#
func set_value(
	key:String,
	value
):

	values[key]=value



#
# 重置游戏状态
#
# 新游戏使用
#
func reset():

	values = {

		"village_corruption":0,

		"outer_god_progress":0,

		"church_truth":0,

		"hero_memory":0,

		"hero_humanity":100,

		"mite_humanity":100

	}



#
# 调试输出
#
func debug_print():

	print("================")

	print(values)

	print("================")
