@tool
extends PanelContainer

## Hierarchy Copier Tool
##
## Editor plugin for copying scene hierarchy structure
## @author: Khalid A. Ftaini (Guided by Deepseek)
## @version: 1.0.0
## @license: MIT

var editor_plugin: EditorPlugin

@onready var copy_type_option: OptionButton = find_child("CopyTypeOption")
@onready var include_types_checkbox: CheckBox = find_child("IncludeTypesCheckbox")
@onready var result_text: TextEdit = find_child("ResultText")
@onready var status_label: Label = find_child("StatusLabel")
@onready var copy_button: Button = find_child("CopyButton")
@onready var show_button: Button = find_child("ShowButton")
@onready var clear_button: Button = find_child("ClearButton")

func _ready():
	print("🔧 بدء تحميل واجهة الأداة...")
	if copy_type_option and include_types_checkbox and result_text and status_label and copy_button and show_button and clear_button:
		print("✅ جميع عناصر الواجهة موجودة")
		setup_ui()
	else:
		print("❌ عناصر واجهة مفقودة:")
		if !copy_type_option: print("   - CopyTypeOption")
		if !include_types_checkbox: print("   - IncludeTypesCheckbox")
		if !result_text: print("   - ResultText")
		if !status_label: print("   - StatusLabel")
		if !copy_button: print("   - CopyButton")
		if !show_button: print("   - ShowButton")
		if !clear_button: print("   - ClearButton")

# في hierarchy_copier_ui.gd
func setup_ui():
	copy_type_option.clear()
	copy_type_option.add_item("Current Scene", 0)
	copy_type_option.add_item("Selected Node", 1)
	copy_type_option.add_item("All Open Scenes", 2)

	# اكتشاف اللغة تلقائياً
	if TranslationServer.get_locale().substr(0, 2) == "ar":
		setup_arabic_ui()
	else:
		setup_english_ui()

	# إعداد الأحجام
	result_text.custom_minimum_size.y = 200

	# توصيل الإشارات
	copy_button.pressed.connect(_on_copy_button_pressed)
	show_button.pressed.connect(_on_show_button_pressed)
	clear_button.pressed.connect(_on_clear_button_pressed)

func setup_arabic_ui():
	find_child("TitleLabel").text = "أداة نسخ التسلسل الهرمي"
	include_types_checkbox.text = "تضمين أنواع العقد"
	copy_button.text = "نسخ"
	show_button.text = "عرض"
	clear_button.text = "مسح"

func setup_english_ui():
	find_child("TitleLabel").text = "Hierarchy Copier"
	include_types_checkbox.text = "Include Node Types"
	copy_button.text = "Copy"
	show_button.text = "Show"
	clear_button.text = "Clear"

func get_editor_interface():
	if editor_plugin:
		return editor_plugin.get_editor_interface()
	print("❌ editor_plugin غير معين")
	return null

func get_current_scene() -> Node:
	var editor_interface = get_editor_interface()
	if editor_interface:
		var scene = editor_interface.get_edited_scene_root()
		print("📊 المشهد الحالي: ", scene.name if scene else "لا يوجد مشهد")
		return scene
	print("❌ لا يمكن الوصول إلى editor_interface")
	return null

func get_selected_nodes() -> Array:
	var editor_interface = get_editor_interface()
	if editor_interface:
		var selection = editor_interface.get_selection()
		var selected_nodes = selection.get_selected_nodes()
		print("📊 العقد المحددة: ", selected_nodes.size())
		return selected_nodes
	return []

func _on_copy_button_pressed():
	print("📋 زر النسخ مضغوط")
	var hierarchy_text = generate_hierarchy()
	print("📝 النص المُولد: ", hierarchy_text.length(), " حرف")
	
	if hierarchy_text.is_empty():
		status_label.text = "❌ لم يتم العثور على مشهد!"
		return
	
	DisplayServer.clipboard_set(hierarchy_text)
	status_label.text = "✅ تم النسخ إلى الحافظة!"
	print("✅ تم النسخ إلى الحافظة")
	
	await get_tree().create_timer(2.0).timeout
	status_label.text = ""

func _on_show_button_pressed():
	print("👀 زر العرض مضغوط")
	var hierarchy_text = generate_hierarchy()
	print("📝 النص المُولد للعرض: ", hierarchy_text.length(), " حرف")
	
	if hierarchy_text.is_empty():
		status_label.text = "❌ لم يتم العثور على مشهد!"
		print("❌ لا يوجد نص للعرض")
		return
	
	result_text.text = hierarchy_text
	status_label.text = "✅ تم عرض التسلسل الهرمي!"
	print("✅ تم عرض النص في TextEdit")

func _on_clear_button_pressed():
	print("🗑️ زر المسح مضغوط")
	result_text.text = ""
	status_label.text = "✅ تم المسح!"
	print("✅ تم مسح النص")

func generate_hierarchy() -> String:
	print("🌳 جاري إنشاء التسلسل الهرمي...")
	var copy_type = copy_type_option.get_selected_id()
	print("🎯 نوع النسخ المحدد: ", copy_type)
	
	match copy_type:
		0: # المشهد الحالي
			var root_node = get_current_scene()
			if root_node:
				print("📁 جاري معالجة المشهد الحالي: ", root_node.name)
				return build_hierarchy_text(root_node)
			else:
				print("❌ لا يوجد مشهد حالي")
				return ""
		1: # العقدة المحددة
			var selected = get_selected_nodes()
			if selected.is_empty():
				print("❌ لم يتم تحديد أي عقدة")
				return ""
			print("📁 جاري معالجة العقدة المحددة: ", selected[0].name)
			return build_hierarchy_text(selected[0])
		2: # جميع المشاهد المفتوحة
			print("📂 جاري معالجة جميع المشاهد المفتوحة")
			return generate_all_scenes_hierarchy()
	
	return ""

func generate_all_scenes_hierarchy() -> String:
	print("📂 جاري معالجة جميع المشاهد المفتوحة")
	var editor_interface = get_editor_interface()
	if not editor_interface:
		print("❌ لا يمكن الوصول إلى editor_interface")
		return ""
		
	var open_scenes = editor_interface.get_open_scenes()
	print("📂 عدد المشاهد المفتوحة: ", open_scenes.size())
	
	var result = ""
	
	for scene_path in open_scenes:
		print("📁 معالجة المشهد: ", scene_path)
		var scene_resource = load(scene_path)
		if scene_resource:
			var scene = scene_resource.instantiate()
			if scene:
				result += "=== " + scene_path.get_file() + " ===\n"
				result += build_hierarchy_text(scene)
				result += "\n"
				scene.queue_free()
	
	print("✅ اكتمل معالجة جميع المشاهد")
	return result

func build_hierarchy_text(node: Node, indent_level: int = 0) -> String:
	if not node:
		print("❌ عقدة غير صالحة في build_hierarchy_text")
		return ""
		
	var result = ""
	var indent = "  ".repeat(indent_level)
	var node_name = node.name
	var node_type = " (" + node.get_class() + ")" if include_types_checkbox.button_pressed else ""
	
	result += indent + "📁 " + node_name + node_type + "\n"
	
	print("📦 معالجة العقدة: ", node_name, " (", node.get_class(), ")")
	
	for child in node.get_children():
		result += build_hierarchy_text(child, indent_level + 1)
	
	return result
