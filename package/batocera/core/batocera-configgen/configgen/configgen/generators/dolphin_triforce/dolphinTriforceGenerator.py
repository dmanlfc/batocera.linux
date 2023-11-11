#!/usr/bin/env python
import Command
import batoceraFiles
from generators.Generator import Generator
import shutil
import os.path
from os import environ
import configparser
from . import dolphinTriforceControllers
import controllersConfig

class DolphinTriforceGenerator(Generator):

    def generate(self, system, rom, playersControllers, guns, wheels, gameResolution):
        if not os.path.exists(os.path.dirname(batoceraFiles.dolphinTriforceIni)):
            os.makedirs(os.path.dirname(batoceraFiles.dolphinTriforceIni))

        # Dir required for saves
        if not os.path.exists(batoceraFiles.dolphinTriforceData + "/StateSaves"):
            os.makedirs(batoceraFiles.dolphinTriforceData + "/StateSaves")

        dolphinTriforceControllers.generateControllerConfig(system, playersControllers, rom)

        ## dolphin.ini ##

        dolphinTriforceSettings = configparser.ConfigParser(interpolation=None)
        # To prevent ConfigParser from converting to lower case
        dolphinTriforceSettings.optionxform = str
        if os.path.exists(batoceraFiles.dolphinTriforceIni):
            dolphinTriforceSettings.read(batoceraFiles.dolphinTriforceIni)

        # Sections
        if not dolphinTriforceSettings.has_section("General"):
            dolphinTriforceSettings.add_section("General")
        if not dolphinTriforceSettings.has_section("Core"):
            dolphinTriforceSettings.add_section("Core")
        if not dolphinTriforceSettings.has_section("Interface"):
            dolphinTriforceSettings.add_section("Interface")
        if not dolphinTriforceSettings.has_section("Analytics"):
            dolphinTriforceSettings.add_section("Analytics")
        if not dolphinTriforceSettings.has_section("Display"):
            dolphinTriforceSettings.add_section("Display")

        # Define default games path
        if "ISOPaths" not in dolphinTriforceSettings["General"]:
            dolphinTriforceSettings.set("General", "ISOPath0", "/userdata/roms/triforce")
            dolphinTriforceSettings.set("General", "ISOPaths", "1")
        if "GCMPathes" not in dolphinTriforceSettings["General"]:
            dolphinTriforceSettings.set("General", "GCMPath0", "/userdata/roms/triforce")
            dolphinTriforceSettings.set("General", "GCMPathes", "1")

        # Save file location
        if "MemcardAPath" not in dolphinTriforceSettings["Core"]:
            dolphinTriforceSettings.set("Core", "MemcardAPath", batoceraFiles.dolphinTriforceData + "/GC/MemoryCardA.USA.raw")
            dolphinTriforceSettings.set("Core", "MemcardBPath", batoceraFiles.dolphinTriforceData + "/GC/MemoryCardB.USA.raw")

        # Draw or not FPS
        if system.isOptSet("showFPS") and system.getOptBoolean("showFPS"):
            dolphinTriforceSettings.set("General", "ShowLag", "True")
            dolphinTriforceSettings.set("General", "ShowFrameCount", "True")
        else:
            dolphinTriforceSettings.set("General", "ShowLag", "False")
            dolphinTriforceSettings.set("General", "ShowFrameCount", "False")

        # Don't ask about statistics
        dolphinTriforceSettings.set("Analytics", "PermissionAsked", "True")

        # PanicHandlers displaymessages
        dolphinTriforceSettings.set("Interface", "UsePanicHandlers", "False")
	
        # Disable OSD Messages
        if system.isOptSet("triforce_osd_messages") and system.getOptBoolean("triforce_osd_messages"):
            dolphinTriforceSettings.set("Interface", "OnScreenDisplayMessages", "False")
        else:
            dolphinTriforceSettings.set("Interface", "OnScreenDisplayMessages", "True")

        # Don't confirm at stop
        dolphinTriforceSettings.set("Interface", "ConfirmStop", "False")

        # fixes gui display
        dolphinTriforceSettings.set("Display", "RenderToMain", "False")
        dolphinTriforceSettings.set("Display", "Fullscreen", "False")

        # Enable Cheats
        dolphinTriforceSettings.set("Core", "EnableCheats", "True")

        # Dual Core
        if system.isOptSet("triforce_dual_core") and system.getOptBoolean("triforce_dual_core"):
            dolphinTriforceSettings.set("Core", "CPUThread", "True")
        else:
            dolphinTriforceSettings.set("Core", "CPUThread", "False")

        # Gpu Sync
        if system.isOptSet("triforce_gpu_sync") and system.getOptBoolean("triforce_gpu_sync"):
            dolphinTriforceSettings.set("Core", "SyncGPU", "True")
        else:
            dolphinTriforceSettings.set("Core", "SyncGPU", "False")

        # Language
        dolphinTriforceSettings.set("Core", "SelectedLanguage", str(getGameCubeLangFromEnvironment())) # Wii
        dolphinTriforceSettings.set("Core", "GameCubeLanguage", str(getGameCubeLangFromEnvironment())) # GC

        # Enable MMU
        if system.isOptSet("triforce_enable_mmu") and system.getOptBoolean("triforce_enable_mmu"):
            dolphinTriforceSettings.set("Core", "MMU", "True")
        else:
            dolphinTriforceSettings.set("Core", "MMU", "False")

        # Backend - Default OpenGL
        if system.isOptSet("triforce_api"):
            dolphinTriforceSettings.set("Core", "GFXBackend", system.config["triforce_api"])
        else:
            dolphinTriforceSettings.set("Core", "GFXBackend", "OGL")

        # Serial Port 1 to AM-Baseband
        dolphinTriforceSettings.set("Core", "SerialPort1", "6")

        # Gamecube pads forced as AM-Baseband
        dolphinTriforceSettings.set("Core", "SIDevice0", "11")
        dolphinTriforceSettings.set("Core", "SIDevice1", "11")

        # Save dolphin.ini
        with open(batoceraFiles.dolphinTriforceIni, 'w') as configfile:
            dolphinTriforceSettings.write(configfile)

        ## gfx.ini ##

        dolphinTriforceGFXSettings = configparser.ConfigParser(interpolation=None)
        # To prevent ConfigParser from converting to lower case
        dolphinTriforceGFXSettings.optionxform = str
        dolphinTriforceGFXSettings.read(batoceraFiles.dolphinTriforceGfxIni)

        # Add Default Sections
        if not dolphinTriforceGFXSettings.has_section("Settings"):
            dolphinTriforceGFXSettings.add_section("Settings")
        if not dolphinTriforceGFXSettings.has_section("Hacks"):
            dolphinTriforceGFXSettings.add_section("Hacks")
        if not dolphinTriforceGFXSettings.has_section("Enhancements"):
            dolphinTriforceGFXSettings.add_section("Enhancements")             
        if not dolphinTriforceGFXSettings.has_section("Hardware"):
            dolphinTriforceGFXSettings.add_section("Hardware")  
            
        # Graphics setting Aspect Ratio
        if system.isOptSet('triforce_aspect_ratio'):
            dolphinTriforceGFXSettings.set("Settings", "AspectRatio", system.config["triforce_aspect_ratio"])
        else:
            # set to zero, which is 'Auto' in Dolphin & Batocera
            dolphinTriforceGFXSettings.set("Settings", "AspectRatio", "0")
        
        # Show fps
        if system.isOptSet("showFPS") and system.getOptBoolean("showFPS"):
            dolphinTriforceGFXSettings.set("Settings", "ShowFPS", "True")
        else:
            dolphinTriforceGFXSettings.set("Settings", "ShowFPS", "False")

        # HiResTextures
        if system.isOptSet('triforce_hires_textures') and system.getOptBoolean('triforce_hires_textures'):
            dolphinTriforceGFXSettings.set("Settings", "HiresTextures",      "True")
            dolphinTriforceGFXSettings.set("Settings", "CacheHiresTextures", "True")
        else:
            dolphinTriforceGFXSettings.set("Settings", "HiresTextures",      "False")
            dolphinTriforceGFXSettings.set("Settings", "CacheHiresTextures", "False")

        # Widescreen Hack
        if system.isOptSet('triforce_widescreen_hack') and system.getOptBoolean('triforce_widescreen_hack'):
            # Prefer Cheats than Hack 
            if system.isOptSet('enable_cheats') and system.getOptBoolean('enable_cheats'):
                dolphinTriforceGFXSettings.set("Settings", "wideScreenHack", "False")
            else:
                dolphinTriforceGFXSettings.set("Settings", "wideScreenHack", "True")
        else:
            dolphinTriforceGFXSettings.set("Settings", "wideScreenHack", "False")

        # Various performance hacks - Default Off
        if system.isOptSet('triforce_perf_hacks') and system.getOptBoolean('triforce_perf_hacks'):
            dolphinTriforceGFXSettings.set("Hacks", "BBoxEnable", "False")
            dolphinTriforceGFXSettings.set("Hacks", "DeferEFBCopies", "True")
            dolphinTriforceGFXSettings.set("Hacks", "EFBEmulateFormatChanges", "False")
            dolphinTriforceGFXSettings.set("Hacks", "EFBScaledCopy", "True")
            dolphinTriforceGFXSettings.set("Hacks", "EFBToTextureEnable", "True")
            dolphinTriforceGFXSettings.set("Hacks", "SkipDuplicateXFBs", "True")
            dolphinTriforceGFXSettings.set("Hacks", "XFBToTextureEnable", "True")
            dolphinTriforceGFXSettings.set("Enhancements", "ForceFiltering", "True")
            dolphinTriforceGFXSettings.set("Enhancements", "ArbitraryMipmapDetection", "True")
            dolphinTriforceGFXSettings.set("Enhancements", "DisableCopyFilter", "True")
            dolphinTriforceGFXSettings.set("Enhancements", "ForceTrueColor", "True")            
        else:
            if dolphinTriforceGFXSettings.has_section("Hacks"):
                dolphinTriforceGFXSettings.remove_option("Hacks", "BBoxEnable")
                dolphinTriforceGFXSettings.remove_option("Hacks", "DeferEFBCopies")
                dolphinTriforceGFXSettings.remove_option("Hacks", "EFBEmulateFormatChanges")
                dolphinTriforceGFXSettings.remove_option("Hacks", "EFBScaledCopy")
                dolphinTriforceGFXSettings.remove_option("Hacks", "EFBToTextureEnable")
                dolphinTriforceGFXSettings.remove_option("Hacks", "SkipDuplicateXFBs")
                dolphinTriforceGFXSettings.remove_option("Hacks", "XFBToTextureEnable")
            if dolphinTriforceGFXSettings.has_section("Enhancements"):
                dolphinTriforceGFXSettings.remove_option("Enhancements", "ForceFiltering")
                dolphinTriforceGFXSettings.remove_option("Enhancements", "ArbitraryMipmapDetection")
                dolphinTriforceGFXSettings.remove_option("Enhancements", "DisableCopyFilter")
                dolphinTriforceGFXSettings.remove_option("Enhancements", "ForceTrueColor")  

        # Internal resolution settings
        if system.isOptSet('triforce_resolution'):
            dolphinTriforceGFXSettings.set("Settings", "EFBScale", system.config["triforce_resolution"])
        else:
            dolphinTriforceGFXSettings.set("Settings", "EFBScale", "2")

        # VSync
        if system.isOptSet('triforce_vsync'):
            dolphinTriforceGFXSettings.set("Hardware", "VSync", str(system.getOptBoolean('triforce_vsync')))
        else:
            dolphinTriforceGFXSettings.set("Hardware", "VSync", "True")

        # Anisotropic filtering
        if system.isOptSet('triforce_filtering'):
            dolphinTriforceGFXSettings.set("Enhancements", "MaxAnisotropy", system.config["triforce_filtering"])
        else:
            dolphinTriforceGFXSettings.set("Enhancements", "MaxAnisotropy", "0")

        # Anti aliasing
        if system.isOptSet('triforce_antialiasing'):
            dolphinTriforceGFXSettings.set("Settings", "MSAA", system.config["triforce_antialiasing"])
        else:
            dolphinTriforceGFXSettings.set("Settings", "MSAA", "0")

        # Save gfx.ini
        with open(batoceraFiles.dolphinTriforceGfxIni, 'w') as configfile:
            dolphinTriforceGFXSettings.write(configfile)

        ## logger settings ##

        dolphinTriforceLogSettings = configparser.ConfigParser(interpolation=None)
        # To prevent ConfigParser from converting to lower case
        dolphinTriforceLogSettings.optionxform = str
        dolphinTriforceLogSettings.read(batoceraFiles.dolphinTriforceLoggerIni)

        # Sections
        if not dolphinTriforceLogSettings.has_section("Logs"):
            dolphinTriforceLogSettings.add_section("Logs")

        # Prevent the constant log spam.
        dolphinTriforceLogSettings.set("Logs", "DVD", "False")

        # Save Logger.ini
        with open(batoceraFiles.dolphinTriforceLoggerIni, 'w') as configfile:
            dolphinTriforceLogSettings.write(configfile)

        ## game settings ##

        # These ini files are required to launch Triforce games, and thus should always be present and enabled.
        if not os.path.exists(batoceraFiles.dolphinTriforceGameSettings):
            os.makedirs(batoceraFiles.dolphinTriforceGameSettings)
        for filename in os.listdir("/usr/share/triforce"):
            source_path = os.path.join("/usr/share/triforce", filename)
            destination_path = os.path.join(batoceraFiles.dolphinTriforceGameSettings, filename)
            if os.path.exists(destination_path) and os.path.getmtime(source_path) <= os.path.getmtime(destination_path):
                continue
            shutil.copy(source_path, destination_path)
        
        # logic to deal with Mario Kart games that don't run on the new binary yet
        if "kart" in rom.lower():
            commandArray = ["dolphin-triforce-legacy", "-b", "-U", batoceraFiles.dolphinTriforceConfig, "-e", rom]
        else:
            commandArray = ["dolphin-triforce", "-b", "-u", batoceraFiles.dolphinTriforceConfig, "-e", rom]

        return Command.Command(
            array=commandArray,
            env={
                "QT_QPA_PLATFORM":"xcb",
                "SDL_GAMECONTROLLERCONFIG": controllersConfig.generateSdlGameControllerConfig(playersControllers),
                "SDL_JOYSTICK_HIDAPI": "0"
            }
        )
            
    def getInGameRatio(self, config, gameResolution, rom):
        if 'triforce_aspect_ratio' in config:
            if config['triforce_aspect_ratio'] == "1":
                return 16/9
            elif config['triforce_aspect_ratio'] == "3" and (gameResolution["width"] / float(gameResolution["height"]) > ((16.0 / 9.0) - 0.1)):
                return 16/9
        return 4/3

# Seem to be only for the gamecube. However, while this is not in a gamecube section
# It may be used for something else, so set it anyway
def getGameCubeLangFromEnvironment():
    lang = environ['LANG'][:5]
    availableLanguages = { "en_US": 0, "de_DE": 1, "fr_FR": 2, "es_ES": 3, "it_IT": 4, "nl_NL": 5 }
    if lang in availableLanguages:
        return availableLanguages[lang]
    else:
        return availableLanguages["en_US"]
