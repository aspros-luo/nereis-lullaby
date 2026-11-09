#!/usr/bin/env python3
"""Wire VisualLibrary into main_shell stage + portrait (idempotent)."""
from pathlib import Path

path = Path("scripts/ui/main_shell.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd"
if not path.exists():
    raise SystemExit("main_shell.gd not found")

t = path.read_text(encoding="utf-8")
if "VisualLibraryScript" in t and "stage_image" in t:
    print("already applied")
    raise SystemExit(0)

a = 'const AftermathStoryletsScript = preload("res://scripts/systems/daily/aftermath_storylets.gd")\n'
b = a + 'const VisualLibraryScript = preload("res://scripts/ui/visual_library.gd")\n'
if "VisualLibraryScript" not in t:
    if a not in t:
        raise SystemExit("preload anchor missing")
    t = t.replace(a, b, 1)

a = "var stage_bg: ColorRect\nvar stage_title: Label\n"
b = "var stage_bg: ColorRect\nvar stage_image: TextureRect\nvar stage_title: Label\n"
if "var stage_image" not in t:
    if a not in t:
        raise SystemExit("stage_bg var missing")
    t = t.replace(a, b, 1)

a = "var portrait_label: Label\n"
b = "var portrait_image: TextureRect\nvar portrait_label: Label\n"
if "var portrait_image" not in t:
    if a not in t:
        raise SystemExit("portrait_label var missing")
    t = t.replace(a, b, 1)

a = """\tstage_bg = ColorRect.new()
\tstage_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\tstage_wrap.add_child(stage_bg)
"""
b = """\tstage_bg = ColorRect.new()
\tstage_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\tstage_wrap.add_child(stage_bg)
\tstage_image = TextureRect.new()
\tstage_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
\tstage_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\tstage_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
\tstage_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
\tstage_image.visible = false
\tstage_wrap.add_child(stage_image)
"""
if "stage_image = TextureRect" not in t:
    if a not in t:
        raise SystemExit("stage_bg build missing")
    t = t.replace(a, b, 1)

a = """\tportrait_label = Label.new()
\tportrait_label.add_theme_color_override("font_color", Color("#77717b"))
\tsc.add_child(portrait_label)
"""
b = """\tportrait_image = TextureRect.new()
\tportrait_image.custom_minimum_size = Vector2(120, 160)
\tportrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
\tportrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
\tportrait_image.visible = false
\tsc.add_child(portrait_image)
\tportrait_label = Label.new()
\tportrait_label.add_theme_color_override("font_color", Color("#77717b"))
\tsc.add_child(portrait_label)
"""
if "portrait_image = TextureRect" not in t:
    if a not in t:
        raise SystemExit("portrait build missing")
    t = t.replace(a, b, 1)

a = """\t\tstage_title.text = \"丰收节 · 公共场\"
\t\tstage_hint.text = \"鼓声与笑声叠在一起。\"
\t\tstage_bg.color = Color(\"#3a2e28\")
\t\tportrait_label.text = \"节庆\"
"""
b = """\t\tstage_title.text = \"丰收节 · 公共场\"
\t\tstage_hint.text = \"鼓声与笑声叠在一起。\"
\t\tVisualLibraryScript.apply_location(stage_bg, stage_image, \"FESTIVAL\")
\t\tVisualLibraryScript.apply_portrait(portrait_image, portrait_label, \"festival\")
"""
if a in t:
    t = t.replace(a, b, 1)

a = """\t\tstage_title.text = str(LOCATION_NAMES.get(loc, loc))
\t\tstage_hint.text = _location_desc(loc)
\t\tstage_bg.color = STAGE_COLORS.get(loc, Color(\"#2a2430\"))
\t\tportrait_label.text = \"立绘占位\"
"""
b = """\t\tstage_title.text = str(LOCATION_NAMES.get(loc, loc))
\t\tstage_hint.text = _location_desc(loc)
\t\tVisualLibraryScript.apply_location(stage_bg, stage_image, loc)
\t\tVisualLibraryScript.apply_portrait(portrait_image, portrait_label, \"placeholder\")
"""
if a in t:
    t = t.replace(a, b, 1)

a = """\tif beat.has(\"portrait\"):
\t\tportrait_label.text = str(beat.get(\"portrait\"))
"""
b = """\tif beat.has(\"portrait\"):
\t\tvar pid: String = str(beat.get(\"portrait\"))
\t\tVisualLibraryScript.apply_portrait(portrait_image, portrait_label, pid)
"""
if a in t:
    t = t.replace(a, b, 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
