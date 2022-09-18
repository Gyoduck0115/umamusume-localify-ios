#pragma once

#ifndef UMAMUSUMELOCALIFYANDROID_GAME_HPP
#define UMAMUSUMELOCALIFYANDROID_GAME_HPP

#define Unity2019 "2019.4.21f1"
#define Unity2019Twn "2019.4.19f1"
#define Unity2020 "2020.3.24f1"

namespace Game
{
    enum class Region
    {
        UNKNOWN,
        JAP,
        KOR,
        TWN,
    };

    inline auto currentGameRegion = Region::UNKNOWN;

    inline std::string GamePackageName = "jp.co.cygames.umamusume";
    inline std::string GamePackageNameKor = "com.kakaogames.umamusume";
    inline std::string GamePackageNameTwn = "com.komoe.kmumamusume";

    static std::string GetPackageNameByGameRegion(Region gameRegion)
    {
        if (gameRegion == Region::JAP)
            return GamePackageName;
        if (gameRegion == Region::KOR)
            return GamePackageNameKor;
        if (gameRegion == Region::TWN)
            return GamePackageNameTwn;
        return "";
    }

    static std::string GetCurrentPackageName()
    {
        return GetPackageNameByGameRegion(currentGameRegion);
    }
}

#endif
