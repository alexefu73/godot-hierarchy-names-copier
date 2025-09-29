@tool
extends EditorPlugin

var plugin_control: Control

func _enter_tree():
	# تحميل الواجهة
	var ui_scene = load("res://addons/hierarchy_copier/hierarchy_copier_ui.tscn")
	if ui_scene:
		plugin_control = ui_scene.instantiate()
		plugin_control.editor_plugin = self
		
		# إضافة إلى dock مضمون الظهور
		add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, plugin_control)
		
		# طباعة رسالة تأكيد في console المحرر
		print("🎯 أداة نسخ التسلسل الهرمي مفعلة! ابحث عنها في الجانب الأيمن")
	else:
		push_error("❌ تعذر تحميل واجهة الأداة!")

func _exit_tree():
	if plugin_control:
		remove_control_from_docks(plugin_control)
		plugin_control.queue_free()

# دالة مساعدة للعثور على الواجهة
func make_visible(visible: bool):
	if plugin_control:
		plugin_control.visible = visible

func get_plugin_name():
	return "Hierarchy Copier"
