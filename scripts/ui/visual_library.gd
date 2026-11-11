class_name VisualLibrary
extends RefCounted
## Central art lookup for locations and portraits.
## Drop PNG/WebP under assets/; missing files fall back to solid colors / text.

const LOCATION_PATHS: Dictionary = {
	"HOME": "res://assets/locations/home.png",
	"COMMONS": "res://assets/locations/commons.png",
	"PATH": "res://assets/locations/path.png",
	"SHRINE": "res://assets/locations/shrine.png",
	"CLINIC": "res://assets/locations/clinic.png",
	"FOREST": "res://assets/locations/forest.png",
	"GROVE": "res://assets/locations/grove.png",
	"FESTIVAL": "res://assets/locations/festival.png",
}

const LOCATION_COLORS: Dictionary = {
	"HOME": Color("#2a2430"),
	"COMMONS": Color("#2c2832"),
	"SHRINE": Color("#24262e"),
	"CLINIC": Color("#1f2a2c"),
	"PATH": Color("#2a2824"),
	"FOREST": Color("#1a2420"),
	"GROVE": Color("#22281e"),
	"FESTIVAL": Color("#3a2e28"),
}

const PORTRAIT_PATHS: Dictionary = {
	"none": "",
	"placeholder": "",
	"popo": "res://assets/portraits/popo.png",
	"hero": "res://assets/portraits/hero.png",
	"merchant": "res://assets/portraits/merchant.png",
	"smith": "res://assets/portraits/smith.png",
	"festival": "res://assets/portraits/festival.png",
	"visitor": "res://assets/portraits/hero.png",
	"worship": "res://assets/portraits/worship.png",
	"doctor": "res://assets/portraits/doctor.png",
}

const PORTRAIT_LABELS: Dictionary = {
	"none": "",
	"placeholder": "立绘占位",
	"popo": "老婆婆",
	"hero": "外来人",
	"merchant": "商人",
	"smith": "铁匠",
	"festival": "节庆",
	"visitor": "外来人",
	"worship": "礼拜主持",
	"doctor": "诊疗处",
}

static func load_texture(path: String) -> Texture2D:
	if path.strip_edges() == "":
		return null
	if not ResourceLoader.exists(path):
		return null
	var res = load(path)
	if res is Texture2D:
		return res
	return null

static func location_texture(location_id: String) -> Texture2D:
	var path: String = str(LOCATION_PATHS.get(location_id, ""))
	return load_texture(path)

static func location_color(location_id: String) -> Color:
	return LOCATION_COLORS.get(location_id, Color("#2a2430"))

static func portrait_texture(portrait_id: String) -> Texture2D:
	var path: String = str(PORTRAIT_PATHS.get(portrait_id, ""))
	return load_texture(path)

static func portrait_label(portrait_id: String) -> String:
	return str(PORTRAIT_LABELS.get(portrait_id, portrait_id))

## Apply location art onto a ColorRect (fallback) + TextureRect (image).
static func apply_location(bg: ColorRect, image: TextureRect, location_id: String) -> void:
	var col: Color = location_color(location_id)
	if bg != null:
		bg.color = col
	if image == null:
		return
	var tex: Texture2D = location_texture(location_id)
	if tex != null:
		image.texture = tex
		image.visible = true
		image.modulate = Color(1, 1, 1, 1)
	else:
		image.texture = null
		image.visible = false

## Apply portrait art; show label text when texture missing.
static func apply_portrait(image: TextureRect, label: Label, portrait_id: String) -> void:
	var pid: String = portrait_id if portrait_id != "" else "placeholder"
	var tex: Texture2D = portrait_texture(pid)
	var text: String = portrait_label(pid)
	if image != null:
		if tex != null:
			image.texture = tex
			image.visible = true
		else:
			image.texture = null
			image.visible = false
	if label != null:
		if tex != null:
			label.text = text
			label.visible = text != ""
		else:
			label.text = text if text != "" else "立绘占位"
			label.visible = true
