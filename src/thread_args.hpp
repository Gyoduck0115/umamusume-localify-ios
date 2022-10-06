#include <string>

struct Config {
  const char *bundle_version;
  const char *document_path;
  bool static_entries_use_hash;
  int max_fps;
  float ui_animation_scale;
  bool ui_use_system_resolution;
  int graphics_quality;
  int anti_aliasing;
  bool force_landscape;
  float force_landscape_ui_scale;
  bool ui_loading_show_orientation_guide;
  bool replace_to_builtin_font;
  bool replace_to_custom_font;
  const char *replace_assets_path;
  const char *font_assetbundle_path;
  const char *font_asset_name;
};

struct ThreadArgs {
  void *framework;
  Config *config;
};
