class_name EndingResolver
extends RefCounted
## Demo ending resolver (Paradise / Blaze / Incomplete / Tie).
## Spec: docs/ENDING_RESOLVER_LOGIC_CN.md v2
## Dims 0–100. Hero (F) is capped and cannot alone force Paradise.

const E_MIN := 35.0
const TIE_BAND := 8.0
const F_CAP := 55.0
const V_FLOOR := 20.0
const A_FLOOR := 20.0

const END_INCOMPLETE := "incomplete"
const END_PARADISE := "paradise"
const END_BLAZE := "blaze"
const END_TIE := "tie"

static func estimate_dims(flags: Dictionary, knowledge_count: int = 0, aftermath_depth: int = 0) -> Dictionary:
	var A := 15.0
	var B := 5.0
	var C := 5.0
	var D := 0.0
	var E := 20.0
	var F := 0.0
	var V := 10.0
	if bool(flags.get("festival_helped", false)):
		B += 18.0
		V += 8.0
		E += 4.0
	if bool(flags.get("festival_offered_food", false)):
		B += 14.0
		A += 6.0
		V += 6.0
		E += 4.0
	if bool(flags.get("festival_refused", false)):
		B -= 8.0
		D += 14.0
		C += 6.0
		V -= 3.0
	if bool(flags.get("tendency_p_soft", false)):
		V += 6.0
		E += 4.0
	if bool(flags.get("tendency_t_soft", false)):
		C += 8.0
		D += 6.0
	for k in ["trace_home_bowl", "trace_commons_seat", "trace_shrine_flowers", "trace_path_scrap"]:
		if bool(flags.get(k, false)):
			C += 8.0
			E += 1.0
	if bool(flags.get("hero_met", false)):
		F += 18.0
		E += 3.0
	if bool(flags.get("hero_second_met", false)):
		F += 14.0
		C += 4.0
	if bool(flags.get("hero_offer_leave", false)):
		C += 10.0
		D += 8.0
		F += 6.0
	if bool(flags.get("hero_stay_watch", false)):
		V += 6.0
		E += 4.0
		F += 4.0
	if bool(flags.get("hero_ask_name", false)):
		C += 6.0
		F += 8.0
	C += mini(20.0, float(knowledge_count) * 2.0)
	E += mini(12.0, float(aftermath_depth) * 1.5)
	A += mini(15.0, float(knowledge_count))
	return {
		"A": clampf(A, 0.0, 100.0),
		"B": clampf(B, 0.0, 100.0),
		"C": clampf(C, 0.0, 100.0),
		"D": clampf(D, 0.0, 100.0),
		"E": clampf(E, 0.0, 100.0),
		"F": clampf(F, 0.0, 100.0),
		"V": clampf(V, 0.0, 100.0),
	}

static func resolve(dims: Dictionary, tie_choice: String = "") -> Dictionary:
	var A: float = float(dims.get("A", 0))
	var B: float = float(dims.get("B", 0))
	var C: float = float(dims.get("C", 0))
	var D: float = float(dims.get("D", 0))
	var E: float = float(dims.get("E", 0))
	var F: float = float(dims.get("F", 0))
	var V: float = float(dims.get("V", 0))
	if E < E_MIN:
		return {
			"id": END_INCOMPLETE,
			"label": "未完之日",
			"P": 0.0,
			"T": 0.0,
			"dims": dims,
			"text": (
				"日子还没攒够分量。\n"
				+ "有些灯没点亮，有些缝也还没被看见。\n"
				+ "现在还不是写下结尾的时候。"
			),
		}
	var F_eff: float = minf(F, F_CAP)
	var V_eff: float = V
	var P: float = (0.20 * A + 0.20 * B + 0.20 * V_eff + 0.12 * F_eff + 0.18 * E - 0.20 * C - 0.25 * D)
	var T: float = (0.30 * C + 0.30 * D + 0.15 * E + 0.10 * A - 0.12 * B - 0.12 * V_eff - 0.10 * F_eff)
	if F >= 40.0 and V < V_FLOOR and A < A_FLOOR:
		P *= 0.7
	P = maxf(0.0, P)
	T = maxf(0.0, T)
	if absf(P - T) < TIE_BAND:
		if tie_choice == END_PARADISE:
			return _pack(END_PARADISE, P, T, dims, true)
		if tie_choice == END_BLAZE:
			return _pack(END_BLAZE, P, T, dims, true)
		return {
			"id": END_TIE,
			"label": "临界",
			"P": P,
			"T": T,
			"dims": dims,
			"text": (
				"两种结局几乎一样近。\n"
				+ "一边是灯还亮着的桌子，一边是被整理干净的名单缝。\n\n"
				+ "需要你自己选：留下，或把缝看穿。"
			),
		}
	if P > T:
		return _pack(END_PARADISE, P, T, dims, false)
	return _pack(END_BLAZE, P, T, dims, false)

static func _pack(id: String, P: float, T: float, dims: Dictionary, from_tie: bool) -> Dictionary:
	var label := "永恒乐园" if id == END_PARADISE else "烈火天罚"
	var text := ""
	if id == END_PARADISE:
		text = (
			"日子把我按进一张还有空位的桌边。\n"
			+ "灯没灭。碗还会再添一次。\n"
			+ "有人叫我的名字时，声音是熟的。\n\n"
			+ "这不一定是奖赏。\n"
			+ "更像是：被允许继续留在「好」这一侧。"
		)
		if from_tie:
			text += "\n\n（你在临界处选择了留下。）"
	else:
		text = (
			"名单上的字被热风吹薄。\n"
			+ "有些爱太满，满到要把缝烫平。\n"
			+ "我看清了桌子怎么摆，也看清了谁不能坐。\n\n"
			+ "离开时没有鼓声。\n"
			+ "只有一种干净得近乎残忍的清楚。"
		)
		if from_tie:
			text += "\n\n（你在临界处选择了看穿。）"
	return {"id": id, "label": label, "P": P, "T": T, "dims": dims, "text": text}

static func soft_preview_line(dims: Dictionary) -> String:
	var r: Dictionary = resolve(dims)
	var id: String = str(r.get("id", ""))
	if id == END_INCOMPLETE:
		return "日子还轻"
	if id == END_TIE:
		return "两端几乎一样近"
	if id == END_PARADISE:
		return "灯这一侧更近"
	if id == END_BLAZE:
		return "缝这一侧更近"
	return ""
