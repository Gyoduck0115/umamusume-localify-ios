#include "hook.h"
#include "fnv1a_hash.hpp"
#include "il2cpp_hook.h"
#include "localify/localify.h"
#include "stdinclude.hpp"
#include <dlfcn.h>
#include <exception>
#include <sstream>
#include <string>
#include <thread>
#include <utility>

#include "thread_args.hpp"

using namespace std;
using namespace localify;

const char *g_bundle_version;

const char *g_document_path;

int g_max_fps = 30;
float g_ui_animation_scale = 1.0f;
bool g_ui_use_system_resolution = false;
bool g_replace_to_builtin_font = false;
bool g_replace_to_custom_font = false;
const char *g_replace_assets_path;
const char *g_font_assetbundle_path;
const char *g_font_asset_name;
int g_graphics_quality = -1;
int g_anti_aliasing = -1;
bool g_force_landscape = false;
float g_force_landscape_ui_scale = 0.5;
bool g_ui_loading_show_orientation_guide = true;
std::unordered_map<std::string, ReplaceAsset> g_replace_assets;

void dlopen_process(const char *name, void *handle) {
  if (!il2cpp_handle) {
    if (name != nullptr && strstr(name, "UnityFramework")) {
      il2cpp_handle = handle;
      LOGI("Got UnityFramework(il2cpp) handle!");
    }
  }
}

HOOK_DEF(void *, dlopen, const char *name, int flags) {
  void *handle = orig_dlopen(name, flags);
  dlopen_process(name, handle);
  return handle;
}

std::vector<std::string> load_dicts() {
  std::vector<std::string> dicts;
  auto dictsPath =
      u16string(u8_u16(g_document_path)).append(u"/localized_data");
  if (filesystem::exists(dictsPath) && filesystem::is_directory(dictsPath)) {
    for (auto &file : filesystem::directory_iterator(dictsPath)) {
      if (file.path().filename().string() == ".DS_Store")
        continue;
      if (file.is_regular_file()) {
        dicts.emplace_back(file.path().filename().string());
      }
    }
  }
  return dicts;
}

void load_assets() {
  if (!string(g_replace_assets_path).empty()) {
    auto replaceAssetsPath = u8_u16(g_replace_assets_path);
    if (!replaceAssetsPath.starts_with(u"/")) {
      replaceAssetsPath.insert(0,
                               u16string(u8_u16(g_document_path)).append(u"/"));
    }
    if (filesystem::exists(replaceAssetsPath) &&
        filesystem::is_directory(replaceAssetsPath)) {
      sleep(1);
      for (auto &file : filesystem::directory_iterator(replaceAssetsPath)) {
        if (file.path().filename().string() == ".DS_Store")
          continue;
        if (file.is_regular_file()) {
          auto assets = ReplaceAsset{file.path().string(), nullptr};
          try {
            g_replace_assets.emplace(file.path().filename().string(), assets);
          } catch (std::exception &e) {
            LOGE("g_replace_assets emplace Error: %s", e.what());
          }
        }
      }
    }
  }
}

HOOK_DEF(int, il2cpp_init, char *domainName) {
  auto res = orig_il2cpp_init(domainName);
  LOGI("Init il2cpp!");
  std::thread init_thread([]() {
    // logger::init_logger();
    il2cpp_hook_init(il2cpp_handle);
    il2cpp_hook();
  });
  init_thread.detach();
  return res;
}

/* std::optional<std::vector<std::string>> read_config() {
  std::ifstream config_stream{string("/sdcard/Android/data/")
                                  .append(Game::GetCurrentPackageName())
                                  .append("/config.json")};
  std::vector<std::string> dicts{};

  if (!config_stream.is_open()) {
    LOGW("config.json not loaded.");
    return nullopt;
  }

  LOGI("config.json loaded.");

  rapidjson::IStreamWrapper wrapper{config_stream};
  rapidjson::Document document;

  document.ParseStream(wrapper);

  if (!document.HasParseError()) {
    if (document.HasMember("maxFps")) {
      g_max_fps = document["maxFps"].GetInt();
    }
    if (document.HasMember("uiAnimationScale")) {
      g_ui_animation_scale = document["uiAnimationScale"].GetFloat();
    }
    if (document.HasMember("uiUseSystemResolution")) {
      g_ui_use_system_resolution = document["uiUseSystemResolution"].GetBool();
    }
    if (document.HasMember("replaceFont")) {
      g_replace_to_builtin_font = document["replaceFont"].GetBool();
    }
    if (!document.HasMember("replaceFont") &&
        document.HasMember("replaceToBuiltinFont")) {
      g_replace_to_builtin_font = document["replaceToBuiltinFont"].GetBool();
    }
    if (document.HasMember("replaceToCustomFont")) {
      g_replace_to_custom_font = document["replaceToCustomFont"].GetBool();
    }
    if (document.HasMember("fontAssetBundlePath")) {
      g_font_assetbundle_path =
          std::string(document["fontAssetBundlePath"].GetString());
    }
    if (document.HasMember("fontAssetName")) {
      g_font_asset_name = std::string(document["fontAssetName"].GetString());
    }
    if (document.HasMember("graphicsQuality")) {
      g_graphics_quality = document["graphicsQuality"].GetInt();
      if (g_graphics_quality < -1) {
        g_graphics_quality = -1;
      }
      if (g_graphics_quality > 4) {
        g_graphics_quality = 4;
      }
    }
    if (document.HasMember("antiAliasing")) {
      g_anti_aliasing = document["antiAliasing"].GetInt();
      vector<int> options = {0, 2, 4, 8, -1};
      g_anti_aliasing = find(options.begin(), options.end(), g_anti_aliasing) -
                        options.begin();
    }
    if (document.HasMember("forceLandscape")) {
      g_force_landscape = document["forceLandscape"].GetBool();
    }
    if (document.HasMember("forceLandscapeUiScale")) {
      g_force_landscape_ui_scale = document["forceLandscapeUiScale"].GetFloat();
      if (g_force_landscape_ui_scale <= 0) {
        g_force_landscape_ui_scale = 1;
      }
    }
    if (document.HasMember("uiLoadingShowOrientationGuide")) {
      g_ui_loading_show_orientation_guide =
          document["uiLoadingShowOrientationGuide"].GetBool();
    }
    if (document.HasMember("replaceAssetsPath")) {
      auto replaceAssetsPath =
          u8_u16(document["replaceAssetsPath"].GetString());
      if (!replaceAssetsPath.starts_with(u"/")) {
        replaceAssetsPath.insert(
            0, u16string(u8_u16(g_document_path)).append(u"/"));
      }
      if (filesystem::exists(replaceAssetsPath) &&
          filesystem::is_directory(replaceAssetsPath)) {
        for (auto &file : filesystem::directory_iterator(replaceAssetsPath)) {
          if (file.is_regular_file()) {
            g_replace_assets.emplace(
                file.path().filename().string(),
                ReplaceAsset{file.path().string(), nullptr});
          }
        }
      }
    }

    if (document.HasMember("dicts")) {
      auto &dicts_arr = document["dicts"];
      auto len = dicts_arr.Size();

      for (size_t i = 0; i < len; ++i) {
        auto dict = dicts_arr[i].GetString();

        dicts.emplace_back(dict);
      }
    }
  }

  config_stream.close();
  return dicts;
} */

extern "C" void hack_thread(void *args) {
  ThreadArgs *thread_args = (ThreadArgs *)args;
  Config *config = thread_args->config;
  il2cpp_handle = thread_args->framework;

  g_bundle_version = config->bundle_version;
  g_document_path = config->document_path;
  g_max_fps = config->max_fps;
  g_ui_animation_scale = config->ui_animation_scale;
  g_ui_use_system_resolution = config->ui_use_system_resolution;
  g_graphics_quality = config->graphics_quality;
  g_anti_aliasing = config->anti_aliasing;
  g_force_landscape = config->force_landscape;
  g_force_landscape_ui_scale = config->force_landscape_ui_scale;
  g_ui_loading_show_orientation_guide =
      config->ui_loading_show_orientation_guide;
  g_replace_to_builtin_font = config->replace_to_builtin_font;
  g_replace_to_custom_font = config->replace_to_custom_font;
  g_replace_assets_path = config->replace_assets_path;
  g_font_assetbundle_path = config->font_assetbundle_path;
  g_font_asset_name = config->font_asset_name;

  auto il2cpp_init = dlsym(il2cpp_handle, "il2cpp_init");
  MSHookFunction(reinterpret_cast<void *>(il2cpp_init),
                 reinterpret_cast<void *>(new_il2cpp_init),
                 reinterpret_cast<void **>(&orig_il2cpp_init));

  auto dict = load_dicts();
  load_assets();
  load_textdb(g_bundle_version, &dict);
  /* MSHookFunction(reinterpret_cast<void *>(dlopen),
                 reinterpret_cast<void *>(new_dlopen),
                 reinterpret_cast<void **>(&orig_dlopen)); */

  // auto dict = read_config();

  /* while (!il2cpp_handle) {
    sleep(1);
  } */

  /* std::thread init_thread([]() {
    // logger::init_logger();
    // localify::load_textdb(get_application_version(), &dict.value());
    il2cpp_hook_init(il2cpp_handle);
    il2cpp_hook();
  });
  init_thread.detach(); */
}
