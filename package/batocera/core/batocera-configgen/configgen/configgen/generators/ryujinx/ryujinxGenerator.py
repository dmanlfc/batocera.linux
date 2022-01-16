#!/usr/bin/env python

from generators.Generator import Generator
import Command
import os
import controllersConfig
import json
import configgen.controllersConfig as controllersConfig

class RyujinxGenerator(Generator):

    def generate(self, system, rom, playersControllers, gameResolution):

        # create the config folder
        ryujinxPath = "/userdata/system/configs/ryujinx"
        if not os.path.exists(ryujinxPath):
            os.makedirs(ryujinxPath)
        
        # ensure certain settings are batocera friendly
        #Config.json
        configFile = open('/userdata/system/configs/ryujinx/Config.json', 'r')
        data = json.load(configFile)
        configFile.close()

        data["check_updates_on_start"] = False
        data["show_confirm_exit"] = False
        data["hide_cursor_on_idle"] = True
        data["start_fullscreen"] = True
        data["docked_mode"] = True #set docked for full controller config
        data["enable_discord_integration"] = False
        # todo "game_dirs": [ "/userdata/roms/switch" ]
        # avoid log spam unless an error
        data["enable_file_log"] = False
        data["logging_enable_debug"] = False
        data["logging_enable_stub"] = False
        data["logging_enable_info"] = False
        data["logging_enable_warn"] = False
        data["logging_enable_error"] = True
        data["logging_enable_guest"] = False
        # need to set audio output otherwise if bato is 'auto' - settings won't stick
        data["audio_backend"] = "SDL2"
              
        # custom settings
        # aspect ratio
        if system.isOptSet("ryujinxRatio"):
            data["aspect_ratio"] = system.config["ryujinxRatio"]
        else:
            data["aspect_ratio"] = "Fixed16x9"
        # vsync
        if system.isOptSet("ryujinxVSync") and system.getOptBoolean("ryujinxVSync") == False:
            data["enable_vsync"] = False
        else:
            data["enable_vsync"] = True
        # anisotropy filtering
        if system.isOptSet("ryujinxFiltering"):
            data["max_anisotropy"] = system.config["ryujinxFiltering"]
        else:
            data["max_anisotropy"] = -1
        # resolution scale
        if system.isOptSet("ryujinxScale"):
            data["res_scale"] = system.config["ryujinxScale"]
        else:
            data["res_scale"] = 1
        # backend audio
        if system.isOptSet("ryujinxAudio"):
            data["audio_backend"] = system.config["ryujinxAudio"]
        else:
            data["audio_backend"] = "SDL2"
        
        # todo - RyujinxGenerator.ryujinxControllerConfig(RyujinxConfig, system, playersControllers)

        configFile = open('/userdata/system/configs/ryujinx/Config.json', 'w+')
        configFile.write(json.dumps(data))
        configFile.close()

        # now run the emulator
        commandArray = ["/usr/ryujinx/Ryujinx", "-r", "/userdata/system/configs/ryujinx", rom ]

        return Command.Command(
            array=commandArray,
            env={
                "GDK_BACKEND": "x11",
                "SDL_GAMECONTROLLERCONFIG": controllersConfig.generateSdlGameControllerConfig(playersControllers),
                # hum pw 0.2 and 0.3 are hardcoded, not nice
                "SPA_PLUGIN_DIR": "/usr/lib/spa-0.2:/lib32/spa-0.2",
                "PIPEWIRE_MODULE_DIR": "/usr/lib/pipewire-0.3:/lib32/pipewire-0.3"
            })
    
    # controller config
    @staticmethod
    def ryujinxControllerConfig(RyujinxConfigFile, system, playersControllers):
        # pads
        RyujinxButtons = {
            "button_a":      "a",
            "button_b":      "b",
            "button_x":      "x",
            "button_y":      "y",
            "button_dup":     "up",
            "button_ddown":   "down",
            "button_dleft":   "left",
            "button_dright":  "right",
            "button_l":      "pageup",
            "button_r":      "pagedown",
            "button_plus":  "start",
            "button_minus": "select",
            "button_zl":     "l2",
            "button_zr":     "r2",
            "button_sl":     "l3",
            "button_sr":     "r3",
            "button_home":   "hotkey"
        }

        RyujinxAxis = {
            "lstick":    "joystick1",
            "rstick":    "joystick2"
        }
        # controls section
        if not RyujinxConfig.has_section("Controls"):
            RyujinxConfig.add_section("Controls")


        # Options required to load the functions when the configuration file is created
        if not RyujinxConfig.has_option("Controls", "vibration_enabled"):
            RyujinxConfig.set("Controls", "vibration_enabled", "false")
            RyujinxConfig.set("Controls", "vibration_enabled\\default", "false")    
            RyujinxConfig.set("Controls", "use_docked_mode", "true")
            RyujinxConfig.set("Controls", "use_docked_mode\\default", "true")
            #RyujinxConfig.set("Controls", "profiles\\size", 1)

        for index in playersControllers :
            controller = playersControllers[index]
            controllernumber = str(int(controller.player) - 1)
            for x in RyujinxButtons:
                RyujinxConfig.set("Controls", "player_" + controllernumber + "_" + x, '"{}"'.format(RyujinxGenerator.setButton(RyujinxButtons[x], controller.guid, controller.inputs,controllernumber)))
            for x in RyujinxAxis:
                RyujinxConfig.set("Controls", "player_" + controllernumber + "_" + x, '"{}"'.format(RyujinxGenerator.setAxis(RyujinxAxis[x], controller.guid, controller.inputs,controllernumber)))
            RyujinxConfig.set("Controls", "player_" + controllernumber + "_connected", "true")
            RyujinxConfig.set("Controls", "player_" + controllernumber + "_type", "0")
            RyujinxConfig.set("Controls", "player_" + controllernumber + "_type\\default", "0")
            RyujinxConfig.set("Controls", "player_" + controllernumber + "_vibration_enabled", "false")
            RyujinxConfig.set("Controls", "player_" + controllernumber + "_vibration_enabled\\default", "false")
        
            
        # telemetry section
        if not RyujinxConfig.has_section("WebService"):
            RyujinxConfig.add_section("WebService") 
        RyujinxConfig.set("WebService", "enable_telemetry", "false")
        RyujinxConfig.set("WebService", "enable_telemetry\\default", "false") 
        
        
        # controls section
        if not RyujinxConfig.has_section("Services"):
            RyujinxConfig.add_section("Services")
        RyujinxConfig.set("Services", "bcat_backend", "none")
        RyujinxConfig.set("Services", "bcat_backend\\default", "none") 

        ### update the configuration file
        if not os.path.exists(os.path.dirname(RyujinxConfigFile)):
            os.makedirs(os.path.dirname(RyujinxConfigFile))
        with open(RyujinxConfigFile, 'w') as configfile:
            RyujinxConfig.write(configfile)

    @staticmethod
    def setButton(key, padGuid, padInputs,controllernumber):
        # it would be better to pass the joystick num instead of the guid because 2 joysticks may have the same guid
        if key in padInputs:
            input = padInputs[key]

            if input.type == "button":
                return ("button:{},guid:{},engine:sdl,port:{}").format(input.id, padGuid,controllernumber)
            elif input.type == "hat":
                return ("engine:sdl,guid:{},hat:{},direction:{},port:{}").format(padGuid, input.id, RyujinxGenerator.hatdirectionvalue(input.value),controllernumber)
            elif input.type == "axis":
                # untested, need to configure an axis as button / triggers buttons to be tested too
                return ("engine:sdl,guid:{},axis:{},direction:{},threshold:{},port:{}").format(padGuid, input.id, "+", 0.5,controllernumber)

    @staticmethod
    def setAxis(key, padGuid, padInputs,controllernumber):
        inputx = -1
        inputy = -1

        if key == "joystick1":
            try:
                 inputx = padInputs["joystick1left"]
            except:
                 inputx = ["0"]
        elif key == "joystick2":
            try:
                 inputx = padInputs["joystick2left"]
            except:
                 inputx = ["0"]

        if key == "joystick1":
            try:
                 inputy = padInputs["joystick1up"]
            except:
                 inputy = ["0"]
        elif key == "joystick2":
            try:
                 inputy = padInputs["joystick2up"]
            except:
                 inputy = ["0"]

        try:
            return ("axis_x:{},guid:{},axis_y:{},engine:sdl,,port:{}").format(inputx.id, padGuid, inputy.id,controllernumber)
        except:
            return ("0")

    @staticmethod
    def hatdirectionvalue(value):
        if int(value) == 1:
            return "up"
        if int(value) == 4:
            return "down"
        if int(value) == 2:
            return "right"
        if int(value) == 8:
            return "left"
        return "unknown"