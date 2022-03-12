package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;

	public static var bg:FlxSprite;
	public var frontBG:FlxSprite;

	var bop1:FlxTween;
	var bop2:FlxTween;

	public var fp:FlxSprite;

	public static var transitioning:Bool = false;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
				TitleState.lastStage = 4;
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		bg = new FlxSprite(-1511).loadGraphic(Paths.image('menuBG'));
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

		frontBG = new FlxSprite(bg.x).loadGraphic(Paths.image('mainmenu/frontBG'));
		frontBG.updateHitbox();
		frontBG.scale.set(1.2, 1.2);
		frontBG.screenCenter(Y);
		frontBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(frontBG);

		fp = new FlxSprite(511, 190).loadGraphic(Paths.image('mainmenu/followPoint'));
		fp.updateHitbox();
		fp.antialiasing = ClientPrefs.globalAntialiasing;
		add(fp);

		FlxG.camera.follow(fp);

		if(TitleState.lastStage == 1)
		{
			fp.x = -1000;
			FlxTween.tween(bg, {x: 0}, 1.3, {
				ease: FlxEase.sineInOut,
				onComplete: function(twn:FlxTween)
				{
					bop(bg);
				}
			});
			FlxTween.tween(fp, {x: 511}, 1.3, {ease: FlxEase.sineInOut});
			FlxTween.tween(frontBG, {x: 0}, 1.3, {ease: FlxEase.sineInOut});
		} else {
			bg.x = 0;
			frontBG.x = 0;
		}

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.sound.music.time < 6950)
		{
			FlxG.sound.music.time = 6950;
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.camera.follow(fp);
				transitioning = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTween.tween(bg, {x: -2511}, 1.3, {ease: FlxEase.sineInOut});
				FlxTween.tween(frontBG, {x: -2511}, 1.3, {ease: FlxEase.sineInOut});
				FlxTween.tween(fp, {x: -2000}, 1.3, {
				ease: FlxEase.sineInOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new MainMenuState());
					TitleState.lastStage = 4;
				}
			});
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}