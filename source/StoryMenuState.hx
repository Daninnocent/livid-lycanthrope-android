package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;
	var x:FlxSprite;

	var normal:FlxSprite;
	var expert:FlxSprite;

	var funnytween:FlxTween;
	var funnytween2:FlxTween;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		FlxG.camera.zoom = 1.6;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {
			ease: FlxEase.expoOut,
		});

		var bg:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menus/story/week1storymodebg'));
		bg.scrollFactor.set(0, 0);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var leftdot:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menus/freeplay/leftdot'));
		leftdot.scrollFactor.set(0, 0);
		leftdot.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftdot);

		var rightdot:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menus/freeplay/rightdot'));
		rightdot.scrollFactor.set(0, 0);
		rightdot.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightdot);

		var upperbarrier:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menus/main/upperbarrier'));
		upperbarrier.scrollFactor.set(0, 0);
		upperbarrier.antialiasing = ClientPrefs.globalAntialiasing;
		add(upperbarrier);

		var dog:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('menus/story/week1lyc'));
		dog.scrollFactor.set(0, 0);
		dog.antialiasing = ClientPrefs.globalAntialiasing;
		add(dog);

		var lowerbarrier:FlxSprite = new FlxSprite(0,-100).loadGraphic(Paths.image('menus/main/lowerbarrier'));
		lowerbarrier.scrollFactor.set(0, 0);
		lowerbarrier.antialiasing = ClientPrefs.globalAntialiasing;
		add(lowerbarrier);

		var bbg:FlxSprite = new FlxSprite(0,555).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bbg);

		var cSprite:FlxSprite = new FlxSprite(10,10);
		cSprite.frames = Paths.getSparrowAtlas('menus/main/menu_story_mode');
		cSprite.animation.addByPrefix('idle', "story_mode white", 24);
		cSprite.animation.play('idle');
		add(cSprite);
		cSprite.setGraphicSize(Std.int(cSprite.width *0.6));
		cSprite.updateHitbox();
		cSprite.antialiasing = true;
		//
		cSprite.x += 20;
		cSprite.y += 20;

		var week:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/story/week1'));
		week.scrollFactor.set(0, 0);
		week.antialiasing = ClientPrefs.globalAntialiasing;
		week.screenCenter();
		week.y += 270;
		add(week);

		expert = new FlxSprite(-340,450).loadGraphic(Paths.image('menus/story/exp'));
		expert.scrollFactor.set(0, 0);
		expert.scale.set(0.2,0.2);
		expert.antialiasing = ClientPrefs.globalAntialiasing;
		add(expert);
		FlxG.mouse.visible = true;
		normal = new FlxSprite(-780,450).loadGraphic(Paths.image('menus/story/nrm'));
		normal.scrollFactor.set(0, 0);
		normal.scale.set(0.16,0.16);
		normal.antialiasing = ClientPrefs.globalAntialiasing;
		add(normal);

		var difftext:Alphabet = new Alphabet(0, 30, 'Difficulty', true, false,0,0.5);
		difftext.diff = true;
		add(difftext);

		var scoretext:Alphabet = new Alphabet(0, 30, 'Week Score', true, false,0,0.5);
		scoretext.score = true;
		add(scoretext);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);


		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			var weekThing:MenuItem = new MenuItem(-9990, bgSprite.y + 10000, WeekData.weeksList[i]);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (weekIsLocked(i))
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.alpha =0;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);

		x = new FlxSprite(1280 - 84,10).loadGraphic(Paths.image('credits/x'));
		x.updateHitbox();
		x.scale.set(0.8,0.8);
		x.antialiasing = true;
		add(x);

		
		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 60, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
			sprDifficulty.alpha =0;
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.alpha =0;
		difficultySelectors.add(rightArrow);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, bgSprite.y + 425).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		// add(rankText);
		add(scoreText);

		changeWeek();

		#if mobileC
		addVirtualPad(FULL, A_B);
		#end

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "" + lerpScore;
		scoreText.screenCenter();
		scoreText.x += 415;
		scoreText.y += 270;

		if (FlxG.mouse.overlaps(x))
			x.scale.set(0.85,0.85);
		else
			x.scale.set(0.8,0.8);

		if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(x))
					{
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new MainMenuState());
					}
			}

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = !weekIsLocked(curWeek);

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			PlayState.alreadyshowed = true;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if(PlayState.alreadyshowed){
					LoadingState.loadAndSwitchState(new VideoState("assets/videos/Fnf-Lyccutscene1", new PlayState()));
					PlayState.alreadyshowed = false;
				}
				else {
					LoadingState.loadAndSwitchState(new PlayState());
				}
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;
		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curDifficulty == 0)
			curDifficulty = 2;
		if (curDifficulty == 3)
			curDifficulty = 1;

		if (curDifficulty == 2)
			{
				expert.alpha = 1;
				normal.alpha = 0;
			}
		else
			{
				expert.alpha = 0;
				normal.alpha = 1;
			}
			if(funnytween != null) {
				funnytween.cancel();
			}
			if(funnytween2 != null) {
				funnytween2.cancel();
			}
		expert.scale.set(0.24,0.24);
		normal.scale.set(0.2,0.2);
		funnytween2 = FlxTween.tween(normal, {"scale.x": 0.16,"scale.y": 0.16}, 0.4, {ease: FlxEase.cubeOut,onComplete: function(twn:FlxTween) {
			funnytween2 = null;
		}
	});
		funnytween = FlxTween.tween(expert, {"scale.x": 0.2,"scale.y": 0.2}, 0.4, {ease: FlxEase.cubeOut,onComplete: function(twn:FlxTween) {
			funnytween = null;
		}
	});

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 15;
				FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
		}
		updateText();
	}

	function weekIsLocked(weekNum:Int) {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
