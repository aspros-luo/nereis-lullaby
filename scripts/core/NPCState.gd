class_name NPCState
extends Resource


# ==================================================
# 永久状态
# 
# 影响：
# - NPC支线
# - 主线条件
# - 结局
#
# 永久保存
# ==================================================

var permanent:Dictionary = {


	"trust":0,          # 信任度

	"fear":0,           # 恐惧度

	"memory":0,         # 记忆相关

	"quest":0,          # 任务进度

	"alive":true        # 是否存活

}





# ==================================================
# 临时状态
#
# 每天重置
#
# 影响：
# - 当天交流
# - 当天行为
# - 夜晚结算
#
# ==================================================

var temporary:Dictionary = {


	"talk_count":0,     # 今日聊天次数


	"drink_count":0,    # 今日饮酒次数


	"drunk":false,      # 是否喝醉


	"mood":0            # 今日心情

}





# ==================================================
# 每日重置
# ==================================================

func reset_daily():


	temporary["talk_count"]=0

	temporary["drink_count"]=0

	temporary["drunk"]=false

	temporary["mood"]=0
