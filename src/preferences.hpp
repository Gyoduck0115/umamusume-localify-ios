#include "il2cpp/il2cpp-class.h"
#include <string>
#include <unordered_map>

struct ReplaceAsset {
  std::string path;
  Il2CppObject *asset;
};

extern const char *g_bundle_version;

extern const char *g_document_path;

extern bool g_static_entries_use_hash;

extern int g_max_fps;
extern float g_ui_animation_scale;
extern bool g_ui_use_system_resolution;
/**
 * -1 Auto (Default behavior)
 * 0 Toon1280, Anti: 0
 * 1 Toon1280x2, Anti: 2
 * 2 Toon1280x4, Anti: 4
 * 3 ToonFull, Anti: 8
 */
extern int g_graphics_quality;
/**
 * -1 Follow graphics quality
 * 0 MSAA OFF
 * 2 x2
 * 4 x4
 * 8 x8
 */
extern int g_anti_aliasing;
extern bool g_force_landscape;
extern float g_force_landscape_ui_scale;
extern bool g_ui_loading_show_orientation_guide;
extern bool g_replace_to_builtin_font;
extern bool g_replace_to_custom_font;
extern const char *g_replace_assets_path;
extern const char *g_font_assetbundle_path;
extern const char *g_font_asset_name;

extern std::unordered_map<std::string, ReplaceAsset> g_replace_assets;
