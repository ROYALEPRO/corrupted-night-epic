package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var bfGlitch:FlxSprite;

	var bop1:FlxTween;
	var bop2:FlxTween;

	public var fp:FlxSprite;
	public var bg:FlxSprite;
	public var frontBG:FlxSprite;

	public var transitioning:Bool = false;

	var eee:Bool = true;
	var lkp:Array<FlxKey> = [];

	//secret codes
	var tesla:Array<FlxKey> = [FlxKey.UP, FlxKey.UP, FlxKey.DOWN, FlxKey.DOWN, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.LEFT, FlxKey.RIGHT, FlxKey.B, FlxKey.A, FlxKey.ENTER];
	var sega:Array<FlxKey> = [FlxKey.M, FlxKey.C, FlxKey.S, FlxKey.E, FlxKey.G, FlxKey.A];

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		Conductor.changeBPM(61);
		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		bg = new FlxSprite(0).loadGraphic(Paths.image('menuBG'));
		bg.updateHitbox();
		bg.scale.set(1.2, 1.2);
		bg.screenCenter(Y);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		function bop(bg:FlxSprite):Void {
			bop1 = FlxTween.tween(bg, {x: -5}, 5, {
				ease: FlxEase.quadInOut,
				onComplete: function(tween:FlxTween)
				{
					bop2 = FlxTween.tween(bg, {x: 5}, 5, {
						ease: FlxEase.quadInOut,
						onComplete: function(tween:FlxTween)
						{
							bop(bg);
						}
					});
				}
			});
		}

		bop(bg);

		var logo:FlxSprite = new FlxSprite(10, 0).loadGraphic(Paths.image('titlelogo'));
		logo.scale.set(0.7, 0.7);
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		logo.updateHitbox();
		add(logo);

		bfGlitch = new FlxSprite(770, 210);
		bfGlitch.frames = Paths.getSparrowAtlas('mainmenu/menu-bf-glitch');
		bfGlitch.animation.addByPrefix('idle', 'Symbol 1', 24);
		bfGlitch.animation.play('idle');
		bfGlitch.scale.set(1.15, 1.15);
		bfGlitch.updateHitbox();
		add(bfGlitch);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		frontBG = new FlxSprite().loadGraphic(Paths.image('mainmenu/frontBG'));
		frontBG.updateHitbox();
		frontBG.scale.set(1.2, 1.2);
		frontBG.screenCenter();
		frontBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(frontBG);

		fp = new FlxSprite(0, 190).loadGraphic(Paths.image('mainmenu/followPoint'));
		fp.updateHitbox();
		fp.screenCenter(X);
		fp.antialiasing = ClientPrefs.globalAntialiasing;
		add(fp);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(45, 170 + (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.scale.set(0.8, 0.8);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (eee)
		{
			var finalKey:FlxKey = FlxG.keys.firstJustPressed();
			if(finalKey != FlxKey.NONE) {
				lkp.push(finalKey); //Convert int to FlxKey
				if(lkp.length > tesla.length || lkp.length > sega.length)
				{
					lkp.shift();
				}
				
				if(lkp.length == tesla.length)
				{
					var isDifferent:Bool = false;
					for (i in 0...lkp.length) {
						if(lkp[i] != tesla[i]) {
							isDifferent = true;
							break;
						}
					}

					if(!isDifferent)
					{
						FlxG.sound.pause();
						selectedSomethin = true;
						bfGlitch.visible = false;
						(new FlxVideo(Paths.video('aquiestatuviejainutilmiracomomelacachoooooh'))).finishCallback = function() {
							isDifferent = true;
							selectedSomethin = false;
							FlxG.sound.resume();
							bfGlitch.visible = true;
						}

						#if ACHIEVEMENTS_ALLOWED
						var achieveID:Int = Achievements.getAchievementIndex('aqui_esta_tu_vieja_mira_como_me_la_cacho');
						if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][16])) { //aquiestatuviejainutilmiracomomelacachotomeseñoraoooooo
							Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][16], true);
							giveAchievement();
							ClientPrefs.saveSettings();
						}
						#end
					}
				}
				else if(lkp.length == sega.length)
				{
					var isDifferent:Bool = false;
					for (i in 0...lkp.length) {
						if(lkp[i] != sega[i]) {
							isDifferent = true;
							break;
						}
					}

					if(!isDifferent)
					{
						FlxG.sound.pause();
						selectedSomethin = true;
						bfGlitch.visible = false;
						(new FlxVideo(Paths.video('mcsonic'))).finishCallback = function() {
							isDifferent = true;
							selectedSomethin = false;
							FlxG.sound.resume();
							bfGlitch.visible = true;
						}
					}
				}
			}
		}
		
		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										FlxG.camera.follow(fp);
										FlxTween.tween(fp, {x: 890}, 3, {ease: FlxEase.quadInOut}); 
										FlxTween.tween(FlxG.camera, {zoom: 2.3}, 3, {
											ease: FlxEase.quadInOut,
											onComplete: function(twn:FlxTween)
											{
												FlxG.sound.music.fadeOut(1.8, 0);
												FlxG.camera.fade(FlxColor.BLACK, 1.8, false, function()
												{
													MusicBeatState.switchState(new StoryMenuState());
												});
											}
										});
									case 'freeplay':
										FlxG.camera.follow(fp);
										FlxG.sound.music.fadeOut(1.5, 0);
										FlxTween.tween(fp, {x: -1000}, 1.3, {
											ease: FlxEase.sineInOut,
											onComplete: function(twn:FlxTween)
											{
												MusicBeatState.switchState(new FreeplayState());
											}
										});
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										FlxG.camera.follow(fp);
										transitioning = true;
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										FlxTween.tween(bg, {x: 1489}, 1.3, {ease: FlxEase.sineInOut});
										FlxTween.tween(frontBG, {x: 1489}, 1.3, {ease: FlxEase.sineInOut});
										FlxTween.tween(fp, {x: 2000}, 1.3, {
											ease: FlxEase.sineInOut,
											onComplete: function(twn:FlxTween)
											{
												MusicBeatState.switchState(new options.OptionsState());
											}
										});
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('aqui_esta_tu_vieja_mira_como_me_la_cacho', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "aqui_esta_tu_vieja_mira_como_me_la_cacho"');
	}
	#end
}
