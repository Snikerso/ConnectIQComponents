# ConnectIQComponents

Reusable, themeable UI components for Garmin Connect IQ, written in Monkey C.
MIT licensed. Initial API: **0.2.0** (experimental; pin your dependency).

Compose instances, pass property dictionaries, override styles and connect
callbacks—an approach familiar from React. Rendering uses Garmin's drawing API;
there is no JSX, virtual DOM, automatic state binding or CSS engine.

## Quick integration: source dependency

Clone this repository into `vendor/ConnectIQComponents` inside your application,
or add it as a Git submodule. Pin a commit or release tag in production.

```sh
git submodule add https://github.com/Snikerso/ConnectIQComponents.git vendor/ConnectIQComponents
git -C vendor/ConnectIQComponents checkout v0.2.0
```

Add the library directory to your application's `monkey.jungle`:

```properties
base.sourcePath = source;vendor/ConnectIQComponents/source
```

If your application already has other source paths, keep them in this list.
No resources or application permissions are required by the library.
Minimum declared Connect IQ API: 3.2.0. Actual compiled targets are listed under validation below.

## Compose your UI

```monkeyc
import ConnectIQComponents;

var theme = new ConnectIQComponents.Theme({
    :background => 0x100D0A,
    :accent => 0xD7A15D,
    :foreground => 0xFFFFFF
});
var card = new ConnectIQComponents.Panel({
    :x => 60, :y => 90, :width => 240, :height => 180
}, theme);
var label = new ConnectIQComponents.Label({
    :text => "Rows: 0", :width => 240, :height => 60
}, theme);
card.add(label);
card.add(new ConnectIQComponents.Button({
    :text => "Add row", :x => 20, :y => 80,
    :width => 200, :height => 50,
    :style => {:radius => 24, :accent => 0x92581F},
    :onPress => method(:increment)
}, theme));
var view = new ConnectIQComponents.ComponentView(card, theme);
// Return these from AppBase.getInitialView():
return [view, new ConnectIQComponents.ComponentDelegate(view, method(:increment))];
```

Define `increment` on your application class. Update content with
`label.setProps({:text => "Rows: " + count.toString()})`.
For changes outside the delegate callback, call `WatchUi.requestUpdate()`.
See `examples/showcase` for a complete application with touch and hardware SELECT.

## API

| Component | Purpose | Extra props |
|---|---|---|
| Component | Container / base class for your own components | — |
| Panel | Rounded surface containing children | — |
| Label | Centered, width-fitted text | `:text` |
| Button | Rounded button with action | `:text`, `:onPress` |
| Badge | Capsule label / stat chip with border | `:text` |
| OutlineButton | Secondary action with border | `:text`, `:onPress` |
| Divider | Horizontal or vertical rule | `:vertical` |
| ProgressRing | Segmented progress ring | `:value`, `:ticks`, `:startAngle` |
| ProgressBar | Progress clamped to 0…1 | `:value` |
| ComponentView | WatchUi.View adapter | root component, theme |
| ComponentDelegate | Touch and SELECT adapter | view, SELECT callback or null |

Common props: `:x`, `:y`, `:width`, `:height`, `:visible`, `:disabled`, `:style`,
`:onPress`. Coordinates are local to the parent. Bounds must have nonnegative
dimensions. `add(child)` composes children; `setProps(dictionary)` merges top-level
props. Passing `:style` replaces the previous local style dictionary.

Theme tokens: `:background`, `:surface`, `:foreground`, `:accent`, `:muted`,
`:radius`, `:padding`, `:font`, `:border`, `:borderWidth`, `:track`,
`:ringWidth`, `:tickLength`. `theme.values` may be updated followed by a redraw.
Styles resolve on each draw: defaults → shared theme → local overrides.
Child themes are passed explicitly; children do not inherit their parent's local style.

Children draw in insertion order and receive input in reverse order. Hidden or
disabled parents block input to their subtree. Children are not clipped to their
parent's bounds. Hardware SELECT calls the explicitly supplied primary action;
there is no focus traversal yet. Text is truncated by width; choose a font that
fits the height. Layout uses pixels; the showcase derives its bounds from screen
size. Custom components override `paint(dc, x, y, style)`.

## Monkey Barrel distribution

Build with the official Connect IQ SDK and your own developer signing key:

```sh
export CONNECTIQ_SDK="/path/to/connectiq-sdk"
export CONNECTIQ_KEY="/path/to/developer_key"
./scripts/build.sh
```

Output: `dist/ConnectIQComponents-0.2.0.barrel` and showcase binaries for Venu 3
and fēnix 7. Keep signing keys outside this repository.

To use the barrel, copy it into your app's `barrels/` directory, then add this
inside your application's manifest `<iq:barrels>`:

```xml
<iq:depends name="ConnectIQComponents" version="0.2.0"/>
```

And configure the application's jungle:

```properties
base.barrelPath = barrels/ConnectIQComponents-0.2.0.barrel
```

Use either source integration or a barrel, never both at once. Existing barrel
paths must be preserved. See [Garmin build configuration](https://developer.garmin.com/connect-iq/articles/core-topics/Build_Configuration.html).

## Validation

Build script compiles the barrel and source-integrated showcase for AMOLED
(Venu 3) and MIP (fēnix 7). Unit tests cover theme isolation, partial prop updates,
nested hit bounds, disabled/hidden controls and overlapping input ordering.

```sh
"$CONNECTIQ_SDK/bin/monkeyc" -f tests/monkey.jungle -d venu3 -y "$CONNECTIQ_KEY" -t -o dist/tests.prg
"$CONNECTIQ_SDK/bin/monkeydo" dist/tests.prg venu3 -t
```

Verified with SDK 9.2.0: source showcase builds for Venu 3 and fēnix 7,
barrel consumer build for Venu 3, and all 6 simulator unit tests passed.
The barrel consumer example is in `examples/barrel-showcase`.

Compilation is not visual validation or confirmation on physical hardware.
Check on your supported devices before shipping.

## Public releases

Publish this repository to GitHub, tag versions (`v0.2.0`) and attach the `.barrel`
to GitHub Releases. The library is a developer dependency, not a Connect IQ Store
application. Consumers can choose a source checkout or a downloadable barrel.
Release procedure and contribution guidance: [CONTRIBUTING.md](CONTRIBUTING.md).

## Extracted indicators (0.2.0)

Badge generalizes the stat/value chips from KnittingCounter. OutlineButton and
Divider generalize TeaStop secondary actions and top rules. ProgressRing
generalizes TeaStop segmented timer progress, without timer or persistence logic.
The consuming apps are not migrated by this library release.

```monkeyc
var ring = new ConnectIQComponents.ProgressRing({
    :x=>40, :y=>40, :width=>280, :height=>280,
    :value=>0.75, :ticks=>60, :startAngle=>-90,
    :style=>{:accent=>0xB3DFAC, :track=>0x203028, :ringWidth=>3, :tickLength=>6}
}, theme);
ring.setProps({:value=>elapsedSeconds / totalSeconds.toFloat()});
```

Progress values are clamped to 0…1. The ring starts at the top and advances
clockwise by default. Nonpositive tick counts draw nothing; use a reasonable
count (for example 12 or 60) to stay within watch rendering budgets.
Badge radius follows its height; OutlineButton uses the theme radius.
All new components share the existing bounds, composition and input behavior.
