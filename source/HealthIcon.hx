package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	public var char:String = '';

	public var offsetX = 0;
	public var offsetY = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			offsetX = 0;
			offsetY = 0;
			switch (char) {
				case 'tankman' | 'tankmanlol':
					var file:FlxAtlasFrames = Paths.getSparrowAtlas('icons/TankmanIcon');
					frames = file;
					
					animation.addByPrefix(char, 'TankmanIcon', 24, true);
					animation.play(char);

					offsetY += 5;
				default:
					var name:String = 'icons/' + char;
					if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
					if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

					// lmao dont mind me just importing forever's dynamic healthicons
					var iconGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image(name));
					loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
			
					animation.add(char, [0, 1], 0, false, isPlayer);
					animation.play(char);
					updateHitbox();
			}
			this.char = char;

			updateHitbox();

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
