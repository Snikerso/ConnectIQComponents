import Toybox.Test;
import ConnectIQComponents;
(:test)
function testThemeOverrides(logger) {
    var theme = new ConnectIQComponents.Theme({:accent=>0x123456});
    var first = new ConnectIQComponents.Button({:style=>{:accent=>0xABCDEF}}, theme);
    var second = new ConnectIQComponents.Button({}, theme);
    Test.assertEqual(first.style()[:accent], 0xABCDEF);
    Test.assertEqual(second.style()[:accent], 0x123456);
    first.setProps({:text=>"Changed"});
    Test.assertEqual(first.style()[:accent], 0xABCDEF);
    return true;
}
class PressRecorder {
    var count = 0;
    function initialize() {}
    function pressed() { count++; }
}
(:test)
function testNestedHitTesting(logger) {
    var recorder = new PressRecorder();
    var root = new ConnectIQComponents.Panel({:x=>10, :y=>20}, null);
    var button = new ConnectIQComponents.Button({:x=>5, :y=>5, :width=>20, :height=>20,
        :onPress=>recorder.method(:pressed)}, null);
    root.add(button);
    Test.assert(root.press(15, 25, 0, 0));
    Test.assertEqual(recorder.count, 1);
    Test.assert(!root.press(35, 45, 0, 0));
    button.setProps({:disabled=>true});
    Test.assert(!root.press(16, 26, 0, 0));
    button.setProps({:disabled=>false, :visible=>false});
    Test.assert(!root.press(16, 26, 0, 0));
    Test.assertEqual(recorder.count, 1);
    return true;
}
(:test)
function testTopmostReceivesPress(logger) {
    var first = new PressRecorder();
    var second = new PressRecorder();
    var root = new ConnectIQComponents.Component({}, null);
    root.add(new ConnectIQComponents.Button({:onPress=>first.method(:pressed)}, null));
    root.add(new ConnectIQComponents.Button({:onPress=>second.method(:pressed)}, null));
    Test.assert(root.press(2, 2, 0, 0));
    Test.assertEqual(first.count, 0);
    Test.assertEqual(second.count, 1);
    root.setProps({:visible=>false});
    Test.assert(!root.press(2, 2, 0, 0));
    return true;
}

// Test the emitted drawing operations, independent of device font metrics.
class DrawingRecorder {
    var lines = [];
    var fills = [];
    var texts = [];
    var foreground;
    var penWidth = 1;
    function initialize() {}
    function setColor(fg, bg) { foreground = fg; }
    function setPenWidth(width) { penWidth = width; }
    function drawLine(x1, y1, x2, y2) { lines.add([x1, y1, x2, y2, foreground]); }
    function fillRoundedRectangle(x, y, w, h, radius) { fills.add([x,y,w,h,radius]); }
    function drawRoundedRectangle(x, y, w, h, radius) {}
    function getTextWidthInPixels(text, font) { return text.length()*6; }
    function drawText(x, y, font, text, justification) { texts.add([text, foreground]); }
}
(:test)
function testRingClampAndGeometry(logger) {
    var ring = new ConnectIQComponents.ProgressRing({:x=>10, :y=>20, :width=>100, :height=>80,
        :ticks=>12, :value=>0.5, :style=>{:accent=>1, :track=>2}}, null);
    Test.assertEqual(ring.activeTicks(), 6);
    var dc = new DrawingRecorder();
    ring.draw(dc, 5, 5);
    Test.assertEqual(dc.lines.size(), 12);
    for (var i = 0; i < dc.lines.size(); i++) {
        var line = dc.lines[i];
        Test.assert(line[0]>=15 && line[0]<=115 && line[2]>=15 && line[2]<=115);
        Test.assert(line[1]>=25 && line[1]<=105 && line[3]>=25 && line[3]<=105);
        Test.assertEqual(line[4], i < 6 ? 1 : 2);
    }
    Test.assertEqual(dc.penWidth, 1);
    ring.setProps({:value=>5});
    Test.assertEqual(ring.activeTicks(), 12);
    ring.setProps({:value=>-1});
    Test.assertEqual(ring.activeTicks(), 0);
    ring.setProps({:ticks=>0});
    dc = new DrawingRecorder();
    ring.draw(dc, 0, 0);
    Test.assertEqual(dc.lines.size(), 0);
    return true;
}
(:test)
function testBadgeAndOutlineStyles(logger) {
    var theme = new ConnectIQComponents.Theme({:accent=>7, :muted=>8});
    var badge = new ConnectIQComponents.Badge({:text=>"42", :height=>20}, theme);
    var dc = new DrawingRecorder();
    badge.draw(dc, 0, 0);
    Test.assertEqual(dc.fills[0][4], 10);
    Test.assertEqual(dc.texts[0][0], "42");
    var button = new ConnectIQComponents.OutlineButton({:text=>"Cancel", :disabled=>true}, theme);
    button.draw(dc, 0, 0);
    Test.assertEqual(dc.texts[1][1], 8);
    Test.assertEqual(theme.values[:accent], 7);
    return true;
}
(:test)
function testDividerOrientation(logger) {
    var divider = new ConnectIQComponents.Divider({:x=>10, :y=>20, :width=>40, :height=>10}, null);
    var dc = new DrawingRecorder();
    divider.draw(dc, 5, 5);
    Test.assertEqual(dc.lines[0][0], 15);
    Test.assertEqual(dc.lines[0][2], 55);
    Test.assertEqual(dc.lines[0][1], dc.lines[0][3]);
    divider.setProps({:vertical=>true});
    divider.draw(dc, 5, 5);
    Test.assertEqual(dc.lines[1][0], dc.lines[1][2]);
    Test.assertEqual(dc.lines[1][1], 25);
    Test.assertEqual(dc.lines[1][3], 35);
    Test.assertEqual(dc.penWidth, 1);
    return true;
}
