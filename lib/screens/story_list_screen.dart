import 'package:flutter/material.dart';
import 'story_reader_screen.dart';
import '../models/story.dart';
import 'paywall_screen.dart';

class StoryListScreen extends StatelessWidget {
  StoryListScreen({Key? key}) : super(key: key);

  final List<Story> stories = [
    Story(
      title: "The Quiet Train in the Night",
      content:
          '''The train waits quietly at the platform, lights glowing softly against the night. There's no crowd. No rush. Just open doors and a gentle invitation to step inside.

You take your seat by the window. The fabric is cool and comfortable beneath your hands. As the doors close, the outside world fades slightly, as if someone gently turned down its volume.

The train begins to move, not with a jolt, but with a smooth, steady pull forward. The sound of the tracks settles into a calm rhythm beneath you. A rhythm that doesn't demand attention--only presence.

Your breathing slows naturally.

In...
and out.

Nothing needs to be done. The train is already going where it needs to go.

Outside the window, small towns drift past. Streetlights glow dimly. Buildings rest quietly, their windows dark and still. Everyone here has already settled into the night.

The train does not stop. It simply observes, the way you do--without judgment, without attachment.

Each town fades into the distance, replaced by darkness again. Your thoughts begin to do the same. Appearing briefly... then dissolving.

The rhythm continues.

Soft.
Steady.
Predictable.

The seat supports your body fully now. Shoulders soften. Jaw relaxes. Even your eyelids feel heavier, blinking more slowly each time.

The train hum becomes background noise, like a memory you don't need to hold onto. You don't have to follow the journey. You can simply rest inside it.

And as the train continues forward, the night grows deeper and quieter around you.

The train enters a long, open stretch of night. No towns. No lights. Just darkness stretching wide and calm.

This part of the journey feels timeless. The train could be moving for minutes... or hours. It doesn't matter.

Your breathing syncs fully now with the motion beneath you.

In...
out...

You notice the carriage is nearly empty. A few seats away, someone sleeps peacefully, head tilted gently toward the window.

No conversation. No movement. Just shared stillness.

The world feels paused--not frozen, but resting.

Your body understands this moment. Muscles release tension they've been holding all day without you realizing it.

Thoughts begin to lose their edges. They no longer form full sentences. Just fragments. Sensations. Images that drift and fade before becoming anything solid.

The train continues its quiet work.

Carrying you.
Supporting you.
Asking nothing in return.

Your awareness grows lighter, floating just above sleep.

Somewhere, far ahead, the train begins to slow. Not enough to wake you. Just enough to signal that the journey is complete.

You don't need to open your eyes.

You don't need to move.

The train has done its job.

And now...
you are free
to rest
completely.''',
      audioPath: "audio/stories/the quiet train in the night.mp3",
      premium: false,
    ),
    Story(
      title: "The Lantern by the Quiet Harbor",
      content: '''The air near the harbor is calm tonight...
cool, but gentle...
carrying the quiet scent of salt and distant water.

The sky has already darkened completely,
and the last traces of daylight
have faded beyond the horizon.

Everything feels slower here...
as though time itself has decided to rest.

Near the edge of the dock,
a single lantern glows softly.

Its light is warm...
steady...
unhurried.

It reflects across the water in long, wavering lines,
moving gently with each small ripple,
never breaking,
never rushing.

The harbor is quiet now.
Boats sit peacefully in their places,
tethered loosely,
rocking almost imperceptibly.

Their ropes make the softest sounds
as they sway,
a rhythm so subtle
it barely reaches awareness.

You find yourself standing nearby,
comfortable...
unbothered...
with nowhere else you need to be.

The wooden planks beneath your feet
feel solid and reassuring,
warmed slightly from the day,
cooling slowly as the night settles in.

Somewhere in the distance,
water laps gently against stone,
a sound that feels older than memory.

The lantern flickers once...
then steadies again.

Its glow creates a small circle of light,
holding back the darkness
without effort.

Beyond it,
the night stretches endlessly...
soft...
open...
safe.

You begin to walk slowly along the dock,
each step easy,
unforced.

There is no hurry here.
No destination to reach.
Only the quiet invitation
to move at your own pace.

As you walk,
you notice the way the air feels on your skin...
cool,
clean,
comforting.

Each breath arrives naturally,
and leaves just as gently.

The harbor seems to breathe with you...
in...
and out...
slowly...
peacefully.

You pause near the lantern,
standing within its glow.

The light feels calming,
as if it's meant to be here,
watching over the water,
keeping everything steady through the night.

Reflections shimmer softly below,
stretching and narrowing,
never settling into one shape for long.

It's easy to watch them,
to let your eyes soften,
to allow your thoughts
to drift just as freely.

Nothing asks for your attention.
Nothing pulls you away.

A bench sits nearby,
smooth from years of quiet use.

You settle onto it comfortably,
the wood cool beneath you,
supportive and still.

From here,
the harbor opens up in front of you...
wide...
quiet...
resting.

The boats barely move now,
as though they too are drifting toward sleep.

Their outlines blur slightly in the low light,
edges softened by shadow and reflection.

The lantern continues its steady glow,
unchanging...
patient.

You can hear your breathing clearly now,
slow and even,
matching the calm of the water.

With every breath out,
your body feels a little heavier,
a little more settled.

Shoulders relax...
jaw loosens...
hands rest easily.

The night holds everything gently,
asking nothing in return.

Somewhere far away,
a bell rings softly...
once...
then fades.

The sound dissolves into the darkness,
leaving only stillness behind.

You remain seated,
watching the harbor exist exactly as it is.

No expectations.
No effort.

The lantern's light seems warmer now,
its glow wrapping around you
like a quiet reassurance.

You notice how comfortable you feel...
how safe...
how untroubled.

Time feels different here.
Unmeasured.
Unimportant.

Moments stretch softly,
blending into one another,
without edges.

The water continues its gentle movement,
a constant, soothing presence.

Your eyes may grow heavier now...
blinking slowly...
lingering closed just a little longer each time.

There's no need to fight it.
The harbor is watching over everything.

The lantern remains steady,
holding the night together
with its simple, patient light.

And as the quiet deepens,
as the air cools just slightly more,
your awareness begins to drift...

like reflections on the water...
slow...
soft...
unconcerned with where they end.

The harbor rests.
The lantern glows.
And you are free
to rest as well.''',
      audioPath: "audio/stories/the lantern by the quiet harbor.mp3",
      premium: false,
    ),
    Story(
      title: "A cabin where time slows",
      content: '''Somewhere far from schedules and clocks,
there is a small cabin…
quiet…
patient…
resting among tall trees.

The path leading to it is soft underfoot,
covered with pine needles and leaves,
each step muted,
as though the forest itself prefers silence.

The air here feels different…
cool and clean,
carrying the faint scent of wood and earth.

As you approach the cabin,
its windows glow gently,
warm light spilling outward,
welcoming without urgency.

There is no sound of traffic.
No distant voices.
Only the quiet presence of the trees,
standing calmly all around.

You reach the door and step inside.

The cabin greets you with warmth,
the kind that wraps around you slowly,
easing away the weight of the day.

Wooden walls hold the quiet close,
softening every sound.

A fire rests in the hearth,
its flames low and steady,
crackling only when they choose.

You take a moment to stand still,
allowing your body to adjust,
to release whatever it’s been carrying.

Time feels slower here.
Unmeasured.
Unconcerned.

There is a chair nearby,
wide and comfortable,
waiting as though it has all night.

You settle into it easily,
the wood firm and supportive,
a blanket resting within reach.

As you pull it over yourself,
warmth spreads gradually,
not rushing…
not demanding attention.

Outside,
the wind moves gently through the trees,
a soft, distant sound,
like a slow exhale.

Inside the cabin,
everything feels steady and safe.

Your breathing begins to slow naturally,
matching the calm rhythm of the space.

With each breath out,
your shoulders relax…
your hands loosen…
your thoughts drift further apart.

The firelight flickers lazily across the walls,
casting soft shadows
that move without pattern.

It’s easy to watch them,
easy to let your eyes soften,
easy to do nothing at all.

Somewhere nearby,
a kettle rests quietly,
long since finished,
content to remain still.

The cabin seems to understand rest.

It holds the silence carefully,
never breaking it,
never filling it unnecessarily.

You become aware of the weight of your body
settling more fully into the chair…
supported…
held.

Your feet feel warm…
your legs heavy…
your breathing deep and even.

Outside,
night settles in completely.

The forest grows darker,
but never threatening.

Branches sway slowly,
leaves whispering softly,
as though sharing secrets meant only for sleep.

The fire shifts gently,
its glow steady and reassuring.

You might notice your thoughts growing quieter now…
arriving more slowly…
drifting away before they can form fully.

There’s no need to follow them.
No need to hold on.

The cabin exists outside of time.

Minutes stretch.
Then soften.
Then dissolve.

Nothing here needs your attention.
Nothing asks for effort.

Your eyelids may feel heavier now…
closing briefly…
opening again only when they feel like it.

Each breath feels deeper than the last,
filling your chest easily,
leaving just as gently.

The warmth around you seems to increase,
not in temperature,
but in comfort.

The blanket rests perfectly,
the chair supports without pressure,
the cabin remains still.

Somewhere deep within,
your body recognizes this place.

It knows it is safe.
It knows it can rest.

The fire’s glow becomes softer,
edges blurring slightly,
light blending into shadow.

Your awareness begins to drift,
like smoke rising slowly upward,
unconcerned with direction.

The forest continues its quiet vigil,
standing calmly through the night.

The cabin holds you gently,
protective and still.

And as time slows even further,
as thoughts fade into the background,
sleep moves closer…

unhurried…
unforced…
natural.

The cabin remains,
steady and warm,
as you drift comfortably
into rest.''',
      audioPath: "audio/stories/A cabin where night slows.mp3",
      premium: true,
    ),
    Story(
      title: "The Lighthouse That Only Shines For One Person",
      content:
          '''There is a lighthouse on the edge of the Atlantic coast that does not appear on any map.

It does not guide ships.

It does not warn sailors.

And according to the villagers nearby, it only shines for one person at a time.

Daniel had not meant to stay in the village longer than a night. He was traveling — trying to escape something he refused to name — when the storm rolled in and the road flooded. The only inn had one room left.

The innkeeper, an older woman with silver hair and watchful eyes, asked him a strange question while handing over the key.

"Has the light called you yet?"

Daniel smiled politely. He assumed it was a superstition meant to entertain tourists passing through the quiet coastal town.

That night, sometime after two in the morning, he woke to pale brightness drifting across the ceiling.

Not lightning.

Not headlights.

A steady white beam moving slowly from one wall to the other.

Back.

And forth.

He sat up and turned toward the window.

Far beyond the cliffs, cutting through the darkness, a lighthouse was shining.

But earlier that evening, the coastline had been empty. He had stood outside before bed and watched the horizon. There had been nothing but black ocean stretching endlessly under the sky.

The beam continued its calm rotation. When it reached the inn, it seemed to slow, lingering just a moment longer before moving on.

Daniel told himself it had always been there.

He had simply missed it.

The next morning, he mentioned it over breakfast.

The room grew quiet.

Two fishermen paused mid-conversation. An elderly man lowered his newspaper.

The innkeeper met Daniel's eyes and said softly, "It only appears when someone is ready."

"Ready for what?" he asked.

She only smiled and returned to the counter.

That night, the beam returned.

This time it paused at his window.

Not long.

But long enough to feel deliberate.

As if aware of him.

The following evening, without fully deciding to, Daniel found himself walking toward the cliffs. The path felt unfamiliar yet obvious, as though it had always been waiting.

The farther he walked, the quieter the world became. The wind softened. The waves seemed distant. Even the air felt still.

Then he saw it.

The lighthouse stood tall on a rocky outcrop that should not have existed. Its surface glowed faintly in the dark, smooth and pale, as though lit from within.

The beam rotated slowly, steady and unhurried, like a heartbeat.

The door was unlocked.

Inside, there was no dust, no machinery, no cables. Only a spiral staircase rising into soft white light.

Each step felt lighter than it should have.

At the top, there was no lantern room.

Only a mirror.

It did not reflect Daniel standing there.

Instead, it showed moments.

Small, quiet memories.

The phone call he never returned.

The apology he rehearsed but never delivered.

The night he left without explaining why.

The person he convinced himself he no longer needed.

The images shifted — not accusing, not cruel — simply honest.

They showed not only what had happened, but what would continue if nothing changed.

Loneliness disguised as independence.

Silence disguised as strength.

Distance disguised as freedom.

The lighthouse was not guiding ships.

It was guiding him.

It existed for one person at a time, illuminating what they had avoided seeing.

A warmth filled the room. Not heat, not brightness, but clarity.

A question formed in his thoughts.

Would he return unchanged, or face what he had been running from?

The mirror divided into two reflections.

In one, he left the village in the morning and forgot everything. He continued drifting from place to place, telling himself he preferred it that way.

In the other, he made a call. He listened instead of defended. He returned instead of disappeared.

The beam outside grew brighter, though it did not hurt his eyes.

Daniel closed them.

For the first time in months, he allowed himself to feel what he had buried under distance.

When he opened his eyes again, the mirror was gone.

The staircase was gone.

He was standing alone on the cliffs at dawn.

The lighthouse had vanished.

Only the ocean remained under the rising sun.

The next morning, the innkeeper watched him check out.

"Did it shine for you?" she asked.

"Yes," Daniel replied.

"And?"

He glanced at his phone.

A message had been sent hours earlier.

A reply waited.

"I think it worked," he said.

The innkeeper nodded, as though she had heard that answer many times before.

That night, somewhere along some forgotten coastline, a lighthouse appeared.

Not on any map.

Not for ships.

Not for sailors.

But for one person.

Exactly when they were ready.''',
      audioPath:
          "audio/stories/the lighthouse that only shines for one person.mp3",
      premium: false,
    ),
    Story(
      title: "The Road That Remembers Every Step",
      content: '''There is a stretch of road that does not appear on any map.

It does not belong to any country.

It has no signs, no mile markers, no intersections.

Most people never see it.

But sometimes, late at night, when someone is walking with thoughts too heavy to carry…

The road appears beneath their feet.

Mila first noticed it after she missed her bus.

The city had gone quiet. Storefronts were dark. Traffic lights blinked yellow into empty intersections.

She decided to walk instead of waiting for another ride.

At first, everything looked familiar.

The same sidewalks.

The same buildings.

But after a few blocks, the pavement changed.

It grew smoother. Wider.

The air felt softer.

The city sounds faded until all she could hear was the steady rhythm of her footsteps.

She turned around.

The street behind her was gone.

Not vanished — just… distant.

Blurred by a gentle silver mist.

Ahead of her stretched a long, open road under a sky filled with more stars than the city should allow.

Mila should have felt afraid.

Instead, she felt something else.

Relief.

The road was quiet in a way that did not demand anything from her.

No notifications.

No expectations.

No unfinished conversations waiting in her pocket.

Just the sound of her steps.

After a while, she began to notice something strange.

With each step forward, faint images shimmered briefly on the surface of the road.

Not reflections.

Memories.

The day she chose the safe option.

The message she never sent.

The opportunity she convinced herself wasn't meant for her.

They appeared beneath her feet and dissolved as she passed over them.

The road was not replaying her past.

It was measuring it.

She slowed.

The images became clearer.

Moments when she stayed quiet instead of speaking.

Moments when she agreed instead of disagreeing.

Moments when she shrank instead of standing.

The road felt longer now.

Heavier.

As if it stretched in proportion to everything she had postponed.

A breeze moved across the open space.

Not cold.

Just present.

Mila stopped walking.

Immediately, the images stopped too.

The road ahead grew darker.

Unformed.

Waiting.

She realized something then.

The road did not move unless she did.

It did not decide direction.

It responded.

Carefully, she took one step forward.

The surface brightened slightly.

Not dramatically.

Just enough to see a little farther.

Another step.

The stars above shifted, aligning gently over the path ahead.

The memories beneath her feet began to change.

Now she saw different scenes.

A version of herself speaking clearly.

A version of herself declining politely.

A version of herself choosing without apology.

They were not guarantees.

They were possibilities.

The road was not showing her destiny.

It was showing her momentum.

The farther she walked with intention, the clearer the path became.

When doubt returned, the mist thickened.

When she hesitated, the surface dimmed.

When she moved with certainty — even small certainty — the road extended smoothly before her.

Time felt different there.

Slower.

Kinder.

There was no rush to reach the end.

No finish line waiting to judge her pace.

After what felt like hours, she saw something in the distance.

Not a building.

Not a person.

Just a horizon glowing faintly gold.

The closer she moved toward it, the lighter her chest felt.

Not because her problems disappeared.

But because they felt… organized.

Placed where they belonged instead of stacked on top of each other.

She understood now.

The road did not appear to guide her somewhere new.

It appeared to remind her that she was already moving.

Even when she believed she was stuck.

Eventually, the mist behind her began to thin.

City sounds drifted faintly back into the air.

Car engines.

Distant sirens.

The world returning.

The golden horizon softened.

The stars faded one by one.

Mila blinked.

She was standing on a familiar sidewalk.

The regular pavement beneath her feet.

Streetlights humming quietly overhead.

Had she been walking the entire time?

Had she moved at all?

She wasn't sure.

But something inside her had shifted.

Her phone buzzed in her pocket.

A message she had been avoiding replying to for days.

Her fingers hovered.

This time, she answered clearly.

Not perfectly.

Not dramatically.

Just honestly.

As she continued down the normal street, she noticed something subtle.

Her steps felt different.

Less rushed.

More deliberate.

And somewhere, far from any map, under a sky untouched by city lights, a long quiet road waits.

It does not force anyone onto it.

It does not call loudly.

But when someone grows tired of standing still inside their own thoughts…

The pavement smooths beneath their feet.

The mist clears.

And the road begins to remember every step they are finally ready to take.''',
      audioPath: "audio/stories/the road that remembers every step.mp3",
      premium: false,
    ),
    Story(
      title: "The Man Who Sat on the Last Bench",
      content:
          '''Every evening at the same quiet park, a man sat on the last bench facing the lake.

He arrived just before sunset.

Not early.

Not late.

Always at that soft in-between hour when the sky turns gold and the world grows quieter.

He never brought a book.

Never played music.

He simply watched the water.

One evening, a woman sat at the other end of the same bench.

Not too close.

Not far.

Just enough space for silence to remain comfortable.

They didn’t speak.

The lake moved in small, patient ripples.

Birds drifted across the fading light.

After a while, she said softly, “It’s the calmest place in the city.”

He nodded. “It feels like time slows down here.”

That was all.

The next evening, she returned.

And so did he.

They didn’t plan it.

They simply arrived.

At first, their conversations were small.

About the color of the sky.

About how the water looked darker before rain.

About the old tree near the shore that leaned slightly to one side.

They never asked the important questions.

Not yet.

Days turned into weeks.

They began sitting closer.

Not touching.

Just closer.

One evening, she didn’t come.

The bench felt longer than usual.

The lake seemed wider.

The sky faded too quickly.

He told himself it didn’t matter.

People are allowed to disappear.

But the next evening, he arrived earlier than usual.

And she was already there.

“I thought you weren’t coming back,” he admitted.

She smiled gently. “I thought the same about you.”

The lake shimmered softly between them.

Silence returned — but this time it felt warmer.

Gradually, their words deepened.

She told him she once wanted to move far away but never did.

He told her he used to rush through life, until he realized he wasn’t sure where he was going.

They laughed at small things.

They noticed the same details.

The way the wind curved across the water.

The way the first star always appeared just above the old leaning tree.

One evening, rain began to fall unexpectedly.

Soft at first.

Then steady.

Neither moved.

The world emptied around them as others hurried home.

They remained on the last bench, letting the rain gather in their hair and on their shoulders.

“It’s strange,” she said quietly, “how something can feel familiar so quickly.”

He looked at her then.

Not at the lake.

Not at the sky.

Just at her.

“Maybe it’s because we were already looking for each other.”

The rain softened.

The clouds thinned.

The first star appeared.

Without thinking, their hands brushed.

Not dramatic.

Not urgent.

Just a quiet meeting of warmth.

Neither pulled away.

The lake breathed in gentle waves.

In.

Out.

In.

Out.

They did not promise forever.

They did not speak about the future.

They simply sat together as the sky turned deep blue.

And something steady settled between them.

Not fireworks.

Not thunder.

Just calm.

A kind of love that feels like arriving somewhere you didn’t know you were traveling toward.

Years later, the last bench would still face the lake.

The old tree would still lean slightly to one side.

The first star would still appear above it.

And sometimes, as evening falls, two figures can be seen sitting there.

Closer now.

Shoulders touching.

Watching the water move slowly in the fading light.

Not because they are afraid to leave.

But because they both understand something simple:

Love does not always arrive loudly.

Sometimes it sits quietly beside you.

On the last bench.

Waiting for you to notice.''',
      audioPath: "audio/stories/the man who sat at the last bench.mp3",
      premium: false,
    ),
    Story(
      title: "The Man Who Remembered Her in Every Lifetime",
      content: '''Elias first saw her in the rain.

It was an ordinary evening. Streetlights glowed against wet pavement, and the city hummed with the quiet rush of people heading home. Umbrellas drifted like dark flowers through the mist.

She was the only one standing still.

A red umbrella tilted against the wind. Strands of dark hair brushed her cheek. She looked neither hurried nor lost — just paused, as though waiting for something she couldn’t name.

Then her eyes met his.

Nothing dramatic happened.

No thunder. No music.

And yet something inside him shifted deeply.

His breath caught. His chest tightened — not in anxiety, but in recognition.

Not attraction.

Recognition.

Like hearing a lullaby you once knew by heart.

Her expression changed too. Confusion softened into something quieter. Familiar.

A whisper brushed through his mind.

There you are.

She walked past him slowly. Their shoulders nearly touched.

For a moment, he almost reached for her — though he had no reason to.

When he turned, she had stopped.

And she was looking back.

That night, Elias dreamed of sand and fire.

He stood beneath a bronze-colored sky, wearing armor that felt heavy but natural. His hands were scarred. The air smelled of smoke and warm earth.

Across a silent battlefield, she stood dressed in white, hair braided with gold thread.

She looked exactly the same.

The same soul.

She began running toward him.

He knew her name without being told.

“Amara.”

He woke with tears on his face.

They met again three days later in a quiet bookstore café.

Soft music played. Coffee steamed in porcelain cups. Rain tapped gently against the windows.

She turned in line and froze when she saw him.

“You,” she said softly, like she’d misplaced something important and just found it.

Her hand trembled slightly. The cup tipped.

He caught it before it fell.

Their fingers brushed.

The world tilted — not physically, but internally, as though gravity had been rearranged.

“I know this sounds strange,” she whispered, “but I feel like I know you.”

Elias swallowed. “I was hoping you’d say that.”

Her name was Amara.

He didn’t ask how he already knew.

Time moved differently with her.

Conversations flowed without effort. Silences felt warm. They reached for the same books, ordered the same tea, paused at the same sunsets.

Once, while walking by the ocean, she stopped suddenly.

“Do you ever have dreams,” she asked, “that feel like memories?”

“Yes.”

“Are we in them?”

“Yes.”

She didn’t look surprised.

“Me too.”

The dreams grew clearer.

A desert city under lantern light. They were scholars mapping constellations together.

A wooden ship cutting through violent waves. She tied a rope while he steadied the mast.

A small countryside village where they chased fireflies as children.

In one life, they married young.

In another, they were best friends who never confessed.

In another, war separated them before they could say goodbye.

Different lifetimes.

Same ending.

They always found each other.

And something always pulled them apart.

Until now.

One quiet evening, they sat by the sea.

The sky melted into soft gold and violet. Waves moved in steady rhythm, like a slow breath.

Amara rested her head on his shoulder.

“What if we’ve been doing this forever?” she asked.

“Doing what?”

“Finding each other.”

The wind moved gently through her hair.

“What if souls don’t forget? What if they just… recognize?”

Elias took her hand.

“Then let’s promise something.”

She looked up at him.

“In every lifetime. No matter how long it takes. We look for each other.”

Her eyes filled, but she smiled.

“I think we always have.”

Years passed quietly.

They built a small home near the water. Mornings were slow. Evenings softer still.

Sometimes they woke at the same time from the same dream and simply smiled.

They stopped fearing loss.

Because they understood now.

Time could interrupt them.

But it could not erase them.

They grew older together. Wrinkles forming like gentle maps of laughter shared.

One winter night, snow falling softly beyond the window, Elias felt the quiet shift inside his body.

Not pain.

Completion.

Amara held his hand beside their bed.

Her forehead rested against his.

“Find me again,” she whispered.

“Always,” he breathed.

His final exhale felt less like an ending — and more like stepping through a doorway.

Another century.

A crowded train station filled with strangers.

A young woman stepped off the platform and paused suddenly.

Her heart fluttered without reason.

Across the room, a man stopped walking.

Their eyes met.

Silence expanded between them.

Recognition bloomed slowly.

Softly.

Inevitably.

A faint smile curved across both their faces at the same time.

As if they were thinking the same words.

There you are.''',
      audioPath:
          "audio/stories/the man who remembered her in every lifetime.mp3",
      premium: false,
    ),
    Story(
      title: "When the Moon Meets the Tide",
      content:
          '''Long before clocks began counting hours, the Moon fell in love with the Ocean.

Not in a loud way.

Not in a way that demanded anything in return.

But in the quiet way that light rests gently on water.

Each night, the Moon would rise slowly into the sky, silver and patient.

And below, the Ocean would stretch wide and endless, breathing in slow, steady waves.

They never touched.

Not truly.

There was always distance between them.

Sky and sea.

Light and depth.

Yet something invisible connected them.

When the Moon grew brighter, the Ocean leaned closer to shore.

When the Moon softened, the Ocean relaxed and drifted back.

It was not force.

It was not command.

It was a conversation.

One evening, when the world was very still, the Moon decided to descend a little lower than usual.

Just slightly.

Just enough to see the surface more clearly.

The Ocean noticed immediately.

Its waves grew gentler.

Flatter.

As if becoming a mirror.

“Why do you move when I change?” the Moon whispered, her voice a thread of silver light.

The Ocean responded in a deep, calm rhythm.

“Because your presence reminds me to rise.”

The Moon glowed warmer.

“I have never touched you,” she said.

“I only shine.”

The Ocean rolled softly along the shore.

“You do not need to touch to change something,” it replied.

“For years, I believed my tides were my own.”

“But when you appear, I feel something pull gently within me.”

The Moon thought about this.

She had always felt alone in the sky.

Surrounded by stars, yes.

But distant from everything below.

She had never realized her quiet light mattered.

That night, clouds drifted slowly across the horizon.

For a moment, they covered the Moon completely.

The Ocean grew uncertain.

Its waves became uneven.

Restless.

Without the silver glow above, it felt heavier.

Darker.

The wind stirred.

The surface rippled sharply.

Then, slowly, the clouds passed.

The Moon returned.

Soft.

Steady.

The Ocean calmed almost immediately.

Its waves smoothed into long, even breaths.

In.

Out.

In.

Out.

“You see?” the Ocean murmured.

The Moon understood now.

Even from afar, she shaped something vast.

Even without touching, she created movement.

And the Ocean understood something too.

Without its surface reflecting her glow, the Moon’s light would drift unnoticed into darkness.

They were separate.

But not isolated.

The Moon needed the Ocean to shimmer.

The Ocean needed the Moon to rise.

From that night on, they stopped longing for closeness.

They stopped wishing to trade places.

Instead, they embraced the space between them.

Because it was in that space that their connection lived.

Every evening, the Moon rises.

Every night, the Ocean answers.

Waves leaning forward.

Light leaning downward.

Not to meet.

But to acknowledge.

A quiet exchange across distance.

And somewhere along the shoreline, if you stand very still and listen to the tide, you might feel it.

The gentle pull.

The slow rhythm.

The calm reminder that even from far away…

We can move one another.

Without force.

Without noise.

Simply by being present.''',
      audioPath: "audio/stories/when the moon meets the tide.mp3",
      premium: false,
    ),
    Story(
      title: "When the River Learned to Fly",
      content:
          '''At the center of a quiet meadow ran a clear, slow-moving river.

In that river lived a koi fish with scales the color of pale sunrise.

He spent his days gliding through cool water, weaving between reeds, watching the sky ripple above him.

High above that same meadow soared a white heron.

Her wings were wide and patient, her movements smooth as wind.

She spent her days riding warm currents, watching the river shimmer far below.

They noticed each other often.

The koi would pause near the surface when a long shadow passed overhead.

The heron would circle slowly when a flicker of gold moved beneath the water.

Neither envied the other.

But both wondered.

What does it feel like to live there?

One evening, when the sun dipped low and painted everything in soft amber light, the meadow grew very still.

The air felt different.

Thicker.

Full of possibility.

The heron landed at the river’s edge.

The koi rose near the surface.

They looked at one another — sky and water meeting in the quiet space between.

A single drop of light fell from the fading sun into the river.

It did not sink.

It did not splash.

It hovered.

Glowing gently between them.

The heron tilted her head.

The koi drifted closer.

And without quite understanding how, they both leaned toward it.

The world shifted.

Not sharply.

Not suddenly.

Just softly — like turning a page.

The koi felt something unfamiliar.

Lightness.

The cool weight of water vanished.

In its place was air — vast and open.

Below him, the meadow stretched wide.

Above him, clouds drifted slowly.

He was no longer swimming.

He was flying.

His fins had become wings.

They moved instinctively, catching the wind.

At the same time, the heron felt herself sink gently downward.

The air thinned around her.

Coolness surrounded her.

She opened her eyes to a world of green light and swaying plants.

The river carried her forward.

Her wings had become fins.

She was no longer flying.

She was swimming.

At first, both panicked.

The koi flapped too quickly, wobbling in the sky.

The heron thrashed in the water, stirring small clouds of sand.

But the meadow remained calm.

The river kept flowing.

The wind kept moving.

Gradually, they slowed.

The koi stopped fighting the air and let the breeze lift him.

He discovered that flying was not about force.

It was about surrender.

The heron stopped resisting the current and allowed the water to guide her.

She discovered that swimming was not about control.

It was about trust.

The koi circled higher, feeling warmth from the fading sun brush against his new wings.

He saw how the river curved gently through the meadow.

How small the reeds looked from above.

How wide the sky truly was.

The heron drifted deeper, watching light filter down in dancing patterns.

She felt the rhythm of the current, steady and constant.

She saw how the sky shimmered above the surface.

How the world looked softer from below.

Time moved differently in each place.

In the sky, moments felt endless.

In the river, they felt deep.

Eventually, as night began to settle, the glowing drop of light returned.

Hovering once again between water and air.

The koi descended.

The heron rose.

They paused at the surface — two beings meeting at the seam of their worlds.

And gently, without fear this time, they moved toward the light.

The meadow shifted again.

Softly.

The koi felt cool water wrap around him once more.

The heron felt wind lift beneath her wings.

Everything returned.

But not unchanged.

The koi no longer wondered what the sky felt like.

The heron no longer wondered about the river’s embrace.

They carried each other’s worlds within them now.

When the heron flew overhead, the koi swam peacefully below.

When the koi flickered near the surface, the heron glided calmly above.

Neither world seemed distant anymore.

Because once, for a quiet evening, the river had learned to fly.

And the sky had learned to flow.

And in that gentle exchange, both had grown lighter.''',
      audioPath: "audio/stories/where the river learned to fly.mp3",
      premium: false,
    ),
    Story(
      title: "The Lantern Deer and the Cloud Cat",
      content:
          '''At the edge of a valley that did not appear on maps, there lived a deer made of quiet light.

    His antlers glowed like warm lanterns at dusk.

    Not bright enough to blind.

    Just bright enough to guide.

    He wandered the valley each evening, and wherever his hooves touched the earth, small silver flowers bloomed.

    Above that same valley drifted a cat made of clouds.

    Her fur was soft mist.

    Her tail curled like slow-moving wind.

    She did not walk the ground.

    She floated just above it, weightless and silent.

    By day, they never saw each other.

    The deer rested beneath trees.

    The cloud cat dissolved into pale sky.

    But every night, when the moon rose high and the world softened into blue and silver, their paths crossed.

    The first time it happened, the deer noticed a shadow gliding beside him.

    Not dark.

    Not heavy.

    Just cool and gentle.

    He looked up.

    Two glowing eyes blinked from a drifting cloud shaped like a cat.

    The cloud cat tilted her head, curious about the small lantern lights moving below.

    The deer paused.

    The cloud paused.

    Neither spoke.

    Magic does not always need words.

    The deer stepped forward again, and the cat floated alongside him.

    As he walked, his antlers cast warm light across the valley.

    The light passed through the cloud cat, turning her mist into faint gold.

    And wherever her soft body drifted, the air shimmered slightly, like quiet stardust settling.

    Together, they moved in slow rhythm.

    Hoof.

    Drift.

    Hoof.

    Drift.

    The valley responded to them.

    Fireflies gathered near the lantern glow.

    The wind softened around the cloud cat’s path.

    The night itself seemed to breathe easier.

    One evening, the valley grew darker than usual.

    Heavy clouds covered the moon.

    The path ahead disappeared into shadow.

    The deer’s lantern-light dimmed slightly, as if unsure.

    The cloud cat felt the air thicken.

    For the first time, the valley did not feel calm.

    It felt uncertain.

    The deer stopped walking.

    The cloud cat lowered herself closer to the ground.

    Without speaking, they leaned toward each other.

    The deer lifted his head higher.

    His antlers glowed a little brighter.

    The cloud cat gathered herself tighter, her mist becoming denser, fuller.

    When the warm lantern light touched the cloud cat’s silver mist, something changed.

    The light did not pass through this time.

    It stayed.

    It spread.

    The cloud cat began to glow from within.

    Soft at first.

    Then steady.

    The deer’s lanterns brightened in response.

    Warm and cool light blended together.

    Gold and silver.

    Earth and sky.

    The valley slowly reappeared around them.

    Not as bright as before.

    But clear enough to continue.

    They realized something simple.

    Alone, they carried gentle magic.

    Together, they carried more.

    From that night on, whenever the valley darkened, they walked side by side.

    The deer lighting the ground.

    The cloud cat lighting the air.

    They never rushed.

    They never tried to own the night.

    They simply moved through it.

    Hoof.

    Drift.

    Hoof.

    Drift.

    And as seasons passed, the valley became known — though no one knew why — as a place where travelers felt safe in the dark.

    Some said they sensed warm light near their feet.

    Others said they felt a soft coolness brush their shoulders.

    Few ever saw the deer.

    Fewer still noticed the cloud cat.

    But those who passed through the valley slept peacefully afterward.

    Because somewhere in the quiet blue night, a lantern deer and a cloud cat still walk together.

    Lighting the ground.

    Lighting the sky.

    And keeping the dark gentle.''',
      audioPath: "audio/stories/the lantern deer and the cloud cat.mp3",
      premium: false,
    ),
    Story(
      title: "The Fox and the Wale",
      content:
          '''In a quiet part of the world where the forest met the sea, there lived a small silver fox.

She walked lightly across moss and fallen leaves, listening to the distant sound of waves beyond the trees.

She had never seen the ocean up close.

But every night, she heard it breathing.

In and out.

Slow and steady.

Far beyond the shoreline, beneath the dark surface of the water, there lived a whale.

Old and gentle.

He moved through the deep currents like drifting wind through tall grass.

He had never stepped onto land.

But sometimes, in the stillness before dawn, he could hear the forest whispering.

Leaves brushing together.

Branches shifting softly.

Two worlds.

Separated by sand and tide.

Connected by sound.

One evening, when the sky turned lavender and the first stars began to appear, the fox wandered farther than usual.

The trees thinned.

The scent of salt grew stronger.

The ground beneath her paws became softer.

Until finally, she stepped out of the forest and onto the shore.

The ocean stretched endlessly before her.

Quiet. Vast. Reflective.

She stood very still.

The waves rolled toward her in slow rhythm.

In.

Out.

In.

Out.

Far beneath the surface, the whale felt something different.

A presence at the edge of the world.

Not loud.

Not threatening.

Just curious.

He rose slowly toward the surface, his movement smooth and unhurried.

When he broke through the water, the sea barely rippled.

The fox saw him — a dark, gentle shape rising from the silver water.

She did not run.

The whale did not retreat.

They watched one another across the wide stretch of tide.

Neither spoke.

But the space between them felt alive.

The fox lowered herself into the sand.

The whale floated just beyond the waves.

The ocean continued its breathing.

In.

Out.

In.

Out.

The fox realized something as she listened.

The sea did not rush.

It did not hurry to arrive anywhere.

It simply moved in rhythm.

The whale, drifting in the cool water, understood something too.

The forest was not restless.

It did not strain toward the horizon.

It grew quietly, leaf by leaf.

They were different creatures.

One belonged to trees and shadows.

The other to depth and current.

Yet both lived by listening.

The fox to the wind.

The whale to the tides.

As the moon climbed higher, the silver light touched both fur and water.

The distance between them no longer felt large.

It felt peaceful.

The fox rested her head on her paws.

The whale let himself sink slightly, buoyed by calm.

Neither needed to cross into the other’s world.

It was enough to know the other existed.

To feel the steady rhythm shared between forest and sea.

After a long while, the fox rose.

She stepped backward toward the tree line.

The whale slowly drifted deeper into the dark blue below.

They did not say goodbye.

They did not promise to meet again.

The forest would still whisper.

The ocean would still breathe.

And somewhere between trees and tide, in the space where sound carries softly across distance, a fox and a whale would remember that even far apart…

They move to the same quiet rhythm.''',
      audioPath: "audio/stories/the fox and the wale.mp3",
      premium: false,
    ),
    Story(
      title: "The Station Where No Train Stops",
      content: '''There is a railway station that does not appear on schedules.

No announcements echo there.

No trains officially arrive.

Yet sometimes, very late at night, when someone feels between chapters of their life…

They find themselves standing on its quiet platform.

Daniel arrived there without meaning to.

He had been walking home after a long day. The streets were nearly empty. The air carried that deep midnight stillness that makes every sound feel larger.

He turned down a path he didn’t remember seeing before.

At the end of it stood a small railway platform.

No ticket booth.

No signs.

No name.

Just a long stretch of track disappearing into silver fog.

A single lantern glowed softly at the center.

Daniel checked his phone.

No signal.

No time displayed.

Only a blank screen.

He should have turned back.

Instead, he stepped onto the platform.

The moment his foot touched the stone, the world behind him faded into a gentle blur.

The city lights dissolved.

The noise disappeared.

The station felt suspended — not abandoned, not forgotten — just… waiting.

A wooden bench rested beneath the lantern.

He sat down.

The quiet there was different from ordinary silence.

It wasn’t empty.

It felt patient.

After a while, he noticed something unusual.

Across the tracks, faint shapes began to form.

Not trains.

Not people.

Scenes.

Brief glimpses, like reflections on water.

A version of himself staying where he was comfortable.

A version of himself choosing something unfamiliar.

A version of himself forgiving someone he still held tightly in memory.

They appeared and vanished, as though the fog itself was imagining them.

Daniel stood and walked closer to the edge of the platform.

The tracks stretched endlessly in both directions.

No sound of an approaching train.

No vibration beneath his feet.

And yet, he felt certain something was moving.

Not toward him.

But around him.

The lantern above flickered softly.

With each gentle pulse of light, another possibility shimmered in the distance.

He realized then that this station was not a place for departure.

It was a place for pause.

A space between decisions.

A platform built for moments when the next step feels unclear.

The fog across the tracks began to shift.

Not dramatically.

Just enough to reveal two directions.

One track curved slightly left.

The other continued straight into the pale glow of the horizon.

There were no signs telling him which to choose.

No conductor calling out destinations.

Only stillness.

Daniel closed his eyes.

He listened — not for trains — but for himself.

Underneath the noise of doubt.

Underneath the memory of expectations.

There it was.

A small, steady knowing.

Not loud.

Not urgent.

Just present.

When he opened his eyes again, the lantern glowed warmer.

The fog thinned.

He stepped forward.

The moment his foot crossed the edge of the platform, the station dissolved behind him.

The tracks became an ordinary sidewalk.

The lantern turned into a streetlight.

The fog lifted into the quiet air of early morning.

A distant train horn echoed somewhere far away.

Not for him.

Not this time.

But he understood now.

The station appears whenever someone needs space to choose without pressure.

It never forces arrival.

It never demands departure.

It simply waits.

And when the heart grows steady enough to move again…

The path continues.''',
      audioPath: "audio/stories/the station where no train stops.mp3",
      premium: false,
    ),
    Story(
      title: "The Lighthouse Between Them",
      content: '''Clara believed some places remembered love.

That was the only explanation she had for the lighthouse.

It stood alone on the edge of the cliffs, white paint weathered by salt and time. The ocean below moved in slow, endless breaths, as if the world itself were sleeping.

She had come there to be alone.

After the breakup. After the city noise. After realizing that sometimes love can end quietly — not with anger, but with absence.

The lighthouse keeper’s cottage had been empty for years. She rented it for the summer, hoping the sound of waves might soften the ache in her chest.

On her first evening, she climbed the narrow spiral stairs to the top.

The lantern room glowed gold with the setting sun.

And someone was already there.

He stood by the glass, looking out at the horizon.

Clara startled. “I didn’t know anyone else—”

“I could say the same,” he replied gently.

His name was Adrian.

He wasn’t the keeper. There hadn’t been one in years. He was restoring the lighthouse for the coastal heritage foundation — sanding wood, repairing beams, giving old things another chance.

Clara smiled at that.

Giving old things another chance.

They began with polite conversations.

Weather.

Waves.

The stubborn rust on the railing.

But something about the lighthouse made everything softer. Voices echoed gently. Footsteps slowed. Even silence felt shared.

Some evenings, they would sit at the top together, watching ships blink in the distance.

“Do you think the light still matters?” Clara asked once. “With all the GPS and technology?”

Adrian looked at the glowing lens.

“I think some lights aren’t about navigation,” he said. “They’re about comfort. About knowing something steady is out there.”

She didn’t realize how much she needed to hear that.

Days turned into a rhythm.

Mornings smelled like salt and coffee. Afternoons were filled with the scrape of sandpaper and the cry of distant gulls.

Clara began writing again — something she hadn’t done in months. Words came easier by the sea.

Adrian worked quietly, carefully, as if every nail he hammered was an apology to time itself.

One windy afternoon, rain rushed in unexpectedly. Clara ran toward the lighthouse, laughing as the storm chased her.

She slipped on the wet stone.

Strong hands caught her before she fell.

For a moment, they were close. Closer than they had ever been.

Rain streaked across his face. Her heartbeat thudded wildly.

“You okay?” he asked softly.

“Yes,” she whispered.

But her voice trembled.

Not from fear.

That night, the storm grew fierce.

The power flickered out in the cottage.

Without thinking, Clara grabbed a blanket and climbed to the lighthouse.

Adrian was already there, lighting oil lamps along the spiral stairs.

The sea roared below like something alive.

They stood at the top, wrapped in borrowed warmth, watching lightning split the sky.

“It’s beautiful,” Clara breathed.

“It’s terrifying,” Adrian corrected gently.

She smiled. “Same thing sometimes.”

Another flash of lightning illuminated the ocean — wild and endless.

And in that sudden brightness, Clara realized something.

She wasn’t lonely anymore.

Not in the quiet way that aches.

Adrian’s hand brushed hers.

Neither pulled away.

The storm raged. The lighthouse stood steady.

And between thunderclaps, their fingers intertwined fully for the first time.

Summer slowly softened into late August.

The lighthouse gleamed brighter now, freshly painted, restored.

Clara’s notebook was full.

Adrian’s repairs were nearly complete.

Change hovered in the air like the first hint of autumn.

One evening, as the sun sank into molten gold, Clara felt the old fear creeping back.

“What happens when the restoration is done?” she asked.

Adrian didn’t answer immediately.

He looked at the horizon, then at her.

“Then I decide where I want to stay.”

Her breath caught.

“And where do you want to stay?”

He stepped closer, close enough that she could see the reflection of the sea in his eyes.

“Somewhere steady,” he said quietly. “Somewhere that feels like light.”

The meaning wasn’t hidden.

It wasn’t rushed either.

It simply rested there between them.

True.

On the final night of summer, the lighthouse lantern shone fully for the first time in years.

They stood together at the top as the beam swept across dark water.

Ships blinked in response, small distant acknowledgments.

Clara leaned against him.

“Do you think places remember love?” she asked softly.

Adrian wrapped his arm around her shoulders.

“I think people do,” he replied.

The ocean breathed below.

The light turned steadily.

And for the first time in a long while, Clara understood something gentle and certain:

Some loves don’t arrive like storms.

They arrive like lighthouses.

Quiet.

Steady.

Guiding you home.

love can be steady.''',
      audioPath: "audio/stories/the lighthouse between them.mp3",
      premium: false,
    ),
    Story(
      title: "The Girl Who Waited for Sunrise",
      content: '''Mara had always loved mornings.

Not because she woke early.

But because sunrise felt honest.

Night could hide things. Noise could distract you. Even laughter sometimes covered loneliness. Morning never lied. Every dawn arrived quietly, asking nothing except that you begin again.

She watched most of them alone.

From the same park bench at the edge of the city, where buildings faded into trees and long grass.

It became her ritual after her father passed away.

He had loved sunrises too.

“Every day starts with forgiveness,” he used to say.

She didn’t fully understand what he meant.

Not then.

The first time she noticed him, he sat several benches away, wrapped in a grey coat despite the warm air. A thermos rested beside him.

He didn’t check his phone.

Didn’t rush.

He simply watched the sky.

Day after day.

Always arriving before the sun appeared.

Always leaving moments after it rose.

Sometimes their eyes met.

A polite nod.

Nothing more.

Still, his quiet presence felt comforting.

Like sharing silence with someone who understood it.

One morning rain arrived suddenly, scattering joggers and early walkers.

Mara stayed beneath an oak tree, stubborn against the drizzle.

Footsteps approached.

A warm cup appeared beside her.

“Coffee,” the man said gently. “Before it gets cold.”

She blinked. “I didn’t ask for this.”

“I know.”

He smiled slightly.

“I thought you might need it.”

His name was Daniel.

They spoke only a little that morning — about rain, about weather, about nothing important.

But when sunrise spilled gold across the park, silence returned easily between them.

Shared.

After that, conversation came naturally.

Some mornings they talked endlessly.

Other mornings not at all.

Daniel repaired old watches.

“I like things that tick slowly,” he explained once. “They remind people time doesn’t always rush.”

Mara laughed.

“That sounds nothing like this city.”

“Exactly why I stay,” he said.

She told him about grief arriving unexpectedly — in songs, empty chairs, or grocery aisles.

Daniel listened without interrupting.

It felt rare.

To be heard without advice.

Weeks passed.

Summer softened the air.

One morning she arrived late.

His bench was empty.

She told herself it meant nothing.

Still, the sunrise felt quieter without him.

The next day he returned holding two pastries.

“You disappeared,” she said before thinking.

He looked surprised.

“I thought maybe you had.”

They both laughed.

Relief settled quietly between them.

It happened slowly.

A shared umbrella during drizzle.

Walking out of the park together.

His hand brushing hers.

Then staying.

One morning he spoke softly.

“I started coming here after my wife died.”

The honesty landed gently.

“I think grief teaches people how to recognize each other,” Mara said.

Daniel nodded.

“I think it does.”

Autumn arrived early.

Fog covered the park one morning, hiding the sunrise completely.

Mara waited longer than usual.

Fear crept in unexpectedly.

What if he didn’t come back?

Then footsteps appeared through the mist.

Daniel sat beside her, handing her coffee without a word.

“I was afraid you wouldn’t come,” she admitted.

“So was I,” he said.

“Afraid of what?”

His smile was small.

“That I might stop needing sunrise if I stayed home with you instead.”

Her breath caught.

The fog lifted slowly.

Golden light broke through.

Without planning it, she leaned toward him.

He met her halfway.

The kiss was gentle.

Careful.

Two people learning that love after loss does not replace what came before.

It grows beside it.

Winter mornings became colder.

They brought thicker coats and longer conversations.

Sometimes they missed sunrise entirely because they were too busy laughing.

Neither minded.

One snowy morning Daniel placed something small into her hand.

A pocket watch.

Restored perfectly.

Inside the lid were delicate engraved words.

For every sunrise we almost missed.

Her eyes filled.

“You fixed time,” she whispered.

He shook his head gently.

“No.”

He took her hand.

“I just stopped running from it.”

Snow fell softly around them as the sky brightened.

Another morning began.

And this time, neither of them faced it alone.

Love waits patiently.''',
      audioPath: "audio/stories/the girl who waited for sunrise.mp3",
      premium: false,
    ),
    Story(
      title: "The Fox Who Borrowed the Wind",
      content:
          '''In the far northern grasslands, where silver reeds whispered even when no one walked through them, lived a fox named Luma.

She was smaller than the others.

Quieter too.

While the other foxes chased birds and argued over territory, Luma preferred listening — to insects moving beneath soil, to clouds shifting overhead, to the strange language the wind seemed to speak when dusk arrived.

The elders said she would never survive winter if she spent so much time staring at the sky.

But Luma believed the sky watched back.

One evening, as the sun melted into amber light, a powerful wind rolled across the plains.

It bent grasses flat and carried the scent of distant snow.

Luma followed it.

Not because she was brave.

Because she was curious.

The wind rushed toward the cliffs at the edge of the world — a place foxes avoided. Too steep. Too lonely.

At the very top stood a twisted pine tree shaped like a question.

And beneath it sat a raven.

Old.

Feathers faded to soft grey.

“You finally came,” the raven croaked.

Luma froze.

Animals did not usually speak aloud.

Not like that.

“I didn’t mean to,” she said carefully.

The raven tilted its head.

“Few do.”

The wind circled them both, tugging gently at her fur.

“You listen to it,” the raven continued.

“Yes.”

“Then perhaps it will listen to you.”

Winter arrived early that year.

Snow swallowed the plains.

Rivers froze.

Food grew scarce.

Foxes grew thin.

The wind howled endlessly across empty land.

Luma struggled to hunt. Rabbits vanished beneath deep drifts. Even birds disappeared into distant forests.

One long night, hungry and trembling, she climbed back toward the cliff.

The raven waited beneath the pine.

“You came again,” it said.

“I don’t know where else to go.”

The wind rose suddenly, swirling around them.

Cold.

Sharp.

Alive.

“Ask,” the raven whispered.

“Ask what?”

“For help.”

Luma hesitated.

Foxes did not ask.

Foxes survived.

But hunger and loneliness softened pride.

She closed her eyes.

“I don’t want to be afraid anymore,” she murmured into the storm.

The wind answered.

Not in words.

In warmth.

It wrapped around her gently, lifting snow from her paws and clearing a narrow path down the hillside.

Confused, she followed.

The trail led to a hidden hollow sheltered by fallen stone.

Inside, grasses still grew.

And rabbits slept beneath them.

Enough food to last weeks.

Luma understood then.

The wind had heard her.

Word spread quickly among the foxes.

They noticed she survived when others struggled.

They followed her sometimes, pretending it was coincidence.

Luma never chased them away.

She simply shared the hollow.

Winter softened.

Snow melted slowly into streams that sang across stone.

One morning she returned to the cliff to thank the raven.

The pine stood alone.

No feathers.

No footprints.

Only wind moving through branches.

For the first time, she realized something gentle.

Maybe the raven had never been separate from it.

Spring returned color to the plains.

Fox cubs chased butterflies again.

Birdsong filled mornings.

Luma still wandered alone sometimes.

But she was no longer lonely.

She understood now that listening was not weakness.

It was a way of belonging.

On warm evenings she climbed the cliffs and sat beneath the pine tree.

The wind curled around her like an old friend.

Carrying scents of rain.

Of distant mountains.

Of places she might someday explore.

She never asked it for food again.

Or safety.

Instead she asked simple things.

Stories.

And sometimes, when twilight turned the grasslands gold, the wind slowed just enough to whisper back.

Peace moves softly.''',
      audioPath: "audio/stories/the fox who borrowed the wind.mp3",
      premium: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Stories")),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return ListTile(
            leading: const Icon(Icons.book),
            title: Text(story.title),
            trailing: story.premium
                ? const Icon(Icons.lock, color: Colors.amber)
                : const Icon(Icons.arrow_forward),
            onTap: () {
              if (story.premium) {
                PaywallScreen.show(
                  context: context,
                  onSuccess: () {
                    Navigator.pop(context); // Close paywall
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) =>
                            StoryReaderScreen(sleepstory: story),
                      ),
                    );
                  },
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => StoryReaderScreen(sleepstory: story),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
