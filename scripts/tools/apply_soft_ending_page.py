#!/usr/bin/env python3
"""Wire SoftEndingPage into main_shell when AF11 ending fires (idempotent)."""
from pathlib import Path

path = Path("scripts/ui/main_shell.gd")
if not path.exists():
    path = Path(__file__).resolve().parents[2] / "scripts/ui/main_shell.gd"
if not path.exists():
    raise SystemExit("main_shell.gd not found")

t = path.read_text(encoding="utf-8")
if "SoftEndingPageScript" in t and "func _show_soft_ending" in t:
    print("already applied")
    raise SystemExit(0)

anchor = 'const VisualLibraryScript = preload("res://scripts/ui/visual_library.gd")\n'
ins = anchor + 'const SoftEndingPageScript = preload("res://scripts/ui/soft_ending_page.gd")\n'
if "SoftEndingPageScript" not in t:
    if anchor not in t:
        anchor = 'const AftermathStoryletsScript = preload("res://scripts/systems/daily/aftermath_storylets.gd")\n'
        ins = anchor + 'const SoftEndingPageScript = preload("res://scripts/ui/soft_ending_page.gd")\n'
    if anchor not in t:
        raise SystemExit("preload anchor missing")
    t = t.replace(anchor, ins, 1)

if "var ending_page" not in t:
    a = "var last_save_msg: String = \"\"\n"
    b = "var last_save_msg: String = \"\"\nvar ending_page\n"
    if a not in t:
        raise SystemExit("var anchor missing")
    t = t.replace(a, b, 1)

if "_setup_ending_page" not in t:
    a = "\t_build_system_overlay()\n"
    b = "\t_build_system_overlay()\n\t_setup_ending_page()\n"
    if a not in t:
        raise SystemExit("_build_system_overlay anchor missing")
    t = t.replace(a, b, 1)

setup = r'''
func _setup_ending_page() -> void:
	ending_page = SoftEndingPageScript.new()
	add_child(ending_page)
	if not ending_page.continued.is_connected(_on_ending_continued):
		ending_page.continued.connect(_on_ending_continued)
	if not ending_page.back_to_title.is_connected(_on_ending_back_to_title):
		ending_page.back_to_title.connect(_on_ending_back_to_title)
	if not ending_page.tie_chosen.is_connected(_on_ending_tie_chosen):
		ending_page.tie_chosen.connect(_on_ending_tie_chosen)

func _show_soft_ending(beat: Dictionary) -> void:
	var result := {
		"id": str(beat.get("ending", "")),
		"label": str(beat.get("ending_label", "软结局")),
		"text": str(beat.get("text", "")),
	}
	var preview := str(beat.get("preview", ""))
	if ending_page != null:
		ending_page.open_ending(result, preview)
	else:
		_set_dialogue(str(beat.get("text", "")))

func _on_ending_continued() -> void:
	_set_dialogue("结局页合上了。日子还在，只是有些路已经知道自己不会再走第二次。")
	_refresh_ui()

func _on_ending_back_to_title() -> void:
	var title_path := "res://scenes/title.tscn"
	if ResourceLoader.exists(title_path):
		get_tree().change_scene_to_file(title_path)
	elif ResourceLoader.exists("res://title.tscn"):
		get_tree().change_scene_to_file("res://title.tscn")
	else:
		_set_dialogue("找不到标题场景。请从编辑器重新运行。")

func _on_ending_tie_chosen(choice_id: String) -> void:
	var dims: Dictionary = EndingResolver.estimate_dims(world_flags.flags, 0, aftermath._aftermath_depth())
	var result: Dictionary = EndingResolver.resolve(dims, choice_id)
	world_flags.set_flag("ending_soft_" + str(result.get("id", "")))
	world_flags.set_flag("ending_soft_seen")
	if ending_page != null:
		ending_page.open_ending(result, EndingResolver.soft_preview_line(dims))

'''

if "func _setup_ending_page" not in t:
    for key in ["func _gift_popo", "func _open_kitchen", "func _on_kitchen_cooking_completed"]:
        if key in t:
            t = t.replace(key, setup + key, 1)
            break
    else:
        raise SystemExit("insert anchor for setup missing")

old = '''\tif str(beat.get("ending", "")) != "":
\t\tworld_flags.set_flag("ending_soft_" + str(beat.get("ending")))
'''
new = '''\tif str(beat.get("ending", "")) != "":
\t\tworld_flags.set_flag("ending_soft_" + str(beat.get("ending")))
\t\t_show_soft_ending(beat)
'''
if old in t and "_show_soft_ending(beat)" not in t:
    t = t.replace(old, new, 1)

path.write_text(t, encoding="utf-8")
print("applied", path, "lines", t.count("\n") + 1)
