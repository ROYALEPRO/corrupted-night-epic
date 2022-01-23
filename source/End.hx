package;
import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class End extends MusicBeatState
{
    public function new() 
    {
        super();
    }

    var thanks:FlxText;
 
    override function create() 
    {
        super.create();
  
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        thanks = new FlxText(0, 0, FlxG.width,
			"Thanks for play the demo!\n
			The team is working very hard to release the full release soon!\n
			If you want to participate in the project so that this goes faster, talk to me on my discord: ROYAL#5081\n
			We are waiting for you :D\n
			Now you can try use the secret codes on: secret codes.txt",
			32);
        thanks.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        thanks.screenCenter(Y);
        add(bg);
		add(thanks);
        FlxG.sound.playMusic(Paths.music('freeplay'));
    }
 
 
    override function update(elapsed:Float) 
    {
        super.update(elapsed);
  
        if (controls.ACCEPT) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.sound.music.time = 6950;
            MusicBeatState.switchState(new MainMenuState());
    }   }
}